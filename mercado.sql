/*Criar um banco de dados de produtos onde podemos realizar as seguintes operações:
1 - Armazenar produto
2 - Atualizar produto
3 - Deletar um produto
3 - Visualizar produtos
4 - Registrar vendas
5 - Visualizar vendas
6 - Calcular lucro
*/

/*criando o banco*/
CREATE DATABASE mercado;

/*selecionando o banco*/
USE mercado;

/*Tabelas*/

CREATE TABLE categorias(
	id INTEGER AUTO_INCREMENT,
	nome VARCHAR(30),
	PRIMARY KEY(id)
);

CREATE TABLE produtos(
	codigo INTEGER AUTO_INCREMENT,
	nome VARCHAR(50),
	categoria_id INTEGER,
	pcusto DOUBLE,
	pvenda DOUBLE,
	PRIMARY KEY(codigo),
	FOREIGN KEY(categoria_id) REFERENCES categorias(id)
);

CREATE TABLE carrinhos(
	id INTEGER AUTO_INCREMENT,
	status_carrinho VARCHAR(15),
	PRIMARY KEY(id)
);

CREATE TABLE vendas(
	id INTEGER AUTO_INCREMENT,
	produto_nome VARCHAR(50),
	categoria_nome VARCHAR(30),
	carrinho_id INTEGER,
	pvenda DOUBLE,
	pcusto DOUBLE,
	unidades INTEGER,
	dt_criacao DATETIME,
	PRIMARY KEY(id)
);

/*procedures*/

DELIMITER $$

CREATE PROCEDURE insert_produto(nome_produto VARCHAR(50), id_categoria INTEGER, preco_venda DOUBLE, preco_custo DOUBLE)
BEGIN

	SET @produto_existe = (SELECT COUNT(*) FROM produtos WHERE nome = nome_produto);
	
	IF(@produto_existe)THEN
	
		SET @categoria_existe = (SELECT COUNT(*) FROM categorias WHERE id = id_categoria);
		
		IF(@categoria_existe)THEN
		
			INSERT INTO produtos(nome, categoria_id, pvenda, pcusto)
				VALUES(nome_produto, id_categoria, preco_venda, preco_custo);
				
				SELECT "Produto cadastrado com sucesso!" AS MSG;
		
		ELSE
		
			SELECT "Erro, categoria inválida!" AS MSG;
		
		END IF;
	
	ELSE
	
		SELECT "Erro, esse nome já está registrado!" AS MSG;
	
	END IF;

END $$

CREATE PROCEDURE novo_carrinho()
BEGIN

	INSERT INTO carrinhos(status_carrinho)
		VALUES("aberto");
		
	SET = @id_carrinho = (SELECT MAX(id) FROM carrinhos);
	
	SELECT CONCAT("Id do carrinho: ", @id_carrinho) AS MSG;

END $$

DELIMITER ;

/*inserindo dados básicos*/

INSERT INTO categorias(nome)
	VALUES('Alimentos'),('Bebidas'),('Higiene'),('Limpeza');


