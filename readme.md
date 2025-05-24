
# SIMANEM - Simulador do ANEM16
Autor: **João Paulo Cerquinho Cajueiro**  
---

## 📘 ANEM Não É MIPS

Este processador visa ser de fins didáticos, com base em alguns conceitos do MIPS, mas reduzido para 16 bits.

O ANEM conta com um banco de 16 registradores de uso geral, dos quais R0 tem sempre o valor 0 e R15 é usado como registrador de retorno de função.

### Instruções

A maior parte das instruções é equivalente às instruções do MIPS, mas com duas ressalvas: Primeiro que os opcodes não tem espaço para 3 registradores, logo se usa a técnica do registrador destino ser o mesmo que um dos fontes. Outra é o método para carregar valores imediatos, onde foram criadas 2 novas instruções adicionais ao MIPS: LIL (Load Immediate Lower byte) e LIU (Load Immediate Upper byte). No assembly se define uma pseudo instrução LIW (Load Immediate Word) que é separada nestas duas na hora da compilação.

As instruções são:

| Aritméticas | Saltos | Deslocamentos | Dados |
|-------------|--------|----------------|-------|
| ADD         | J      | SHL            | LW    |
| SUB         | JAL    | SHR            | SW    |
| AND         | JR     | SAR            | LIL   |
| OR          | BEQ    | ROL            | LIU   |
| XOR         |        | ROR            |       |
| NOR         |        |                |       |
| SLT         |        |                |       |

Estas instruções são implementadas por 5 formatos de opcode diferentes, tipos R, S, W, I e J.

| Tipo | Instruções |
|------|----------|
| R    | ADD, SUB, AND, OR, XOR, NOR, SLT |
| S    | SHL, SHR, SAR, ROL, ROR |
| L    | LIU, LIL |
| J    | J, JAL, HAB |
| W    | LW, SW, BEQ, JR |

#### Instruçãos Tipo R (Registrador)

|  opcode | reg1 | reg2 | func |
|---------|------|------|------|
| 4b | 4b | 4b | 4b |

Todas instruções tipo R tem o mesmo **opcode**: 0000. A instrução específica é definida pelo campo **func**. Elas realizam operações lógico-aritméticas da seguint forma:

  ```
  reg1 := func(reg1,reg2)
  ```

#### Instruções tipo S (Shift):
|  opcode | reg1 | shamt | func |
|---------|------|------|------|
| 4b | 4b | 4b | 4b |

Instruções S fazem deslocamentos e rotações de **reg1**. A quantidade de bits deslocados é definida por **shamt** - *shift ammount*.

#### Instruções tipo W (Memória):
| opcode | reg1 | reg2 | offset |
|--------|------|------|--------|
| 4b | 4b | 4b | 4b |

Instruções W implementam duas instruções de memória de dados (LW - *Load Word* e SW - *Store Word*), uma de salto condicional (BEQ - *Branch if EQual*) e uma de salto indireto (JR - *Jump to address pointed by Register*), e os campos tem significados diferentes em cada caso.

Nas instruções LW e SW, **reg2** serve como ponteiro da memória de dados, indexado por **offset**. **reg1** age como o registrador de trabalho em ambos os casos.

A instrução BEQ é o único salto condicional do ANEM, que faz o contador de programa deslocar **offset** se **reg1** tiver o mesmo valor que **reg2**.

Neste dois últimos casos, **offset** está em complemento a dois, indo de -8 a +7.

Já a instrução JR simplesmente transfere o valor de **reg1** para o PC, ignorando **reg2** e **offset**.

#### Instruções tipo I (Imediato):
| opcode | reg1 | byte |
|--|--|--|
| 4b | 4b | 8b |

Para LIL, o byte menos significativo (L - *lower*) de **reg1** recebe **byte**, com os demais sem serem modificados. Mesma coisa para LIU, sendo que para o byte mais significativo (U - *upper*).

#### Instruções tipo J (Salto):
| opcode | endereço |
|--|--|
| 4b | 12b |

Nas duas instruções tipo J o PC é somado a **endereço**, que é em complemento a dois e vai de -2048 a 2047. Na JAL - *Jump And Link* - o valor atual do PC, incrementado em 1, é salvo no registrador 15.

---

### 2. OPCODES

| Instrução | Tipo | Opcode |
|-----------|------|--------|
| tipo R    | R    | 0000   |
| tipo S    | R    | 0001   |
| J         | J    | 1000   |
| JAL       | J    | 1001   |
| BEQ       | W    | 0110   |
| JR        | W    | 0111   |
| SW        | W    | 0100   |
| LW        | W    | 0101   |
| LIU       | L    | 1100   |
| LIL       | L    | 1101   |

---

### 3. Multi-ciclo

#### Etapas de Execução:

1. Busca da instrução (RI ← Mem[PC], PC ← PC+1)
2. Decodificação e busca de registradores (A, B)
3. Execução (ULA ou deslocamento)
4. Gravação (registrador ou memória)

#### Etapas por Instrução:

| Instrução | Etapas |
|-----------|--------|
| LW        | busca → decod. → calc.end. → leitura → gravação |
| SW        | busca → decod. → calc.end. → escrita |
| LIL/LIU   | busca → decod. → esc. byte |
| ADD...    | busca → decod. → exec. → esc. reg |
| SHL...    | busca → decod. → exec. |
| BEQ       | busca → decod. → decisão |
| J         | busca → decod. → salta |
| JAL       | busca → decod. → salta → esc. reg |
| JR        | busca → decod. → salta |

---

## 🛠️ Assembler para o ANEM16

**Data:** 17 março 2011

---

### Sumário

1. Uso  
2. Limpeza  
3. Indexação  
4. Montagem  
5. Conversão  

---

### 1. Uso

Pipeline de montagem:

```sh
cat codigo.asm | ./limpa | ./indexa | ./monta > cod_maquina.dat
```

- `.asm` pode conter labels e comentários (começam com `--`)

---

### 2. Limpeza

#### Pseudo-instruções:

| Pseudo | Reais |
|--------|-------|
| NOP    | ADD $0, $0 |
| LIW    | LIU + LIL  |

---

### 3. Indexação

- Extrai `.LABELS` e `.CODE`
- Suporta `.ADDRESS` e `.CONSTANT`

---

### 4. Montagem

Tipos de instruções:

| Tipo | Exemplos |
|------|----------|
| R    | ADD, SUB, AND, OR, XOR, NOR, SLT |
| S    | SHL, SHR, SAR, ROL, ROR |
| L    | LIU, LIL |
| J    | J, JAL, HAB |
| W    | LW, SW, BEQ, JR |
| F    | FADD, FSUB, FMUL, FABS, etc. |
| Fx   | FMLD, FSLD, FMST, FSST, FSX |

---

### 5. Conversão para Intel HEX

Exemplo de linha:

```
:10XXXX00AABBCCDDEEFF...ZZ
:00000001FF
```

Usado para carregar código ANEM16 em FPGAs.

---
