# ------------------------------------------------------------------------------
# 07 - Verificacao automatica
# Compara os resultados reproduzidos (pasta resultados/) com os valores
# reportados no artigo (pasta resultados_publicados/). Termina com erro se
# alguma celula divergir.
# ------------------------------------------------------------------------------

ler <- function(caminho) read.csv(caminho, encoding = "UTF-8", stringsAsFactors = FALSE,
                                  check.names = FALSE)
divergencias <- character(0)
conferidos <- 0

registrar <- function(ok, descricao) {
  conferidos <<- conferidos + 1
  if (!ok) divergencias <<- c(divergencias, descricao)
}

# Tabela 1: razoes de chance com estrelas, celula a celula
t1 <- ler("resultados/tabela1_modelos.csv")
t1_pub <- ler("resultados_publicados/tabela1_publicada.csv")
for (i in seq_len(nrow(t1_pub))) {
  linha <- t1[t1$variavel == t1_pub$variavel[i], ]
  for (m in paste0("M", 1:6)) {
    registrar(identical(linha[[m]], t1_pub[[m]][i]),
              sprintf("Tabela 1, %s, %s: obtido %s, publicado %s",
                      t1_pub$variavel[i], m, linha[[m]], t1_pub[[m]][i]))
  }
}

# Tabela 1: ajuste dos modelos
aj <- ler("resultados/tabela1_ajuste.csv")
aj_pub <- ler("resultados_publicados/tabela1_ajuste_publicado.csv")
for (i in seq_len(nrow(aj_pub))) {
  linha <- aj[aj$modelo == aj_pub$modelo[i], ]
  registrar(linha$n == aj_pub$n[i], sprintf("N do %s", aj_pub$modelo[i]))
  registrar(round(linha$nagelkerke_r2, 3) == aj_pub$nagelkerke_r2[i],
            sprintf("Nagelkerke do %s: obtido %.3f", aj_pub$modelo[i], linha$nagelkerke_r2))
  registrar(round(linha$aic, 1) == aj_pub$aic[i],
            sprintf("AIC do %s: obtido %.1f", aj_pub$modelo[i], linha$aic))
}

# Tabela 2: efeitos marginais, tres casas decimais e estrelas
t2 <- ler("resultados/tabela2_efeitos_marginais.csv")
t2_pub <- ler("resultados_publicados/tabela2_publicada.csv")
for (i in seq_len(nrow(t2_pub))) {
  linha <- t2[t2$variavel == t2_pub$variavel[i], ]
  for (col in c("prob_de", "prob_para", "mudanca")) {
    registrar(abs(round(linha[[col]], 3) - t2_pub[[col]][i]) < 1e-9,
              sprintf("Tabela 2, %s, %s: obtido %.3f, publicado %.3f",
                      t2_pub$variavel[i], col, linha[[col]], t2_pub[[col]][i]))
  }
  registrar(identical(linha$estrelas, t2_pub$estrelas[i]),
            sprintf("Tabela 2, %s, estrelas", t2_pub$variavel[i]))
}

# Apendice A: VIF do Modelo 6
t3 <- ler("resultados/tabela3_apendice_a_vif.csv")
t3_pub <- ler("resultados_publicados/tabela3_apendice_a_publicada.csv")
for (i in seq_len(nrow(t3_pub))) {
  obtido <- t3$vif[t3$variavel == t3_pub$variavel[i]]
  registrar(abs(obtido - t3_pub$vif[i]) < 1e-3,
            sprintf("Ap\u00eandice A, VIF de %s: obtido %.4f, publicado %.4f",
                    t3_pub$variavel[i], obtido, t3_pub$vif[i]))
}

# Apendice B: distribuicao por regiao e porte
t4 <- ler("resultados/tabela4_apendice_b.csv")
t4_pub <- ler("resultados_publicados/tabela4_apendice_b_publicada.csv")
for (i in seq_len(nrow(t4_pub))) {
  linha <- t4[t4$categoria == t4_pub$categoria[i], ]
  for (col in c("n_total", "n_nao_oferta", "pct_nao_oferta", "n_oferta", "pct_oferta")) {
    registrar(linha[[col]] == t4_pub[[col]][i],
              sprintf("Ap\u00eandice B, %s, %s: obtido %s, publicado %s",
                      t4_pub$categoria[i], col, linha[[col]], t4_pub[[col]][i]))
  }
}

cat("\n== Verifica\u00e7\u00e3o contra os valores do artigo ==\n")
cat(sprintf("Valores conferidos: %d\n", conferidos))
if (length(divergencias) == 0) {
  cat("Todos os valores reproduzidos coincidem com os reportados no artigo.\n")
} else {
  cat(sprintf("Diverg\u00eancias: %d\n", length(divergencias)))
  cat(paste0(" - ", divergencias, collapse = "\n"), "\n")
  stop("A reprodu\u00e7\u00e3o n\u00e3o coincide com os valores publicados.")
}
