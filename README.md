# Minhas Respostas ao Desafio Técnico – Cientista de Dados Júnior (Prefeitura RJ)

Bem-vindos! Este repositório contém as minhas respostas ao Desafio técnico para Cientista de Dados Junior da Prefeitura da Cidade do Rio de Janeiro. Este desafio testa nossas habilidades em SQL, Python e visualização de dados e é dividido em 7 etapas.

O Desafio exige a utilização de dados constantes no [data.rio](data.rio) de Chamados da Central de Atendimento 1746 da Prefeitura, bairros da cidade do Rio de janeiro e ocupação hoteleira em grandes eventos na cidade. Adicionalmente, também solicitam o uso dos dados contidos nas APIs públicas: [Public Holiday API](https://date.nager.at/Api) e [Open-Meteo Historical Weather API](https://open-meteo.com/). 

Para mais informações acerca do desafio, acesse a pasta `docs`.

Resumidamente, o desafio exige:
1. Arquivo `analise_sql.sql` contendo as _queries_ necessárias para responder as perguntas contidas em `docs/perguntas_sql.md`;
2. Arquivo `analise_python.py` ou `analise_python.ipynb` respondendo as perguntas contidas em `docs/perguntas_sql.md`, utilizando principalmente as bibliotecas `pandas` e `basedosdados` em Python;
3. Arquivo `analise_api.py` ou `analise_api.ipynb` respondendo as perguntas contidas em `docs/perguntas_api.md`. Ainda que, neste caso, não tenham especificado o uso obrigatório da biblioteca `pandas`, utilizei também para esta análise, por questão de consistência as outras análises;
4. _Dashboard_ desenvolvido por Looker, PBI, Tableau ou qualquer outra ferramenta de visualização de dados, utilizando os dados da Central de Atendimento 1746, bem como das APIs especificadas. No meu caso, utilizei o Power BI;
5. Por fim, fazer _commits_ incrementais ao repositório e fazer um push final ao repositório, contendo também um README com os passos necessários para rodar o código.

## Passos Necessários

1. **Clone o repositório**

```bash
git clone https://github.com/pv2303/desafio-junior-data-scientist
cd desafio-junior-data-scientist
```

2. **Estabeleça um ambiente virtual** (opcional, mas recomendado)

```bash
python3 -m venv venv
venv/Scripts/activate # Em Linux: source venv/bin/activate
```

3. **Instale as bibliotecas**

```bash
pip install -r requisitos.txt
```

4. **Instale o PowerBI**

Meu *dashboard* está contido no arquivo `analise_dashboard.pbix`. Para acessá-lo, é necessário o Power BI instalado. O Power BI pode ser baixado gratuitamente pela Microsoft Store. Acesse [aqui](https://apps.microsoft.com/detail/9NTXR16HNW1T?hl=pt-br&gl=BR&ocid=pdpshare).

5. **Alterar o objeto bill_id**

Caso queiram rodar o `analise_python.ipynb`, será necessário mudar o objeto `bill_id` constante na linha 6 do primeiro *chunk* de código python. 

O id que está no *script* é relacionado ao projeto criado pela minha conta no gmail, não havendo possibilidade de acesso fora dele. O tutorial de como criar conta no Google Cloud Platform (GCP) para obter este id pode ser acessado [aqui](https://docs.dados.rio/tutoriais/como-acessar-dados/).

## Respostas

### SQL

As repostas ao SQL constam como comentário, utilizando o "--" no arquivo *.sql*. As *queries* foram escritas utilizando o padrão SQL do BigQuery. Para acessar os resultados, é necessário fazer a consulta diretamente no GCP.

### Python

As respostas do Python são resultados impressos (`print()`) nos *chunks* de código em Python. As únicas exceções a esta regra são as questões 5 e 10 do `perguntas_sql.md`, que são necessárias inferências adicionais para respondê-las.

Os arquivos estão nomeados conforme as especificações das etapas.

### Visualização de dados

O Power BI não permite a criação de um link sem um email corporativo. Logo, compartilho o .pbix para a visualização do Dashboard em `analise_dashboard.pbix`. Os ícones utilizados na visualização podem ser acessados na pasta `icons` e o README desta pasta consta a fonte das imagens.

Conforme já falado, o desafio exigia o uso das bases de dados mencionadas nos arquivos com as perguntas. Porém, diferentemente dos *scripts* `analise_*.ipynb`, decidi criar um *script* **.py** para demonstrar minhas habilidades em moduralização de código. Assim, a geração dos dados utilizados no *dashboard* foi modularizada em funções específicas no script `dados_dashboard.py`,contendo o código para gerar os arquivos *.csv* utilizados no *dashboard*, mas não vieram para o repositório pois um desses arquivos pesa mais de 400MB, inviabilizando o *push*. Ou seja, **o *script* está disponível para caso queiram os dados brutos utilizados, mas não é necessário para visualizar o *dashboard*, pois o Power BI é capaz de comprimir o tamanho dos arquivos e armazená-los em um *.pbix*.**

Assim, o `analise_dashboard.pbix` contém tanto os dados utilizados quanto as visualizações. Caso seja a primeira vez que tenha entrado no Power BI, é necessário habilitar os mapas para que o mapa feito no *dash* esteja disponível para você (o próprio Power BI coloca o caminho no aplicativo para habilitar esta opção).

---

Obrigado por ler até aqui e visitar! ✨