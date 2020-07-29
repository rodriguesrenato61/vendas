/*Criar um banco de dados de um mercado onde podemos realizar as seguintes operações:
1 - Armazenar produto:
Insere um novo produto no banco de dados com os atributos: codigo, nome, categoria, preço de custo, preço de venda e estoque.
2 - Atualizar dados do produto.
3 - Deletar um produto.
4 - Visualizar dados dos produtos.
5 - Criar carrinho de compras:
Insere um novo carrinho no banco de dados com os atributos: id e status padrão como em andamento.
6 - Registrar vendas:
Insere uma nova venda no banco de dados com os atributos: id, produto, categoria, carrinho ao qual pertence, preço de venda, preço de custo, unidades, data e hora de registro.
7 - Finalizar o carrinho:
Muda o status do carrinho para finalizado.
8 - Visualizar carrinhos:
Visualiza as informações dos carrinhos como id, status, quantidade de produtos e total da compra.
9 - Visualizar vendas:
Visualiza as informações das vendas como id, produto, categoria, preço de venda, preço de custo, unidades, total de custo, total de venda, lucro, status da venda, data e hora.
10 - Calcular total de custo de todas as vendas.
11 - Calcular total de vendas de totas as vendas.
12 - Calcular total de lucro de todas as vendas.
*/

/*criando o banco*/
CREATE DATABASE mercado;

/*selecionando o banco*/
USE mercado;

/*Tabelas*/

/*Tabela categorias
Armazena as categorias dos produtos*/
CREATE TABLE categorias(
	id INTEGER NOT NULL AUTO_INCREMENT,
	nome VARCHAR(30) NOT NULL,
	PRIMARY KEY(id)
);
/*id: chave primária,
nome: nome da categoria*/

/*Tabela produtos
Armazena os dados dos produtos*/
CREATE TABLE produtos(
	codigo INTEGER NOT NULL AUTO_INCREMENT,
	nome VARCHAR(50) NOT NULL,
	fk_categoria INTEGER NOT NULL,
	pcusto DOUBLE NOT NULL,
	pvenda DOUBLE NOT NULL,
	estoque INTEGER DEFAULT 0 NOT NULL,
	PRIMARY KEY(codigo),
	FOREIGN KEY(fk_categoria) REFERENCES categorias(id)
);
/*codigo: chave primária,
nome: nome do produto,
fk_categoria: chave estrangeira para referenciar a categoria do produto,
pcusto: preço de custo,
pvenda: preço de venda
estoque: estoque do produto*/

/*Tabela carrinhos
Armazena os carrinhos onde os produtos são colocados*/
CREATE TABLE carrinhos(
	id INTEGER NOT NULL AUTO_INCREMENT,
	status_carrinho VARCHAR(15),
	PRIMARY KEY(id)
);
/*id: chave primária,
status_carrinho: status do carrinho (em andamento ou finalizado)*/

/*Tabela vendas
Armazena os registros das vendas dos produtos*/
CREATE TABLE vendas(
	id INTEGER NOT NULL AUTO_INCREMENT,
	produto_nome VARCHAR(50) NOT NULL,
	categoria_nome VARCHAR(30) NOT NULL,
	fk_carrinho INTEGER NOT NULL,
	pvenda DOUBLE NOT NULL,
	pcusto DOUBLE NOT NULL,
	unidades INTEGER NOT NULL,
	dt_criacao DATETIME NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY(fk_carrinho) REFERENCES carrinhos(id)
);
/*id: chave primária do registro,
produto_nome: nome do produto,
categoria_nome: categoria do produto,
fk_carrinho: carrinho ao qual o produto pertence,
pvenda: preço de venda do produto,
pcusto: preço de custo do produto,
unidades: quantidade vendida do produto,
dt_criacao: data e hora de realização da venda*/

/*Functions*/

DELIMITER $$

/*Function count_produtos:
Conta a quantidade de produtos de determinado carrinho*/
CREATE FUNCTION count_produtos(id_carrinho INTEGER)
RETURNS INTEGER
RETURN (SELECT SUM(unidades) FROM vendas WHERE fk_carrinho = id_carrinho);/*Contando a quantidade de produtos nesse carrinho*/

/*Function total:
Calcula valor total ds produtos do carrinho*/
CREATE FUNCTION total(id_carrinho INTEGER)
RETURNS DOUBLE
BEGIN

	SET @valor_total = (SELECT SUM(unidades * pvenda) FROM vendas WHERE fk_carrinho = id_carrinho);/*calculando o valor total do carrinho*/

	RETURN @valor_total;
END $$

/*Function status_venda:
Mostra o status da venda de acordo com o status do carrinho*/
CREATE FUNCTION status_venda(id_carrinho INTEGER)
RETURNS VARCHAR(10)
BEGIN

    SET @carrinho_status = (SELECT status_carrinho FROM carrinhos WHERE id = id_carrinho);/*pega o status do carrinho*/

    IF(@carrinho_status = "Em andamento")THEN/*se o status for em andamento*/

        SET @retorno = "Não pago";

    END IF;/*fim se o status for em andamento*/

    IF(@carrinho_status = "Finalizado")THEN/*se o status for finalizado*/

        SET @retorno = "Pago";

    END IF;/*fim se o status for finalizado*/

    RETURN @retorno;
END $$

/*Procedures*/

/*Procedure insert_produto:
Cadastra um novo produto no banco de dados*/
CREATE PROCEDURE insert_produto(nome_produto VARCHAR(50), id_categoria INTEGER, preco_custo DOUBLE, preco_venda DOUBLE, estoque_produto INTEGER)
BEGIN

	INSERT INTO produtos(nome, fk_categoria, pvenda, pcusto, estoque)
			VALUES(nome_produto, id_categoria, preco_venda, preco_custo, estoque_produto);/*cadastrando o produto*/

END $$

/*Procedure update_produto:
Atualiza as informações de determinado produto*/
CREATE PROCEDURE update_produto(cod_produto INTEGER, nome_produto VARCHAR(50), id_categoria INTEGER, preco_custo DOUBLE, preco_venda DOUBLE, estoque_produto INTEGER)
BEGIN

	UPDATE produtos SET nome = nome_produto, fk_categoria = id_categoria, pvenda = preco_venda, pcusto = preco_custo, estoque = estoque_produto WHERE codigo = cod_produto;/*atualizando os dados do produto*/

END $$

/*Procedure delete_produto:
Deleta um determinado produto do banco de dados*/
CREATE PROCEDURE delete_produto(cod_produto INTEGER)
BEGIN

	DELETE FROM produtos WHERE codigo = cod_produto;/*deletando o produto do banco*/

END $$

/*Procedure novo_carrinho:
Cria um novo carrinho no banco de dados*/
CREATE PROCEDURE novo_carrinho()
BEGIN

	INSERT INTO carrinhos(status_carrinho)
		VALUES("Em andamento");
		
	SET @id_carrinho = LAST_INSERT_ID();
	
	SELECT CONCAT("Id do carrinho: ", @id_carrinho) AS MSG;

END $$

/*Procedure registrar_venda:
Registra venda de determinado produto em determinado carrinho*/
CREATE PROCEDURE registrar_venda(id_carrinho INTEGER, cod_produto INTEGER, quantidade INTEGER)
BEGIN

	SET @carrinho_status = (SELECT status_carrinho FROM carrinhos WHERE id = id_carrinho);/*pegando o status do carrinho*/
	
	IF(@carrinho_status = "Em andamento")THEN/*se o carrinho estiver em andamento*/
	
		SET @carrinho_valido = 1;
		
	ELSE/*se o carrinho estiver finalizado*/
	
		SET @carrinho_valido = 0;
		
		SELECT "Erro, este carrinho já está finalizado!" AS MSG;
		
	END IF;/*fim se o carrinho estiver em andamento*/

	SET @produto_estoque = (SELECT estoque FROM produtos WHERE codigo = cod_produto);/*pega o estoque do produto*/
		
	IF(quantidade <= @produto_estoque)THEN/*se a quantidade a ser vendida for menor igual ao estoque do produto*/
		
		SET @quantidade_valida = 1;
		
	ELSE/*se não for*/
		
		SET @quantidade_valida = 0;
			
		SELECT "Erro, quantidade maior que o estoque disponível!" AS MSG;
		
	END IF;/*fim se o estoque é suficiente*/
	
	IF(@quantidade_valida AND @carrinho_valido)THEN/*se todos os dados são válidos*/
	
		SET @nome_produto = (SELECT nome FROM produtos WHERE codigo = cod_produto);/*pega o nome do produto*/
	
		SET @venda_id = (SELECT id FROM vendas WHERE produto_nome = @nome_produto AND fk_carrinho = id_carrinho);/*pega o id da venda em que esse produto está registrado nesse carrinho se houver*/
		
		IF(@venda_id)THEN/*se esse produto já está no carrinho*/
		
			UPDATE vendas SET unidades = unidades + quantidade WHERE id = @venda_id;/*atualizando o registro de venda*/
		
		ELSE/*se esse produto não está no carrinho*/
		
			SET @id_categoria = (SELECT fk_categoria FROM produtos WHERE codigo = cod_produto);/*pegando o id da categoria do produto*/
		
			SET @nome_categoria = (SELECT nome FROM categorias WHERE id = @id_categoria);/*pegando o nome da categoria*/
		
			SET @pvenda = (SELECT pvenda FROM produtos WHERE codigo = cod_produto);/*pegando o preço de venda*/
		
			SET @pcusto = (SELECT pcusto FROM produtos WHERE codigo = cod_produto);/*pegando o preço de custo*/
		
			INSERT INTO vendas(produto_nome, categoria_nome, pvenda, pcusto, unidades, fk_carrinho, dt_criacao)
				VALUES(@nome_produto, @nome_categoria, @pvenda, @pcusto, quantidade, id_carrinho, NOW());/*registrando venda*/
					
		END IF;/*fim se esse produto já está no carrinho*/
		
			UPDATE produtos SET estoque = estoque - quantidade WHERE codigo = cod_produto;/*atualizando o estoque do produto*/
		
			SELECT CONCAT("Venda de ", quantidade," unidade(s) do produto ", @nome_produto, " registrada com sucesso!") AS MSG;

	ELSE/*se nem todos os dados são válidos*/
	
		SELECT "Erro ao registrar venda!" AS MSG;
	
	END IF;/*fim se nem todos os dados são válidos*/ 

END $$

/*Procedure fechar_carrinho:
Muda o status de um carrinho aberto para fechado*/
CREATE PROCEDURE fechar_carrinho(id_carrinho INTEGER)
BEGIN

	UPDATE carrinhos SET status_carrinho = "Finalizado" WHERE id = id_carrinho;/*fechando o carrinho*/

END $$

DELIMITER ;

/*Views*/

/*vw_produtos*/
CREATE VIEW vw_produtos AS SELECT codigo, produtos.nome AS produto, fk_categoria AS categoria_id, categorias.nome AS categoria, pcusto, pvenda, estoque FROM produtos
INNER JOIN categorias ON fk_categoria = categorias.id;

/*vw_carrinhos*/
CREATE VIEW vw_carrinhos AS SELECT carrinhos.id AS id, count_produtos(carrinhos.id) AS produtos, status_carrinho, total(carrinhos.id) AS total_compra FROM carrinhos;

/*vw_vendas*/
CREATE VIEW vw_vendas AS SELECT vendas.id AS id, produto_nome AS produto, categoria_nome AS categoria, fk_carrinho AS carrinho_id, pvenda, pcusto, unidades, (unidades * pcusto) AS total_custo, (unidades * pvenda) AS total_venda, ((unidades * pvenda) - (unidades * pcusto)) AS lucro, status_venda(fk_carrinho) AS venda_status, DATE(dt_criacao) AS data_venda, TIME(dt_criacao) AS hora FROM vendas;

/*inserindo dados básicos*/

INSERT INTO categorias(nome)
	VALUES('Alimentos'),('Bebidas'),('Higiene'),('Limpeza');

/*inserindo produtos para teste*/

CALL insert_produto('Margarina', 1, 2.00, 4.50, 20);
CALL insert_produto('Óleo', 1, 1, 2, 20);
CALL insert_produto('Creme de Leite', 1, 1.25, 2.75, 20);
CALL insert_produto('Maionese', 1, 2, 4, 20);
CALL insert_produto('Extrato de Tomate', 1, 1, 1.75, 20);
CALL insert_produto('Refrigerante', 2, 2.00, 3.75, 20);
CALL insert_produto('Água Mineral', 2, 0.90, 2, 20);
CALL insert_produto('Cerveja', 2, 2.00, 5, 20);
CALL insert_produto('Suco Pronto', 2, 2.00, 4.5, 20);
CALL insert_produto('Chá Pronto', 2, 1.25, 3, 20);
CALL insert_produto('Shampoo', 3, 2.00, 4.75, 20);
CALL insert_produto('Creme Dental', 3, 1.00, 2, 20);
CALL insert_produto('Desodorante', 3, 2.25, 4.5, 20);
CALL insert_produto('Sabonete', 3, 0.40, 1.25, 20);
CALL insert_produto('Papel Higiênico', 3, 0.50, 1.5, 20);
CALL insert_produto('Sabão em Pedra', 4, 0.75, 1.55, 20);
CALL insert_produto('Detergente Líquido', 4, 0.80, 1.85, 20);
CALL insert_produto('Amaciante', 4, 1.15, 3.25, 20);
CALL insert_produto('Água Sanitária', 4, 1.00, 2.35, 20);
CALL insert_produto('Esponja Sintética', 4, 0.50, 1.25, 20);
CALL insert_produto('Sardinha em Lata', 1, 1.25, 2.75, 20);
CALL insert_produto('Macarrão', 1, 0.80, 1.75, 20);

/*inserindo carrinho para testes*/

CALL novo_carrinho();
CALL registrar_venda(1, 1, 3);
CALL registrar_venda(1, 5, 1);
CALL registrar_venda(1, 12, 2);
CALL registrar_venda(1, 4, 4);
CALL registrar_venda(1, 5, 3);
CALL registrar_venda(1, 15, 5);
CALL fechar_carrinho(1);
CALL novo_carrinho();
CALL registrar_venda(2, 10, 3);
CALL registrar_venda(2, 3, 5);
CALL registrar_venda(2, 1, 2);
CALL registrar_venda(2, 18, 7);
CALL registrar_venda(2, 15, 2);
CALL registrar_venda(2, 10, 5);

/*Retornando resultados*/

/*Exibindo total de custo, total de vendas e lucro total recebidos*/
SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Pago";

/*Exibindo total de custo, total de vendas e lucro total não recebidos*/
SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Não pago";

/*Filtrando pelas datas*/
SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Pago" AND data_venda BETWEEN "2020-02-01" AND "2020-02-20";


/*Testando procedures*/

CALL update_produto(4, "Condicionador", 3, 2.15, 4.75, 32);

CALL delete_produto(4);
