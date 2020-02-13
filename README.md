# Banco de dados MySQL para vendas de produtos
Confira o código fonte no arquivo mercado2.sql.

![estrutura](https://github.com/rodriguesrenato61/vendas/blob/master/prints/estrutura2.png)

Banco de dados para venda de produtos com diversas operações:

## 1 - Armazenar produto

Insere um novo produto no banco de dados com os atributos: codigo, nome, categoria, preço de custo, preço de venda e estoque. Para isso utilizamos a procedure insert_produto.
### Exemplo
CALL insert_produto(nome do produto, id da categoria do produto, preço de custo, preço de venda, estoque);
### Utilizando
CALL insert_produto("Condicionador", 3, 2.15, 4.75, 26);

## 2 - Atualizar dados do produto

Para isso utilizamos a procedure update_produto.
### Exemplo
CALL update_produto(código do produto, nome, id da categoria, preço de custo, preço de venda, estoque);
### Utilizando
CALL update_produto(4, "Maionese", 1, 1.75, 3.25, 20);

## 3 - Deletar um produto

Para isso utilizamos a procedure delete_poduto.
### Exemplo
CALL delete_produto(código do produto);
### Utilizando
CALL delete_produto(2);

## 4 - Visualizar dados dos produtos

Utiliza a view de produtos a vw_produtos para a visualizaçao do código, nome, categoria_id, categoria, preço de custo, preço de venda e estoque.
### SELECT * FROM vw_produtos;

![vw_produtos](https://github.com/rodriguesrenato61/vendas/blob/master/prints/vw_produtos.png)

## 5 - Criar carrinho de compras

Insere um novo carrinho no banco de dados com os atributos: id e status padrão como em andamento. Para isso utilizamos a procedure novo_carrinho que irá nos mostrar o id do novo carrinho.
### Exemplo
CALL novo_carrinho();
### Resultado
Id do carrinho: 8

## 6 - Registrar vendas

Insere uma nova venda no banco de dados com os atributos: id, produto, categoria, carrinho ao qual pertence, preço de venda, preço de custo, unidades, data e hora de registro. Para isso utilizamos a procedure registrar_venda.
### Exemplo
CALL registrar_venda(id do carrinho, código do produto, quantidade do produto);
### Utilizando
CALL registrar_venda(2, 3, 5);

## 7 - Finalizar o carrinho

Muda o status do carrinho para finalizado. Para isso utilizamos a procedure fechar_carrinho.
### Exemplo
CALL fechar_carrinho(id do carrinho);
### Utilizando
CALL fechar_carrinho(2);

## 8 - Visualizar carrinhos

Utiliza a view de carrinhos a vw_carrinhos para visualizar o id, status, quantidade de produtos e total da compra.
### SELECT * FROM vw_carrinhos;

![vw_carrinhos](https://github.com/rodriguesrenato61/vendas/blob/master/prints/vw_carrinhos1.png)

## 9 - Visualizar vendas

Utiliza a view de vendas a vw_vendas para visualizar o id, produto, categoria, preço de venda, preço de custo, unidades, total de custo, total de venda, lucro, status da venda, data e hora.
### SELECT * FROM vw_vendas;

![vw_vendas](https://github.com/rodriguesrenato61/vendas/blob/master/prints/vw_vendas1.png)

## 10 - Calcular total de custo, total de vendas e lucro recebidos de todas as vendas

Utiliza a view de vendas para extrair as informações dos totais de venda recebidos.
### SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Pago";

![total vendas](https://github.com/rodriguesrenato61/vendas/blob/master/prints/total_vendas_recebidos.png)

## 11 - Calcular total de custo, total de vendas e lucro não recebidos de todas as vendas

Utiliza a view de vendas para extrair as informações dos totais de venda não recebidos.
### SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Não pago";

![total vendas](https://github.com/rodriguesrenato61/vendas/blob/master/prints/total_vendas_naorecebidos.png)

Podemos também utilizar filtros nessa extração
### Filtrando pela data
SELECT SUM(total_custo) AS total_custo, SUM(total_venda) AS total_venda, SUM(lucro) AS total_lucro FROM vw_vendas WHERE venda_status = "Pago" AND data_venda BETWEEN "2020-02-01" AND "2020-02-20";


