# ------------------------------------------------------------------------------
# 01 - Preparacao dos dados
# Le a base municipal, aplica as transformacoes descritas na Secao 3 do artigo
# e define os blocos de variaveis de cada modelo.
# ------------------------------------------------------------------------------

source("R/funcoes.R")

base <- read.csv("dados/base_be_calamidade.csv",
                 encoding = "UTF-8",
                 colClasses = c(ibge6 = "character", ibge7 = "character"))

# Universo: 5.570 municipios; 308 nao responderam ao questionario de Gestao
# Municipal do Censo SUAS 2024 ou deixaram a variavel dependente em branco.
# A base ja contem apenas os 5.262 com informacao valida.
stopifnot(nrow(base) == 5262)

# IDH-M igual a zero indica ausencia de dado: sao cinco municipios emancipados
# depois do Censo Demografico de 2010, sem IDH-M calculado.
base$idh[base$idh == 0] <- NA

# Transformacoes logaritmicas dos controles de contexto
base$pop_ln <- log(base$pop_2022)
base$pib_ln <- log(base$pib_percapita)

# Dummies regionais, com o Sudeste como categoria de referencia
base$reg_sul         <- as.integer(base$regiao == "Regiao Sul")
base$reg_nordeste    <- as.integer(base$regiao == "Regiao Nordeste")
base$reg_norte       <- as.integer(base$regiao == "Regiao Norte")
base$reg_centrooeste <- as.integer(base$regiao == "Regiao Centro Oeste")

# Blocos de variaveis (ver Quadro 1 e nota da Tabela 1 do artigo)
blocos <- list(
  contexto  = c("pop_ln", "pib_ln", "reg_sul", "reg_nordeste", "reg_norte", "reg_centrooeste"),
  experiencia = c("exp_historico_desastres", "exp_calamidade_ord"),
  relacional  = c("rel_defesa_civil", "rel_plano_contingencia"),
  informacional = c("info_vigilancia_formal", "info_vigilancia_informal", "info_diagnostico",
                    "info_monitora_pmas", "info_sistema_proprio"),
  burocratico = c("inst_secretaria_exclusiva", "inst_pmas_vigente", "inst_psb_formal",
                  "inst_pse_formal", "inst_be_formal", "inst_pccs",
                  "inst_educ_perm_funciona", "inst_educ_perm_nao_funciona", "inst_capacitacao"),
  politico  = c("pol_conselho"),
  capacidade_geral = c("idh", "igem_geral")
)

# Modelos aninhados: os controles de contexto estao presentes em todos;
# IDH-M e i-QualiGov entram apenas no Modelo 6.
especificacoes <- list(
  M1 = c(blocos$experiencia, blocos$contexto),
  M2 = c(blocos$experiencia, blocos$relacional, blocos$contexto),
  M3 = c(blocos$experiencia, blocos$relacional, blocos$informacional, blocos$contexto),
  M4 = c(blocos$experiencia, blocos$relacional, blocos$informacional, blocos$burocratico,
         blocos$contexto),
  M5 = c(blocos$experiencia, blocos$relacional, blocos$informacional, blocos$burocratico,
         blocos$politico, blocos$contexto),
  M6 = c(blocos$experiencia, blocos$relacional, blocos$informacional, blocos$burocratico,
         blocos$politico, blocos$capacidade_geral, blocos$contexto)
)

# Amostra comum a todos os modelos: casos completos nas variaveis do Modelo 6.
# Exclui os cinco municipios sem IDH-M, resultando em 5.257 municipios.
amostra <- base[complete.cases(base[, c("Y_be_calamidade", especificacoes$M6)]), ]
stopifnot(nrow(amostra) == 5257)

# Rotulos usados nas tabelas
rotulos <- c(
  exp_historico_desastres     = "Exposi\u00e7\u00e3o hist\u00f3rica a desastres (ln)",
  exp_calamidade_ord          = "Experi\u00eancia operacional declarada (0-2)",
  rel_defesa_civil            = "Articula\u00e7\u00e3o com a Defesa Civil",
  rel_plano_contingencia      = "Participa do Plano de Conting\u00eancia",
  info_vigilancia_formal      = "Vigil\u00e2ncia - \u00e1rea formal",
  info_vigilancia_informal    = "Vigil\u00e2ncia - \u00e1rea informal",
  info_diagnostico            = "Diagn\u00f3stico socioterritorial",
  info_monitora_pmas          = "Monitora o PMAS",
  info_sistema_proprio        = "Sistema de informa\u00e7\u00e3o pr\u00f3prio",
  inst_secretaria_exclusiva   = "Secretaria exclusiva",
  inst_pmas_vigente           = "PMAS vigente",
  inst_psb_formal             = "\u00c1rea PSB - formal",
  inst_pse_formal             = "\u00c1rea PSE - formal",
  inst_be_formal              = "\u00c1rea Benef\u00edcios - formal",
  inst_pccs                   = "PCCS",
  inst_educ_perm_funciona     = "N\u00facleo Educ. Permanente - funciona",
  inst_educ_perm_nao_funciona = "N\u00facleo Educ. Permanente - n\u00e3o funciona",
  inst_capacitacao            = "Realizou capacita\u00e7\u00e3o",
  pol_conselho                = "Funcionamento do CMAS (0-2)",
  pop_ln                      = "Popula\u00e7\u00e3o (ln)",
  pib_ln                      = "PIB per capita (ln)",
  idh                         = "IDH-M",
  igem_geral                  = "i-QualiGov",
  reg_sul                     = "Regi\u00e3o Sul (ref. Sudeste)",
  reg_nordeste                = "Regi\u00e3o Nordeste",
  reg_norte                   = "Regi\u00e3o Norte",
  reg_centrooeste             = "Regi\u00e3o Centro-Oeste"
)

cat("Dados preparados: base com", nrow(base), "munic\u00edpios;",
    "amostra dos modelos com", nrow(amostra), "munic\u00edpios.\n")
