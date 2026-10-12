# Capacidades estatais e a oferta do Benefício Eventual para calamidade pública: material de replicação

Este repositório reúne os dados e o código necessários para reproduzir todas as análises
estatísticas do artigo:

> CRESTANI, Alana; MARENCO, André. Capacidades estatais e a oferta do Benefício Eventual
> para calamidade pública nos municípios brasileiros. Artigo submetido à *Revista do Serviço
> Público* (RSP), 2026.

O artigo investiga por que alguns municípios brasileiros preveem o Benefício Eventual para
calamidade pública e outros não. A partir do Censo SUAS 2024, estimamos seis modelos de
regressão logística binária e mostramos que a oferta se associa às capacidades municipais em
uso (experiência em emergências, articulação com a Defesa Civil, participação no Plano de
Contingência, monitoramento do PMAS), e não à mera presença formal de estruturas.

## Como reproduzir

Requisitos: **R 4.2 ou superior**. Nenhum pacote adicional é necessário; todo o código usa
apenas o R base.

1. Baixe ou clone este repositório.
2. Abra um terminal na pasta raiz do repositório e execute:

   ```
   Rscript R/00_executar_tudo.R
   ```

   No RStudio, abra o arquivo `replicacao.Rproj` e rode `source("R/00_executar_tudo.R")`.

A execução leva poucos segundos. Os resultados são gravados na pasta `resultados/` e, ao
final, o script `07_verificar_resultados.R` compara cada número reproduzido com o valor
reportado no artigo. Se tudo coincidir, a mensagem final é
*"Todos os valores reproduzidos coincidem com os reportados no artigo"*.

Cada script também pode ser executado isoladamente (a partir da pasta raiz), pois carrega
automaticamente as etapas de que depende.

A pasta `resultados/` já traz as saídas de uma execução completa (R 4.3.3; detalhes em
`resultados/sessao_R.txt`), para quem quiser consultar as tabelas sem rodar o código. Em
sistemas sem suporte a UTF-8, rótulos acentuados podem aparecer como `<U+00E3>` no console e
nos CSVs gerados; os valores numéricos não são afetados.

## O que cada script reproduz

| Script | Resultado no artigo | Arquivo gerado em `resultados/` |
|---|---|---|
| `01_preparar_dados.R` | Seção 3 (amostra, transformações, especificação dos modelos) | — |
| `02_descritivas.R` | Seção 4.1 e Apêndice B (Tabela 4) | `tabela4_apendice_b.csv` |
| `03_modelos_logisticos.R` | Tabela 1 (seis modelos, Nagelkerke R², AIC) | `tabela1_modelos.csv`, `tabela1_coeficientes_completos.csv`, `tabela1_ajuste.csv` |
| `04_efeitos_marginais.R` | Tabela 2 e probabilidades previstas citadas na Seção 4.2 | `tabela2_efeitos_marginais.csv` |
| `05_diagnosticos.R` | Apêndice A (Tabela 3, colinearidade), EPV e correlações | `tabela3_apendice_a_vif.csv` |
| `06_robustez.R` | Testes de robustez sobre IDH-M e i-QualiGov (Seção 4.2) | `robustez_capacidade_geral.csv` |
| `07_verificar_resultados.R` | Conferência automática contra o artigo | — |

O arquivo `tabela1_coeficientes_completos.csv` traz, além das razões de chance, os
coeficientes, erros-padrão, intervalos de confiança de 95% e p-valores de todos os modelos.

## Dados

O arquivo `dados/base_be_calamidade.csv` contém uma linha por município e 30 colunas. O
dicionário completo, com a pergunta do questionário que originou cada variável, está em
`dados/dicionario_variaveis.csv`.

| Fonte | Variáveis |
|---|---|
| Censo SUAS 2024, questionário de Gestão Municipal (MDS) | variável dependente e indicadores das dimensões de experiência, relacional, informacional e burocrático-institucional |
| Censo SUAS 2024, questionário do Conselho Municipal (MDS) | funcionamento do CMAS |
| Sistema Integrado de Informações sobre Desastres – S2ID (2013-2023) | exposição histórica a desastres |
| IBGE (Censo Demográfico 2022; PIB dos Municípios) | população, PIB per capita, região, porte |
| PNUD – Atlas do Desenvolvimento Humano | IDH-M |
| INCT-QualiGov | índice sintético de capacidade estatal (i-QualiGov) |

Os dados do Censo SUAS são públicos e podem ser obtidos no portal da Vigilância
Socioassistencial do Ministério do Desenvolvimento e Assistência Social.

### Composição da amostra

| Etapa | Municípios |
|---|---|
| Municípios brasileiros | 5.570 |
| Sem resposta ao questionário de Gestão Municipal ou com a variável dependente em branco | −308 |
| **Base com informação válida** (estatísticas descritivas, Seção 4.1 e Apêndice B) | **5.262** |
| Sem IDH-M, por terem sido emancipados após o Censo Demográfico de 2010 (todos ofertantes) | −5 |
| **Amostra dos modelos de regressão** (Tabelas 1 e 2, Apêndice A) | **5.257** |

Na base, o IDH-M desses cinco municípios aparece com valor 0, que o script de preparação
converte em dado ausente.

## Especificação dos modelos

Os seis modelos são aninhados e estimados sobre a mesma amostra de 5.257 municípios. Os
controles de contexto (população e PIB per capita em logaritmo natural e dummies regionais,
com o Sudeste como referência) estão presentes em todos os modelos.

| Modelo | Blocos incluídos |
|---|---|
| M1 | experiência operacional + controles de contexto |
| M2 | M1 + dimensão relacional e de coordenação intersetorial |
| M3 | M2 + dimensão informacional, analítica e gerencial |
| M4 | M3 + dimensão burocrático-institucional e programática |
| M5 | M4 + dimensão político-institucional (funcionamento do CMAS) |
| M6 | M5 + IDH-M e i-QualiGov |

Notas metodológicas:

- As estrelas seguem a convenção do artigo: \* p<0,05; \*\* p<0,01; \*\*\* p<0,001.
- Na Tabela 2, a probabilidade prevista média é calculada com a variável no valor mínimo
  ("De") e no máximo ("Para"), mantidas as demais nos valores observados de cada município.
  Para a experiência operacional (0-2), os valores são 0 e 2; para a exposição histórica, o
  mínimo e o percentil 75. As estrelas dessa tabela testam o efeito marginal, com erro-padrão
  pelo método delta, e não o coeficiente da Tabela 1.
- O VIF do Apêndice A é calculado sobre todos os preditores do Modelo 6, incluindo as dummies
  regionais.

## Estrutura do repositório

```
├── dados/
│   ├── base_be_calamidade.csv        base municipal usada no artigo
│   └── dicionario_variaveis.csv      descrição e fonte de cada variável
├── R/
│   ├── 00_executar_tudo.R            executa toda a replicação
│   ├── 01_preparar_dados.R ... 07_verificar_resultados.R
│   └── funcoes.R                     funções auxiliares
├── resultados/                       saídas geradas pelos scripts
├── resultados_publicados/            valores reportados no artigo, usados na verificação
├── CITATION.cff
├── LICENSE
└── README.md
```

## Como citar

Ao usar estes dados ou este código, cite o artigo acima. O GitHub oferece a citação pronta
no botão *Cite this repository*, a partir do arquivo `CITATION.cff`.

## Licença

O código está disponível sob a licença MIT. A base de dados deriva de fontes públicas
(MDS, IBGE, PNUD, S2ID e INCT-QualiGov) e é disponibilizada sob a licença Creative Commons
Atribuição 4.0 (CC BY 4.0). Veja o arquivo `LICENSE`.
