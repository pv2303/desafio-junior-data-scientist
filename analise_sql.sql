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

-- 2. Qual o tipo de chamado que teve mais teve chamado ?
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
 
## 4. Qual o nome da subprefeitura com mais chamados abertos nesse dia?
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