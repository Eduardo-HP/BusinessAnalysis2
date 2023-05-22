CREATE TABLE empresa2.TB_PIPELINE_VENDAS (
  `Account` text,
  `Opportunity_ID` text,
  `Sales_Agent` text,
  `Deal_Stage` text,
  `Product` text,
  `Created_Date` text,
  `Close_Date` text,
  `Close_Value` text DEFAULT NULL
);

CREATE TABLE empresa2.TB_VENDEDORES (
  `Sales_Agent` text,
  `Manager` text,
  `Regional_Office` text,
  `Status` text
);

# Dados carregados no MySQL Workbench

# Total de vendas
SELECT COUNT(*) 
FROM empresa2.TB_PIPELINE_VENDAS;

# Valor total vendido
SELECT SUM(close_value) AS total_valor_venda
FROM empresa2.TB_PIPELINE_VENDAS;

SELECT SUM(CAST(close_value AS UNSIGNED)) AS total_valor_venda
FROM empresa2.TB_PIPELINE_VENDAS;

# Número de vendas concluídas com sucesso
SELECT COUNT(*) AS num_vendas_sucesso
FROM empresa2.TB_PIPELINE_VENDAS
WHERE deal_stage = "Won";
 
# Média do valor das vendas concluídas com sucesso
SELECT ROUND(AVG(CAST(close_value AS UNSIGNED)),2) AS media
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
WHERE tbl.deal_stage = "Won";

# Valos máximo vendido
SELECT MAX(CAST(close_value AS UNSIGNED)) AS valor_maximo
FROM empresa2.TB_PIPELINE_VENDAS;

# Valor mínimo vendido entre as vendas concluídas com sucesso
SELECT MIN(CAST(close_value AS UNSIGNED)) AS valor_minimo
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
WHERE tbl.deal_stage = "Won";

# Valor médio das vendas concluídas com sucesso por agente de vendas
SELECT sales_agent, ROUND(AVG(CAST(close_value AS UNSIGNED)),2) AS valor_medio
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
WHERE tbl.deal_stage = "Won"
GROUP BY sales_agent
ORDER BY valor_medio DESC;
 
# Valor médio das vendas concluídas com sucesso por gerente do agente de vendas
SELECT tbl1.manager, ROUND(AVG(CAST(tbl2.close_value AS UNSIGNED)),2) AS valor_medio
FROM empresa2.TB_VENDEDORES AS tbl1
JOIN empresa2.TB_PIPELINE_VENDAS AS tbl2 ON (tbl1.sales_agent = tbl2.sales_agent)
WHERE tbl2.deal_stage = "Won"
GROUP BY tbl1.manager;

# Total do valor de fechamento da venda por agente de venda e por conta das vendas concluídas com sucesso
SELECT sales_agent, account, SUM(CAST(close_value AS UNSIGNED)) AS total
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
WHERE tbl.deal_stage = "Won"
GROUP BY sales_agent, account
ORDER BY sales_agent, account;

# Número de vendas por agente de venda para as vendas concluídas com sucesso e valor de venda superior a 1000
SELECT sales_agent,
       COUNT(tbl.close_value) AS total
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
WHERE tbl.deal_stage = "Won"
AND tbl.close_value > 1000
GROUP BY tbl.sales_agent;
 
# Número de vendas e a média do valor de venda por agente de vendas
SELECT sales_agent,
       COUNT(tbl.close_value) AS contagem,
       ROUND(AVG(CAST(tbl.close_value AS UNSIGNED)),2) AS media
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
GROUP BY tbl.sales_agent
ORDER BY contagem DESC;

# Agentes de vendas com mais de 30 vendas
SELECT sales_agent,
       COUNT(tbl.close_value) AS num_vendas_sucesso
FROM empresa2.TB_PIPELINE_VENDAS AS tbl
GROUP BY tbl.sales_agent
HAVING COUNT(tbl.close_value) > 30;

# Total do valor de venda de todos os agentes de vendas e os sub-totais por escritório regional
# Resultado das vendas concluídas com sucesso
SELECT COALESCE(B.regional_office, "Total") AS "Escritório Regional",
       COALESCE(A.sales_agent, "Total") AS "Agente de Vendas",
       SUM(A.close_value) AS Total
FROM empresa2.TB_PIPELINE_VENDAS AS A, empresa2.TB_VENDEDORES AS B
WHERE A.sales_agent = B.sales_agent
AND A.deal_stage = "Won"
GROUP BY B.regional_office, A.sales_agent WITH ROLLUP;

# Gerente, escritório regional, cliente, número de vendas e os sub-totais do número de vendas 
# Apenas para as vendas concluídas com sucesso
SELECT COALESCE(A.manager, "Total") AS Gerente,
       COALESCE(A.regional_office, "Total") AS "Escritório Regional",
       COALESCE(B.account, "Total") AS Cliente,
       COUNT(B.close_value) AS numero_vendas
FROM empresa2.TB_VENDEDORES AS A, empresa2.TB_PIPELINE_VENDAS AS B
WHERE (B.sales_agent = A.sales_agent)
AND deal_stage = "Won"
GROUP BY A.manager, A.regional_office, B.account WITH ROLLUP;

# Com CTE
WITH temp_table AS 
(
SELECT A.manager,
       A.regional_office,
       B.account,
       B.deal_stage
FROM empresa2.TB_VENDEDORES AS A, empresa2.TB_PIPELINE_VENDAS AS B
WHERE (B.sales_agent = A.sales_agent)
)
SELECT COALESCE(manager, "Total") AS Gerente, 
       COALESCE(regional_office, "Total") AS "Escritório Regional",
       COALESCE(account, "Total") AS Cliente,
       COUNT(*) AS numero_vendas
FROM temp_table
WHERE deal_stage = "Won"
GROUP BY manager, regional_office, account WITH ROLLUP;

# Clientes

CREATE TABLE cap08.TB_CLIENTES_LOC (
  nome_cliente text,
  faturamento double DEFAULT NULL,
  numero_funcionarios int DEFAULT NULL
);

CREATE TABLE cap08.TB_CLIENTES_INT (
  nome_cliente text,
  faturamento double DEFAULT NULL,
  numero_funcionarios int DEFAULT NULL,
  localidade_sede text
);

# Dados carregados no MySQL Workbench

SELECT * FROM empresa2.TB_CLIENTES_LOC;
SELECT * FROM empresa2.TB_CLIENTES_INT;

# Retornando todos os clientes e suas localidades. Clientes locais estão nos EUA.
SELECT A.nome_cliente, A.localidade_sede AS localidade_sede
FROM empresa2.TB_CLIENTES_INT AS A
UNION
SELECT B.nome_cliente, "USA" AS localidade_sede
FROM empresa2.TB_CLIENTES_LOC AS B;

# Média de faturamento por localidade
# Resultado ordenado pela média de faturamento
SELECT ROUND(AVG(A.faturamento),2) AS media_faturamento, A.localidade_sede AS localidade_sede
FROM empresa2.TB_CLIENTES_INT AS A
GROUP BY localidade_sede
UNION
SELECT ROUND(AVG(B.faturamento),2) AS media_faturamento, "USA" AS localidade_sede
FROM empresa2.TB_CLIENTES_LOC AS B
GROUP BY localidade_sede
ORDER BY media_faturamento;