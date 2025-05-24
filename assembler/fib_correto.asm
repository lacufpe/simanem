-- Trabalho de Sistemas Digitais 2
-- Objetivo: gerar nas 20 primeiras posições da memória de dados os
-- 20 primeiros números da sequência de Fibonacci
-- Dados:
-- Fibonacci => fn = f(n-1) +f(n-2)
-- Consideramos f0 = 1 e f1 = 1 (fibonacci começa com 1)
-- registrador 0 tem valor fixo (0), começa com $1
-- ////////////////////////////////////////////////////////////////
	LIW $9, 1       -- carrega valor 1 no registrador 9 para incrementos
	LIW $10, 2       -- carrega valor 2 no registrador 10 para incrementos
	LIW $1, 1	-- immediate load register 1 with value f0 = 1
	LIW $2, 1	-- immediate load register 2 with value f1 = 1
	LIW $3, 1000	-- load o endereço da memoria 0
	SW $1,0($3)	-- salva valor de f0 na memoria #0
	ADD $3,$9	-- proximo endereço de memoria
	SW $2,0($3)	-- salva valor de f1 na memoria #1
	LIW $4, 2   --contador do numero de iterações
	LIW $5, 20 --numero maximo de iterações


-- loop do fibonacci
loop:	ADD $3,$9		-- próxima memória
		ADD $1, $2 		-- valor do $1 é somado ao valor do $2 e salvo em $1
		SW $1,0($3)		-- armazena na memoria
		ADD $3,$9		-- próxima memória
		ADD $2, $1  	-- valor do $2 é somado ao valor do $1 e salvo em $2
		SW $2,0($3)		-- armazena na memoria

		ADD $4,$10		-- iterações (se escolhesse um número de iterações ímpar, faria pequenas mudanças no código)
		BEQ $4,$5,%fim% -- checa numero de iterações já chegou a 20
		J %loop%		-- volta ao loop
fim: LIU $4,2 			-- reseta contador
