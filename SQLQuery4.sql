USE exercicio2;
GO

DROP TABLE IF EXISTS locacao;
DROP TABLE IF EXISTS filme_estrela;
DROP TABLE IF EXISTS dvd;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS estrela;
DROP TABLE IF EXISTS filme;
GO

CREATE TABLE filme (
	id INT IDENTITY(1001,1) NOT NULL,
	titulo VARCHAR(80) NOT NULL,
	ano INT NULL CHECK (ano <= 2021),
	PRIMARY KEY (id)
);
GO

CREATE TABLE estrela (
	id INT IDENTITY(9901,1) NOT NULL,
	nome VARCHAR(50) NOT NULL,
	nome_real VARCHAR(50) NULL,
	PRIMARY KEY (id)
);
GO

CREATE TABLE dvd (
	num INT IDENTITY(10001,1) NOT NULL,
	data_fabricacao DATE NOT NULL CHECK (data_fabricacao < CAST(GETDATE() AS DATE)),
	filme_id INT NOT NULL,
	PRIMARY KEY (num),
	FOREIGN KEY (filme_id) REFERENCES filme(id)
);
GO

-- Ajustado para IDENTITY(5501,1) para bater com os códigos da locação
CREATE TABLE cliente (
	num_cadastro INT IDENTITY(5501,1) NOT NULL,
	nome VARCHAR(70) NOT NULL,
	logradouro VARCHAR(150) NOT NULL,
	num INT NOT NULL CHECK (num > 0),
	cep CHAR(8) NULL CHECK (LEN(cep) = 8),
	PRIMARY KEY (num_cadastro)	
);
GO

CREATE TABLE filme_estrela (
	filme_id INT NOT NULL,
	estrela_id INT NOT NULL,
	PRIMARY KEY (filme_id, estrela_id),
	FOREIGN KEY (filme_id) REFERENCES filme(id),
	FOREIGN KEY (estrela_id) REFERENCES estrela(id)
);
GO

CREATE TABLE locacao (
	data_locacao DATE NOT NULL DEFAULT (GETDATE()),
	data_devolucao DATE NOT NULL,
	valor DECIMAL(7,2) NOT NULL CHECK (valor > 0),
	DVDnum INT NOT NULL,
	clientenum_cadastro INT NOT NULL,
	PRIMARY KEY (data_locacao, DVDnum, clientenum_cadastro),
	FOREIGN KEY (DVDnum) REFERENCES dvd(num),
	FOREIGN KEY (clientenum_cadastro) REFERENCES cliente(num_cadastro),
	CHECK (data_locacao <= data_devolucao)
);
GO

INSERT INTO filme (titulo, ano) VALUES
('Whiplash', 2015),
('Birdman', 2015),
('Interestelar', 2014),
('A Culpa é das estrelas', 2014),
('Alexandre e o Dia Terrível, Horrível, Espantoso e Horroroso', 2014),
('Sing', 2016);

INSERT INTO estrela (nome, nome_real) VALUES
('Michael Keaton', 'Michael John Douglas'),
('Emma Stone', 'Emily Jean Stone'),
('Miles Teller', NULL),
('Steve Carell', 'Steven John Carell'),
('Jennifer Garner', 'Jennifer Anne Garner');

INSERT INTO filme_estrela (filme_id, estrela_id) VALUES
(1002, 9901),
(1002, 9902),
(1001, 9903),
(1005, 9904),
(1005, 9905);

INSERT INTO dvd (data_fabricacao, filme_id) VALUES
('2020-12-02', 1001),
('2019-10-18', 1002),
('2020-04-03', 1003),
('2020-12-02', 1001),
('2019-10-18', 1004),
('2020-04-03', 1002),
('2020-12-02', 1005),
('2019-10-18', 1002),
('2020-04-03', 1003);

INSERT INTO cliente (nome, logradouro, num, cep) VALUES
('Matilde Luz', 'Rua Síria', 150, '03086040'),
('Carlos Carreiro', 'Rua Bartolomeu Aires', 1250, '04419110'),
('Daniel Ramalho', 'Rua Itajatiba', 169, NULL),
('Roberta Bento', 'Rua Jayme Von Rosenburg', 36, NULL),
('Rosa Cerqueira', 'Rua Arnaldo Simões Pinto', 235, '02917110');

INSERT INTO locacao (data_locacao, data_devolucao, valor, DVDnum, clientenum_cadastro) VALUES
('2021-02-18', '2021-02-21', 3.50, 10001, 5502),
('2021-02-18', '2021-02-21', 3.50, 10009, 5502),
('2021-02-18', '2021-02-19', 3.50, 10002, 5503),
('2021-02-20', '2021-02-23', 3.00, 10002, 5505),
('2021-02-20', '2021-02-23', 3.00, 10004, 5505),
('2021-02-20', '2021-02-23', 3.00, 10005, 5505),
('2021-02-24', '2021-02-26', 3.50, 10001, 5501),
('2021-02-24', '2021-02-26', 3.50, 10008, 5501);
GO

UPDATE cliente
SET cep= CASE num_cadastro
	WHEN 5503 THEN '08411150'
	WHEN 5504 THEN '02918190'
END 
WHERE num_cadastro IN(5503,5504);
GO

UPDATE locacao
SET valor=3.25
WHERE clientenum_cadastro = 5502
	AND data_locacao ='2021-02-18'
GO

UPDATE locacao
SET valor=3.10
WHERE clientenum_cadastro = 5501
	AND data_locacao = '2021-02-24'
GO

UPDATE dvd
SET data_fabricacao= '2019-07-14'
WHERE num = 10005;
GO

UPDATE estrela
SET nome_real = 'Miles Alexander Teller'
WHERE nome = 'Miles Teller';
GO

DELETE FROM filme
WHERE titulo='Sing';
GO

SELECT DISTINCT
	f.id AS id,
	f.ano AS ano,
	CASE
		WHEN LEN(f.titulo) > 10 THEN SUBSTRING(f.titulo, 1, 10) + '...'
		ELSE f.titulo
	END AS nome_filme
FROM filme f
INNER JOIN dvd d ON f.id = d.filme_id
WHERE d.data_fabricacao > '2020-01-01';
GO

SELECT DISTINCT 
	d.num, d.data_fabricacao,
	DATEDIFF(MONTH, d.data_fabricacao, GETDATE())AS qtd_meses
FROM dvd d
INNER JOIN filme f ON d.filme_id= f.id
WHERE f.titulo = 'Interestelar';
GO

SELECT 
	l.DVDnum AS num_dvd,
	l.data_locacao, l.data_devolucao, 
	DATEDIFF(DAY, l.data_locacao, l.data_devolucao)AS dias_alugados,
	l.valor
FROM locacao l
INNER JOIN cliente c ON l.clientenum_cadastro = c.num_cadastro
WHERE c.nome LIKE  '%Rosa%';
GO

SELECT DISTINCT
c.nome AS nome,
c.logradouro +','+CAST(c.num AS VARCHAR(10)) AS endereço_completo,
SUBSTRING (c.cep,1, 5)+'-'+SUBSTRING(c.cep,6,3)AS CEP
FROM cliente c
INNER JOIN locacao l ON c.num_cadastro = l.clientenum_cadastro
WHERE l.DVDnum = 10002;
GO

-- 3. Conferência dos resultados
SELECT * FROM filme;
SELECT * FROM estrela;
SELECT * FROM filme_estrela;
SELECT * FROM dvd;
SELECT * FROM cliente;
SELECT * FROM locacao;