# Script para gerar dados do dashboard contido no analise_dashboard.pbix

# Libs necessárias
import pandas as pd
import basedosdados as bd
import os
import requests


# Traduzir os codigos wmo de clima 
def traduzir_wmo_code(df: pd.DataFrame, coluna_wmo: str, nome_desc: str = 'desc_wmo_pt'):
    """
    Traduz os códigos WMO, da coluna `weather_code` para o português. Apenas os códigos que apareceram na base coletada df_tempo foram contemplados
    
    Args:
        df (pd.DataFrame): data frame que possui uma coluna com os códigos wmo
        coluna_wmo (str): nome da coluna que possui códigos wmo
        nome_desc (str): nome da coluna que descreverá os códigos wmo. O padrão é 'desc_wmo_pt'
        
    retorna
        df (pd.DataFrame): data frame com uma nova coluna com a descrição em português dos códigos WMO
    """
    
    dict_desc = {
        0: 'Ensolarado',
        1: 'Principalmente ensolarado',
        2: 'Parcialmente nublado',
        3: 'Nublado',
        51: 'Garoa leve',
        53: 'Garoa moderada',
        55: 'Garoa forte',
        61: 'Chuva leve',
        63: 'Chuva moderada',
        65: 'Chuva forte'
    }
    
    df[nome_desc] = df[coluna_wmo].map(dict_desc)
    
    return df
    
# Dados de chamados 1746
def pegar_chamados(data_inicio: str, data_fim: str, bill_id: str):
    """
    Retorna um pd.DataFrame contendo os micro dados de chamados do 1746 da Prefeitura da Cidade do Rio de Janeiro. Os dados são extraídos diretamente do BigQuery da Prefeitura. Você precisa informar apenas o intervalo temporal (data_inicio e data_fim) que são inclusivos, isto é, as extremidades serão consideradas e informar o bill_id, que é o id de projeto da sua conta no Google Cloud Platform.
    
    O único tratamento feito converter a data_inicio e data_fim para o formato 'YYY-MM-DD' e posteriomente converter para datetime.
    
    Args:
        data_inicio (str): Data de início no formato 'YYYY-MM-DD' (ex: '2023-01-01')
        data_inicio (str): Data de fim no formato 'YYYY-MM-DD' (ex: '2024-12-31')
        bill_id (str): id do projeto da sua conta no Google Cloud Platform.
        
    Retorna:
        df_chamado (pd.DataFrame): microdados de chamados abertos no período solicitado. As colunas de data já vem no formato datetime
    """
    
    query = f"""
    SELECT 
        ch.id_chamado,
        DATE(ch.data_inicio) AS data_abertura,
        DATE(ch.data_fim) AS data_fechamento,
        ch.id_bairro,
        ba.nome AS nome_bairro,
        ba.subprefeitura,
        ch.id_unidade_organizacional,
        ch.nome_unidade_organizacional,
        ch.unidade_organizacional_ouvidoria,
        ch.categoria,
        ch.tipo,
        ch.subtipo,
        ch.longitude,
        ch.latitude,
        ch.data_alvo_finalizacao,
        ch.data_alvo_diagnostico,
        ch.data_real_diagnostico,
        ch.tempo_prazo,
        ch.prazo_unidade,
        ch.dentro_prazo
    FROM `datario.adm_central_atendimento_1746.chamado` AS ch
    LEFT JOIN `datario.dados_mestres.bairro` AS ba
    USING(id_bairro)
    WHERE DATE(data_inicio) BETWEEN '{data_inicio}' AND '{data_fim}'
    """
    
    df_chamado = bd.read_sql(query, billing_project_id=bill_id)
    
    df_chamado['data_abertura'] = pd.to_datetime(df_chamado['data_abertura'])
    df_chamado['data_fechamento'] = pd.to_datetime(df_chamado['data_fechamento'])
    
    return df_chamado

def pegar_dados_tempo(data_inicial: str, data_final: str,
                      daily_vars = ['temperature_2m_mean', 'weather_code']):
    """
    Retorna um objeto pd.DataFrame com os dados diários de tempo para um local entre duas datas estabelecidas. Os dados são coletados do Open-Meteo Historical Weather API. Para mais informações, acesse: <https://open-meteo.com/>
    
    Args:
        data_inicial(str): Data de início no formato 'YYYY-MM-DD'
        data_final (str): Data de fim no formato 'YYYY-MM-DD'
        daily_vars (str ou list): Variáveis desejadas (ex: 'temperature_2m_mean ou ['temperature_2m_mean', 'weather_code'])
    
    Retorna:
        df (pd.DataFrame): um DataFrame com colunas de dados climáticos
    """
    
    # Verificar se é string para converter para lista
    if isinstance(daily_vars, str):
        daily_vars = [daily_vars]
    
    # API para fazer o geocoding
    url_geocode = 'https://geocoding-api.open-meteo.com/v1/search'
    params_geocode = {
        'name': 'Rio de Janeiro',
        'count': 1
    }
    resp_geocode = requests.get(url=url_geocode, params=params_geocode)
    resp_geocode.raise_for_status()
    dict_geocode = resp_geocode.json()['results'][0]
    
    # API dos dados de tempo
    url_weather = "https://archive-api.open-meteo.com/v1/archive"
    params_weather = {
        'latitude': dict_geocode['latitude'],
        'longitude': dict_geocode['longitude'],
        'start_date': data_inicial,
        'end_date': data_final,
        'daily':    daily_vars,
        'timezone': 'America/Sao_Paulo'
    }
    
    # Acessando os dados
    resp_weather = requests.get(url=url_weather, params=params_weather)
    resp_weather.raise_for_status()
    dados = resp_weather.json()['daily']

    # Convertendo para DataFrame
    df_clima = pd.DataFrame(dados)
    df_clima['time'] = pd.to_datetime(df_clima['time'])
    df_clima.rename({'temperature_2m_mean': 'temperatura_media'})
    
    return df_clima

def pegar_feriados(anos = ['2023', '2024']):
    """
    Acessa a API de feriados (https://date.nager.at) para obter os feriados do Brasil.
    
    Args:
        anos (list): lista dos anos que serão coletados.
        
    Retorna:
        df_feriado_final (pd.DataFrame): um data frame contendo duas colunas: data do feriado (em datetime) e o nome do feriado.
    """
    if isinstance(anos, str):
        anos = [anos]
    
    pais = 'BR'
    
    df_feriado_final = pd.DataFrame()
    
    # URL
    for ano in anos:
        feriado_api_url = f'https://date.nager.at/api/v3/publicholidays/{ano}/{pais}'
        # Requisição
        resp_feriado = requests.get(feriado_api_url)
        resp_feriado.raise_for_status()

        feriado = resp_feriado.json()
        df_feriado = pd.DataFrame(feriado)
        df_feriado_final = pd.concat([df_feriado_final, df_feriado], ignore_index=True)
    
    
    df_feriado_final = df_feriado_final.loc[:, ['date', 'localName']]
    
    df_feriado_final.rename(columns={'localName': 'Nome do Feriado'}, inplace=True)
    df_feriado_final['date'] = pd.to_datetime(df_feriado_final['date'])
    
    return df_feriado_final


def main():
    
    output_path = 'output'
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    data_inicial = '2023-01-01'
    data_final = '2024-12-31'
    
    df_chamado = pegar_chamados(data_inicio=data_inicial,
                                data_fim=data_final,
                                bill_id='teste-tecnico-pcrj')
    
    df_tempo = pegar_dados_tempo(data_inicial=data_inicial,
                                 data_final=data_final)
    
    df_tempo = traduzir_wmo_code(df=df_tempo,
                                 coluna_wmo='weather_code',
                                 nome_desc='tempo_descricao')
    
    df_feriado = pegar_feriados()
    
    path_chamado = os.path.join(output_path, 'df_chamado.csv')
    path_tempo = os.path.join(output_path, 'df_tempo.csv')
    path_feriado = os.path.join(output_path, 'df_feriado.csv')
    
    paths = {path_chamado: df_chamado,
             path_tempo: df_tempo,
             path_feriado: df_feriado}
    
    for path, df in paths.items():
        # separadores ; e decimal com ',' para o Power BI reconhecer corretamente os CSVs
        df.to_csv(path, sep=';', decimal=',', index=False)

if __name__ == '__main__':
    main()