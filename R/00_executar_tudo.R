# ------------------------------------------------------------------------------
# 00 - Executa toda a replicacao, do preparo dos dados a verificacao final.
#
# Uso, a partir da pasta raiz do repositorio:
#   Rscript R/00_executar_tudo.R
# ou, no RStudio, abra replicacao.Rproj e rode source("R/00_executar_tudo.R").
# ------------------------------------------------------------------------------

if (!file.exists("dados/base_be_calamidade.csv")) {
  stop("Execute este script a partir da pasta raiz do reposit\u00f3rio.")
}
dir.create("resultados", showWarnings = FALSE)

etapas <- c("R/01_preparar_dados.R",
            "R/02_descritivas.R",
            "R/03_modelos_logisticos.R",
            "R/04_efeitos_marginais.R",
            "R/05_diagnosticos.R",
            "R/06_robustez.R",
            "R/07_verificar_resultados.R")

for (etapa in etapas) {
  cat("\n------------------------------------------------------------\n")
  cat("Executando", etapa, "\n")
  cat("------------------------------------------------------------\n")
  source(etapa, encoding = "UTF-8")
}

# Trava de seguranca: so declara sucesso se a verificacao realmente conferiu valores
if (!exists("conferidos") || conferidos == 0 || length(divergencias) > 0) {
  stop("A verificação final não foi concluída. Revise as mensagens acima.")
}

writeLines(capture.output(sessionInfo()), "resultados/sessao_R.txt")
cat("\nReplica\u00e7\u00e3o conclu\u00edda. Resultados em resultados/.\n")
