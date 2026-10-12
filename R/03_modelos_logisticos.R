# ------------------------------------------------------------------------------
# 03 - Modelos de regressao logistica binaria
# Reproduz a Tabela 1 do artigo: seis modelos aninhados, estimados sobre os
# mesmos 5.257 municipios, com os controles de contexto em todos os modelos.
# ------------------------------------------------------------------------------

if (!exists("amostra")) source("R/01_preparar_dados.R")

modelos <- lapply(especificacoes, function(vars) {
  formula <- reformulate(vars, response = "Y_be_calamidade")
  glm(formula, family = binomial(link = "logit"), data = amostra)
})

# Coeficientes completos: razao de chance, IC 95% (Wald) e p-valor
coeficientes <- do.call(rbind, lapply(names(modelos), function(m) {
  s <- summary(modelos[[m]])$coefficients
  s <- s[rownames(s) != "(Intercept)", , drop = FALSE]
  data.frame(modelo = m,
             variavel = rownames(s),
             beta = s[, "Estimate"],
             erro_padrao = s[, "Std. Error"],
             razao_chance = exp(s[, "Estimate"]),
             ic95_inf = exp(s[, "Estimate"] - qnorm(0.975) * s[, "Std. Error"]),
             ic95_sup = exp(s[, "Estimate"] + qnorm(0.975) * s[, "Std. Error"]),
             p_valor = s[, "Pr(>|z|)"],
             row.names = NULL)
}))

# Tabela 1 no formato do artigo: razao de chance com estrelas
ordem <- c(blocos$experiencia, blocos$relacional, blocos$informacional,
           blocos$burocratico, blocos$politico,
           "pop_ln", "pib_ln", "idh", "igem_geral",
           "reg_sul", "reg_nordeste", "reg_norte", "reg_centrooeste")

tabela1 <- data.frame(variavel = ordem, rotulo = rotulos[ordem], row.names = NULL)
for (m in names(modelos)) {
  sub <- coeficientes[coeficientes$modelo == m, ]
  celula <- paste0(virgula(sub$razao_chance), estrelas(sub$p_valor))
  tabela1[[m]] <- ifelse(ordem %in% sub$variavel,
                         celula[match(ordem, sub$variavel)], "-")
}

ajuste <- data.frame(
  modelo = names(modelos),
  n = sapply(modelos, function(x) length(x$y)),
  nagelkerke_r2 = sapply(modelos, nagelkerke),
  aic = sapply(modelos, AIC),
  log_verossimilhanca = sapply(modelos, function(x) as.numeric(logLik(x))),
  row.names = NULL
)

cat("\n== Tabela 1 - raz\u00f5es de chance (* p<0,05; ** p<0,01; *** p<0,001) ==\n")
print(tabela1[, c("rotulo", names(modelos))], row.names = FALSE)
cat("\n== Ajuste dos modelos ==\n")
print(transform(ajuste, nagelkerke_r2 = round(nagelkerke_r2, 3), aic = round(aic, 1),
                log_verossimilhanca = round(log_verossimilhanca, 1)), row.names = FALSE)

write.csv(tabela1, "resultados/tabela1_modelos.csv", row.names = FALSE, fileEncoding = "UTF-8")
write.csv(coeficientes, "resultados/tabela1_coeficientes_completos.csv", row.names = FALSE,
          fileEncoding = "UTF-8")
write.csv(ajuste, "resultados/tabela1_ajuste.csv", row.names = FALSE, fileEncoding = "UTF-8")
saveRDS(modelos, "resultados/modelos.rds")
