-- Multiplica $2 por $3
-- $1 eh 1 para subtrair $3 dele
        LIW $1,1     --Carrega $1 com 1 para o decremento.
        LIW $2,300   --carrega $2 com 300
        LIW	$3,5     --carrega $3 com 5
        LIW $4,0     --carrega $4 com zero para o resultado
-- loop do multiplicador

loop:   ADD $4,$2
        SUB $3,$1
        BEQ $3,$0,%fim%
        J %loop%
fim:    SW $4,0($0) --salva o resultado
