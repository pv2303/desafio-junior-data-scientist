/* 
Perguntas do perguntas_sql.md

    Localização de chamados 1746
*/


-- 1. Quantos chamados foram abertos no dia 01/04/2023?

SELECT COUNT(*) AS numero_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) = '2023-04-01';

-- R: 1903 chamados abertos no dia 01/04/2023.

--------------------------------

-- 2. Qual o tipo de chamado que teve mais teve chamados abertos no dia 01/04/2023?
SELECT 
      tipo,
      COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE DATE(data_inicio) = '2023-04-01'
GROUP BY tipo
ORDER BY total_chamados DESC
LIMIT 1;

-- R: Estacionamento irregular foi o tipo com maior número de chamados no dia 01/04/2023 com 373 chamadas

---------------------------------

-- 3. Quais os nomes dos 3 bairros que mais tiveram chamados abertos nesse dia?

SELECT bairros.nome AS nome_bairro,
       COUNT(chamados.id_chamado) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS chamados
LEFT JOIN `datario.dados_mestres.bairro` AS bairros
USING(id_bairro)
WHERE DATE(data_inicio) = '2023-04-01'
AND id_bairro IS NOT NULL
GROUP BY nome_bairro
ORDER BY total_chamados DESC
LIMIT 3;

-- R: Os três bairros com maior número de chamadas abertas no dia 01/04/2023 foram: Campo Grande, com 124 chamados; Tijuca, 96; e Barra da Tijuca, 60.

--------------------------------
 
-- 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?

SELECT bairros.subprefeitura AS nome_subprefeitura,
       COUNT(chamados.id_chamado) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS chamados
LEFT JOIN `datario.dados_mestres.bairro` AS bairros
USING(id_bairro)
WHERE DATE(data_inicio) = '2023-04-01'
AND id_bairro IS NOT NULL
GROUP BY nome_subprefeitura
ORDER BY total_chamados DESC
LIMIT 1;

-- R: A subprefeitura com mais chamados abertos no dia 01/04/2023 foi a Zona Norte com 534 chamados.

---------------------------

-- 5. Existe algum chamado aberto nesse dia que não foi associado a um bairro ou subprefeitura na tabela de bairros? Se sim, por que isso acontece?

SELECT tipo AS tipo_de_chamado,
       COUNT(id_chamado) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado` AS chamados
WHERE DATE(data_inicio) = '2023-04-01'
AND id_bairro IS NULL
GROUP BY tipo
ORDER BY total_chamados DESC;

-- R: Sim, existiram chamados que não foram associados à nenhum id_bairro e, portanto, à nenhuma subprefeitura. Avaliando os principais tipos de chamados que possuem esta característica, é possível verificar que essas questões não dependem do espaço geográfico do cidadão que as origina. Por exemplo, chamados em relação aos ônibus não necessariamente serão questões de um só bairro, visto que existem ônibus (a grande maioria) cujo trajeto perpassa múltiplos bairros. Atendimento ao cidadão é outro caso, visto que dúvidas, sugestões, aviso de erros ou problemas com serviços digitais da prefeitura podem não ser ligados ao local em que o cidadão está fazendo o chamado. Ou seja, a maior parte dessas questões não são dependentes diretamente da localização.

---------------------------

-- Chamados do 1746 em grandes eventos

-- 6. Quantos chamados com o subtipo "Perturbação do sossego" foram abertos desde 01/01/2022 até 31/12/2023 (incluindo extremidades)?

SELECT subtipo,
  COUNT(*) AS total_chamados
FROM `datario.adm_central_atendimento_1746.chamado`
WHERE (subtipo LIKE "%sossego%"
OR subtipo LIKE "%Sossego%")
AND DATE(data_inicio) BETWEEN '2022-01-01' AND '2023-12-31'
GROUP BY subtipo;

-- R: Entre o período solicitado, não há um subtipo exato de "Perturbação do sossego". Assim, escolhi os subtipos com nomes próximos, a saber: "Fiscalização de perturbação do sossego" com 50.368 chamados abertos e "Informações sobre Perturbação do Sossego" com 11.590. Portanto, se totaliza 61.958 chamados abertos com subtipos relacionados à perturbação do sossego.

-- OBSERVAÇÃO: Considerando que este subtipo será utilizado nas próximas questões, é importante ressaltar que a nomenclatura exata varia ao longo do tempo. Assim, é importante levar em conta outras nomenclaturas que possam ser utilizadas para este tipo de chamado. Portanto, optei por usar o %sossego% para abranger todas as possíveis nomenclaturas que verifiquei na base que são coerentes com este subtipo.

---------------------------

-- 7. Selecione os chamados com esse subtipo que foram abertos durante os eventos contidos na tabela de eventos (Reveillon, Carnaval e Rock in Rio)

WITH eventos AS (
  SELECT evento,
  data_evento
  FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`,
  UNNEST(GENERATE_DATE_ARRAY(data_inicial, data_final)) AS data_evento
  WHERE data_inicial IS NOT NULL
),

chamado_eventos AS (
  SELECT 
    id_chamado,
    data_inicio,
    subtipo,
  FROM `datario.adm_central_atendimento_1746.chamado`
  WHERE DATE(data_inicio) IN (SELECT data_evento FROM eventos)
  AND subtipo LIKE "%sossego%"
)

SELECT *
FROM chamado_eventos;

-- R: o select acima mostra a tabela filtrada considerando o subtipo e os dias dos eventos.

---------------------------

-- 8. Quantos chamados desse subtipo foram abertos em cada evento?

WITH eventos AS (
  SELECT evento,
  data_evento
  FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`,
  UNNEST(GENERATE_DATE_ARRAY(data_inicial, data_final)) AS data_evento
  WHERE data_inicial IS NOT NULL
),

chamado_eventos AS (
  SELECT 
    id_chamado,
    data_inicio,
    subtipo,
  FROM `datario.adm_central_atendimento_1746.chamado`
  WHERE DATE(data_inicio) IN (SELECT data_evento FROM eventos)
  AND subtipo LIKE "%sossego%"
)

SELECT 
  ev.evento,
  COUNT(ch.id_chamado) AS total_chamados
FROM chamado_eventos AS ch
LEFT JOIN eventos AS ev
ON DATE(ch.data_inicio) = ev.data_evento
GROUP BY ev.evento;

-- R: Foram abertos 946 chamados do subtipo Perturbação do sossego no Rock in Rio, 252 no Carnaval e 147 no Réveillon.

---------------------------

-- 9. Qual evento teve a maior média diária de chamados abertos deese subtipo ?
WITH eventos AS (
  SELECT evento,
  data_evento
  FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`,
  UNNEST(GENERATE_DATE_ARRAY(data_inicial, data_final)) AS data_evento
  WHERE data_inicial IS NOT NULL
),

chamados AS (
  SELECT 
    DATE(data_inicio) AS data_chamado,
    COUNT(id_chamado) AS total_dia_chamados
  FROM `datario.adm_central_atendimento_1746.chamado`
  WHERE subtipo LIKE "%sossego%"
  GROUP BY data_inicio
),

chamados_por_evento AS (
  SELECT 
    ev.evento,
    ch.data_chamado,
    ch.total_dia_chamados
  FROM eventos AS ev
  JOIN chamados AS ch
    ON ev.data_evento = ch.data_chamado
)

SELECT 
  evento, 
  SUM(total_dia_chamados) / COUNT(DISTINCT data_chamado) AS media_diaria
FROM chamados_por_evento
GROUP BY evento
ORDER BY media_diaria DESC
LIMIT 1;

-- R: o Rock in Rio foi o evento maior média diária de chamados abertos desse subtipo com cerca de 135 chamadas por dia.

---------------------------

-- 10. Compare as médias diárias de chamados abertos desse subtipo durante os eventos específicos (Reveillon, Carnaval e Rock in Rio) e a média diária de chamados abertos desse subtipo considerando todo o período de 01/01/2022 até 31/12/2023.

WITH eventos AS (
  SELECT evento,
  data_evento
  FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`,
  UNNEST(GENERATE_DATE_ARRAY(data_inicial, data_final)) AS data_evento
  WHERE data_inicial IS NOT NULL
),

chamados AS (
  SELECT 
    DATE(data_inicio) AS data_chamado,
    COUNT(id_chamado) AS total_dia_chamados
  FROM `datario.adm_central_atendimento_1746.chamado`
  WHERE subtipo LIKE "%sossego%"
  GROUP BY data_inicio
),

chamados_por_evento AS (
  SELECT 
    ev.evento,
    ch.data_chamado,
    ch.total_dia_chamados
  FROM eventos AS ev
  JOIN chamados AS ch
    ON ev.data_evento = ch.data_chamado
),

media_eventos AS (
  SELECT 
    evento, 
    SUM(total_dia_chamados) / COUNT(DISTINCT data_chamado) AS media_diaria
  FROM chamados_por_evento
  GROUP BY evento
  ORDER BY media_diaria DESC
),

media_periodo AS (
  SELECT 
    'Total do Período' AS evento,
    SUM(total_dia_chamados) / COUNT(DISTINCT data_chamado) AS media_diaria
  FROM chamados
  WHERE data_chamado BETWEEN '2022-01-01' AND '2023-12-31'
)

SELECT * FROM media_eventos
UNION ALL
SELECT * FROM media_periodo
ORDER BY media_diaria DESC;

-- R: Entre 2022 e 2023, os cariocas abriram cerca de 72 chamadas por dia em média do tipo "Perturbação do sossego", sendo maior que o número de chamadas médias do carnaval e do Réveillon. Porém, o Rock in Rio ainda possui o principal com o número de reclamações desse tipo, sendo quase 90% maior que a média total do período.