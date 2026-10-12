# ------------------------------------------------------------------------------
# 02 - Estatisticas descritivas
# Reproduz a Secao 4.1 e o Apendice B (Tabela 4) do artigo.
# Usa os 5.262 municipios com informacao valida na variavel dependente.
# ------------------------------------------------------------------------------

if (!exists("base")) source("R/01_preparar_dados.R")

n_total <- nrow(base)
n_oferta <- sum(base$Y_be_calamidade == 1)
n_nao <- sum(base$Y_be_calamidade == 0)

cat("\n== Se\u00e7\u00e3o 4.1 ==\n")
cat(sprintf("Munic\u00edpios com informa\u00e7\u00e3o v\u00e1lida: %d\n", n_total))
cat(sprintf("Ofertam o benef\u00edcio: %d (%.2f%%)\n", n_oferta, 100 * n_oferta / n_total))
cat(sprintf("N\u00e3o ofertam: %d (%.2f%%)\n", n_nao, 100 * n_nao / n_total))

distribuicao <- function(variavel, recorte, ordem) {
  tab <- table(base[[variavel]], base$Y_be_calamidade)
  tab <- tab[ordem, , drop = FALSE]
  data.frame(recorte = recorte,
             categoria = rownames(tab),
             n_total = as.integer(rowSums(tab)),
             n_nao_oferta = as.integer(tab[, "0"]),
             pct_nao_oferta = round(100 * tab[, "0"] / rowSums(tab)),
             n_oferta = as.integer(tab[, "1"]),
             pct_oferta = round(100 * tab[, "1"] / rowSums(tab)),
             row.names = NULL)
}

apendice_b <- rbind(
  data.frame(recorte = "Brasil", categoria = "Total", n_total = n_total,
             n_nao_oferta = n_nao, pct_nao_oferta = round(100 * n_nao / n_total),
             n_oferta = n_oferta, pct_oferta = round(100 * n_oferta / n_total)),
  distribuicao("regiao", "Regi\u00e3o",
               c("Regiao Norte", "Regiao Nordeste", "Regiao Centro Oeste",
                 "Regiao Sudeste", "Regiao Sul")),
  distribuicao("porte_pop2022", "Porte populacional",
               c("Pequeno I", "Pequeno II", "Medio", "Grande", "Metropole"))
)

cat("\n== Ap\u00eandice B (Tabela 4) ==\n")
print(apendice_b, row.names = FALSE)

write.csv(apendice_b, "resultados/tabela4_apendice_b.csv", row.names = FALSE,
          fileEncoding = "UTF-8")
