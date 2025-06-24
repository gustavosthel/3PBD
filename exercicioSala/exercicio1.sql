CREATE TABLE Disciplinas (
    sigla VARCHAR(10) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargaHoraria INT NOT NULL,
    periodo INT NOT NULL,
    limiteFalta INT NOT NULL
);

CREATE TABLE Alunos (
    matricula INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL
);

-- Operações CRUD para Diciplinas

INSERT INTO Disciplinas (sigla, nome, cargaHoraria, periodo, limiteFalta)
VALUES ('MAT101', 'Matemática Básica', 60, 1, 25);

UPDATE Disciplinas
SET cargaHoraria = 75, periodo = 2
WHERE sigla = 'MAT101';

SELECT * FROM Disciplinas;

SELECT * FROM Disciplinas WHERE periodo = 1;


DELETE FROM Disciplinas WHERE sigla = 'MAT101';

-- Operações CRUD para Alunos

INSERT INTO Alunos (matricula, nome, email, cpf)
VALUES (12345, 'João Silva', 'joao@email.com', '123.456.789-00');

UPDATE Alunos
SET email = 'joao.novo@email.com'
WHERE matricula = 12345;

SELECT * FROM Alunos;

SELECT * FROM Alunos WHERE nome LIKE 'João%';

DELETE FROM Alunos WHERE matricula = 12345;