# ------------------------------------------------------------------------------
# 04 - Efeitos marginais medios
# Reproduz a Tabela 2 do artigo: probabilidade prevista de oferta quando cada
# variavel significativa no Modelo 6 vai do minimo ao maximo, mantidas as
# demais nos valores observados. As estrelas da Tabela 2 testam o efeito
# marginal (metodo delta), nao o coeficiente.
# ------------------------------------------------------------------------------

if (!exists("modelos")) source("R/03_modelos_logisticos.R")

m6 <- modelos$M6
p75_exposicao <- quantile(amostra$exp_historico_desastres, 0.75)
min_exposicao <- min(amostra$exp_historico_desastres)

contrastes <- list(
  list("exp_calamidade_ord", 0, 2),                          # nenhuma -> regular
  list("exp_historico_desastres", min_exposicao, p75_exposicao),  # minimo -> percentil 75
  list("rel_plano_contingencia", 0, 1),
  list("info_monitora_pmas", 0, 1),
  list("inst_psb_formal", 0, 1),
  list("rel_defesa_civil", 0, 1),
  list("inst_pse_formal", 0, 1)
)

tabela2 <- do.call(rbind, lapply(contrastes, function(c) {
  efeito_marginal(m6, c[[1]], c[[2]], c[[3]])
}))
tabela2$rotulo <- rotulos[tabela2$variavel]
tabela2$estrelas <- estrelas(tabela2$p_valor)
tabela2 <- tabela2[order(-abs(tabela2$mudanca)), ]

cat(sprintf("\nExposi\u00e7\u00e3o hist\u00f3rica: m\u00ednimo = %.3f; percentil 75 = %.3f\n",
            min_exposicao, p75_exposicao))
cat("\n== Tabela 2 - efeitos marginais m\u00e9dios (Modelo 6) ==\n")
print(data.frame(variavel = tabela2$rotulo,
                 De = virgula(tabela2$prob_de, 3),
                 Para = virgula(tabela2$prob_para, 3),
                 Mudanca = paste0(ifelse(tabela2$mudanca > 0, "+", ""),
                                  virgula(tabela2$mudanca, 3), " ", tabela2$estrelas)),
      row.names = FALSE)

write.csv(tabela2[, c("variavel", "rotulo", "prob_de", "prob_para", "mudanca",
                      "erro_padrao", "p_valor", "estrelas")],
          "resultados/tabela2_efeitos_marginais.csv", row.names = FALSE, fileEncoding = "UTF-8")
