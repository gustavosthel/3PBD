-- Criacão das tabelas

-- Tabela USUARIO
CREATE TABLE USUARIO (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    documento VARCHAR(20) NOT NULL
);

-- Tabela QUARTO
CREATE TABLE QUARTO (
    id_quarto INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50),
    capacidade INT NOT NULL CHECK (capacidade IN (4, 8, 12)),
    tem_banheiro BOOLEAN NOT NULL
);

-- Tabela VAGA
CREATE TABLE VAGA (
    id_vaga INT AUTO_INCREMENT PRIMARY KEY,
    id_quarto INT NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    posicao VARCHAR(50) NOT NULL, -- Ex: 'beliche superior'
    caracteristicas TEXT NOT NULL, -- Ex: 'perto da janela, sol da manhã'
    preco_diaria DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_quarto) REFERENCES QUARTO(id_quarto)
);

-- Tabela RESERVA
CREATE TABLE RESERVA (
    id_reserva INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_vaga INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    status ENUM('confirmada', 'cancelada') DEFAULT 'confirmada',
    valor_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    FOREIGN KEY (id_vaga) REFERENCES VAGA(id_vaga),
    CHECK (data_inicio < data_fim)
);

-- Tabela PAGAMENTO
CREATE TABLE PAGAMENTO (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva INT UNIQUE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    dados_cartao VARCHAR(255) NOT NULL, -- Criptografado na aplicação
    status ENUM('aprovado', 'pendente', 'recusado') DEFAULT 'pendente',
    data_pagamento DATETIME NOT NULL,
    FOREIGN KEY (id_reserva) REFERENCES RESERVA(id_reserva)
);



-- CRUD (Insert)

-- USUARIO
INSERT INTO USUARIO (nome, email, telefone, documento) 
VALUES ('João Silva', 'joao@email.com', '21999999999', '12345678900');

-- QUARTO
INSERT INTO QUARTO (nome, capacidade, tem_banheiro) 
VALUES ('Sol Nascente', 4, TRUE);

-- VAGA
INSERT INTO VAGA (id_quarto, descricao, posicao, caracteristicas, preco_diaria) 
VALUES (1, 'Cama individual', 'superior', 'perto da janela, sol da manhã', 50.00);

-- RESERVA
INSERT INTO RESERVA (id_usuario, id_vaga, data_inicio, data_fim, valor_total) 
VALUES (1, 1, '2025-07-01', '2025-07-05', 200.00);

-- PAGAMENTO
INSERT INTO PAGAMENTO (id_reserva, valor, dados_cartao, status, data_pagamento) 
VALUES (1, 200.00, 'TOKEN_XYZ123', 'aprovado', NOW());


-- CRUD (Update)

-- USUARIO
UPDATE USUARIO SET telefone = '21888888888' WHERE id_usuario = 1;

-- RESERVA (cancelar)
UPDATE RESERVA SET status = 'cancelada' 
WHERE id_reserva = 1 AND data_inicio > CURDATE() + INTERVAL 3 DAY;

-- PAGAMENTO
UPDATE PAGAMENTO SET status = 'recusado' WHERE id_pagamento = 1;


-- CRUD (Delete)

-- PAGAMENTO
DELETE FROM PAGAMENTO WHERE id_pagamento = 1;

-- RESERVA
DELETE FROM RESERVA WHERE id_reserva = 1 AND status = 'cancelada';

-- USUARIO
DELETE FROM USUARIO WHERE id_usuario = 1;

-- CRUD (Select)

SELECT * FROM USUARIO;
SELECT * FROM QUARTO;
SELECT * FROM VAGA;
SELECT * FROM RESERVA;
SELECT * FROM PAGAMENTO;


-- CRUD (Select um)

-- Por ID
SELECT * FROM USUARIO WHERE id_usuario = 1;
SELECT * FROM RESERVA WHERE id_reserva = 1;

-- Vagas com banheiro
SELECT * FROM VAGA 
WHERE id_quarto IN (SELECT id_quarto FROM QUARTO WHERE tem_banheiro = TRUE);

-- Reservas ativas
SELECT * FROM RESERVA 
WHERE status = 'confirmada' AND data_fim > CURDATE();


DELIMITER //

CREATE PROCEDURE VagasDisponiveis(
    IN p_data_inicio DATE,
    IN p_data_fim DATE,
    IN p_tem_banheiro BOOLEAN
)
BEGIN
    -- Vagas disponíveis no período
    SELECT 
        V.id_vaga,
        V.descricao,
        V.posicao,
        V.caracteristicas,
        V.preco_diaria,
        Q.nome AS quarto,
        Q.capacidade
    FROM VAGA V
    JOIN QUARTO Q ON V.id_quarto = Q.id_quarto
    WHERE 
        Q.tem_banheiro = p_tem_banheiro
        AND V.id_vaga NOT IN (
            SELECT R.id_vaga
            FROM RESERVA R
            WHERE 
                R.status = 'confirmada'
                AND NOT (
                    R.data_fim <= p_data_inicio 
                    OR R.data_inicio >= p_data_fim
                )
        );
    
    -- Camas reservadas no período
    SELECT 
        V.id_vaga,
        R.data_inicio,
        R.data_fim,
        U.nome AS usuario
    FROM RESERVA R
    JOIN VAGA V ON R.id_vaga = V.id_vaga
    JOIN USUARIO U ON R.id_usuario = U.id_usuario
    WHERE 
        R.status = 'confirmada'
        AND NOT (
            R.data_fim <= p_data_inicio 
            OR R.data_inicio >= p_data_fim
        );
END //

DELIMITER ;