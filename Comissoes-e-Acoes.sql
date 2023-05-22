ALTER TABLE `empresa2`.`vendas` 
ADD COLUMN `comissao` DECIMAL(10,2) NULL AFTER `valor_venda`;

SET SQL_SAFE_UPDATES = 0;

UPDATE empresa2.vendas 
SET comissao = 5
WHERE empID = 1;

UPDATE empresa2.vendas 
SET comissao = 6
WHERE empID = 2;

UPDATE empresa2.vendas 
SET comissao = 8
WHERE empID = 3;

SET SQL_SAFE_UPDATES = 1;

# Transformação de atributos e Parsing

# Calculando o valor da comissão a ser pago para cada funcionário
SELECT empID, ROUND((valor_venda * comissao) / 100, 0) AS valor_comissao
FROM empresa2.vendas;

# Valor pago ao funcionário de empID 1 se a comissão for igual a 15%
SELECT empID, GREATEST(15, comissao) AS comissao
FROM empresa2.vendas
WHERE empID = 1;

SELECT empID, ROUND((valor_venda * GREATEST(15, comissao)) / 100, 0) AS valor_comissao
FROM empresa2.vendas
WHERE empID = 1;

# Valor pago ao funcionário de empID 1 se a comissão for igual a 2%
SELECT empID, LEAST(2, comissao) AS comissao
FROM empresa2.vendas
WHERE empID = 1;

SELECT empID, ROUND((valor_venda * LEAST(2, comissao)) / 100, 0) AS valor_comissao
FROM empresa2.vendas
WHERE empID = 1;

# Vendedores separados em categorias
# De 2 a 5 de comissão = Categoria 1
# De 5.1 a 7.9 = Categoria 2
# Igual ou acima de 8 = Categoria 3
SELECT 
  empID,
  valor_venda,
  CASE 
   WHEN comissao BETWEEN 2 AND 5 THEN 'Categoria 1'
   WHEN comissao BETWEEN 5.1 AND 7.9 THEN 'Categoria 2'
   WHEN comissao >= 8 THEN 'Categoria 3' 
  END AS 'Categoria'
FROM empresa2.vendas;

# Parsing

ALTER TABLE `empresa2`.`vendas` 
ADD COLUMN `data_venda` DATETIME NULL AFTER `comissao`;

SET SQL_SAFE_UPDATES = 0;

UPDATE empresa2.vendas 
SET data_venda = '2022-03-15'
WHERE empID = 1;

UPDATE empresa2.vendas
SET data_venda = '2022-03-16'
WHERE empID = 2;

UPDATE empresa2.vendas
SET data_venda = '2022-03-17'
WHERE empID = 3;

SET SQL_SAFE_UPDATES = 1;

SELECT empID, valor_venda, comissao, data_venda, DATE_FORMAT(data_venda, '%d-%b-%Y') AS data_venda_p
FROM empresa2.vendas;

# Transformação de dados

CREATE TABLE empresa2.acoes (dia INT, num_vendas INT, valor_acao DECIMAL(10,2));

INSERT INTO empresa2.acoes VALUES
(1, 32, 0.3),
(1, 4, 70),
(1, 44, 200),
(1, 9, 0.01),
(1, 8, 0.03),
(1, 41, 0.03),
(2, 52, 0.4),
(2, 10, 70),
(2, 53, 200),
(2, 5, 0.01),
(2, 25, 0.55),
(2, 7, 50);

# Se o valor_acao for entre 0 e 10, queremos o maior num_vendas desse range = Grupo 1
# Se o valor_acao for entre 10 e 100, queremos o maior num_vendas desse range = Grupo 2
# Se o valor_acao for maior que 100, queremos o maior num_vendas desse range = Grupo 3
SELECT dia,
  MAX(CASE WHEN valor_acao BETWEEN 0 AND 9 THEN num_vendas ELSE 0 END) AS 'Grupo 1',
  MAX(CASE WHEN valor_acao BETWEEN 10 AND 99 THEN num_vendas ELSE 0 END) AS 'Grupo 2',
  MAX(CASE WHEN valor_acao > 100 THEN num_vendas ELSE 0 END) AS 'Grupo 3'
FROM empresa2.acoes
GROUP BY dia;