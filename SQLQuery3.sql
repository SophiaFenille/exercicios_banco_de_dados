USE exercicio1;
GO
DROP TABLE IF EXISTS user_proj;
DROP TABLE IF EXISTS projetos;
DROP TABLE IF EXISTS usuarios;
GO

CREATE TABLE usuarios(
	id INT IDENTITY (1,1) NOT NULL,
	nome VARCHAR(200) NOT NULL,
	username VARCHAR(200) NULL,
	senha VARCHAR(45) NULL DEFAULT('123mudar'), 
	email VARCHAR(45) NOT NULL,
	PRIMARY KEY (id)
)
GO

CREATE TABLE projetos(
	id INT IDENTITY (10001,1) NOT NULL,
	nome VARCHAR(200) NOT NULL,
	descricao VARCHAR(300) NULL,
	dt DATE NOT NULL CHECK(dt>'2014-09-01'),
	PRIMARY KEY(id)
)
GO

CREATE TABLE user_proj(
	id_usuarios INT NOT NULL,
	id_projetos INT NOT NULL,
	PRIMARY KEY(id_usuarios, id_projetos),
	FOREIGN KEY (id_usuarios) REFERENCES usuarios(id),
	FOREIGN KEY (id_projetos) REFERENCES projetos(id)
)
GO

ALTER TABLE	usuarios		
ALTER COLUMN username VARCHAR(10);

ALTER TABLE usuarios
ADD CONSTRAINT UQ_usuarios_username UNIQUE(username);

ALTER TABLE usuarios
ALTER COLUMN senha VARCHAR(8);

INSERT INTO usuarios(nome,username,senha,email)VALUES
('Maria','Rh_Maria', DEFAULT,'maria@empresa.com'),
('Paulo','Ti_Paulo','123@456','paulo@empresa.com'),
('Ana','Rh_Ana',DEFAULT,'ana@empresa.com'),
('Clara','Ti_Clara',DEFAULT,'clara@empresa.com'),
('Aparecido','Rh_Aparec','55@!cido','aparecido@empresa.com');

INSERT INTO projetos(nome,descricao,dt)VALUES
('Re-folha','Refatoração das folhas','20140905'),
('Manutençaõ PCs','Manutenção PCs','20140906'),
('Auditoria',NULL,'20140907');

INSERT INTO user_proj(id_usuarios,id_projetos)VALUES
('1','10001'),
('5','10001'),
('3','10003'),
('4','10002'),
('2','10002');

SELECT * FROM usuarios;
SELECT * FROM projetos;
SELECT * FROM user_proj;

UPDATE projetos
SET dt='2014-09-12'
WHERE id=10002;

UPDATE usuarios
SET username='Rh_cido'
WHERE nome='Aparecido';

UPDATE usuarios
SET senha='888@!' --para mudar 
WHERE username='Rh_Maria' -- qual usuario
 AND senha='123mudar'; --conferir que a senha antiga era essa

DELETE FROM user_proj
WHERE id_usuarios = 2
	AND id_projetos = 10002;

SELECT id, nome, email, username,
CASE WHEN senha != '123mudar'
	THEN '*******'
	ELSE senha
END AS senha 
FROM usuarios;

SELECT 
	p.nome AS nome_projeto,
	p.descricao,
	p.dt AS data,
	DATEADD(DAY, 15, p.dt)AS data_final
FROM projetos p 
INNER JOIN user_proj up ON p.id = up.id_projetos
INNER JOIN usuarios u ON u.id = up.id_usuarios
WHERE u.email = 'aparecido@empresa.com'
	AND p.id = 10001;

SELECT 
	u.nome,
	u.email
FROM usuarios u, user_proj up, projetos p
WHERE u.id = up.id_usuarios
	AND p.id = up.id_projetos
	AND p.nome = 'Auditoria';

SELECT 
	nome, descricao, dt AS data, '2014-09-16' AS data_final,
	CAST(DATEDIFF(DAY,dt,'2014-09-16')* 79.85 AS DECIMAL (10,2))AS custo_total --conta os dias e multiplica, em decimal 
FROM projetos
WHERE nome LIKE '%Manuten%';

