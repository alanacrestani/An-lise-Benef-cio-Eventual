# ------------------------------------------------------------------------------
# 06 - Verificacoes de robustez
# Examina a relacao entre as medidas de capacidade geral (IDH-M e i-QualiGov) e a
# exposicao historica a desastres, discutida na Secao 4.2 e no Apendice A.
# Cada variante reestima o Modelo 6 retirando uma ou mais variaveis.
# ------------------------------------------------------------------------------

if (!exists("modelos")) source("R/03_modelos_logisticos.R")

variantes <- list(
  "M6 completo"                          = especificacoes$M6,
  "M6 sem IDH-M"                         = setdiff(especificacoes$M6, "idh"),
  "M6 sem i-QualiGov"                    = setdiff(especificacoes$M6, "igem_geral"),
  "M6 sem hist\u00f3rico de desastres"        = setdiff(especificacoes$M6, "exp_historico_desastres"),
  "M6 sem hist\u00f3rico e sem i-QualiGov"    = setdiff(especificacoes$M6,
                                                   c("exp_historico_desastres", "igem_geral"))
)

robustez <- do.call(rbind, lapply(names(variantes), function(nome) {
  mod <- glm(reformulate(variantes[[nome]], response = "Y_be_calamidade"),
             family = binomial, data = amostra)
  s <- summary(mod)$coefficients
  linhas <- intersect(c("idh", "igem_geral"), rownames(s))
  data.frame(especificacao = nome, variavel = rotulos[linhas],
             razao_chance = exp(s[linhas, "Estimate"]),
             p_valor = s[linhas, "Pr(>|z|)"], row.names = NULL)
}))

cat("\n== Robustez: IDH-M e i-QualiGov em variantes do Modelo 6 ==\n")
print(transform(robustez, razao_chance = round(razao_chance, 2), p_valor = round(p_valor, 4)),
      row.names = FALSE)

write.csv(robustez, "resultados/robustez_capacidade_geral.csv", row.names = FALSE,
          fileEncoding = "UTF-8")
