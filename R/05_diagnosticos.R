# ------------------------------------------------------------------------------
# 05 - Diagnosticos
# Reproduz o Apendice A (Tabela 3, colinearidade do Modelo 6), o criterio de
# eventos por variavel (EPV) e a correlacao entre as duas medidas de
# experiencia citada na discussao e na nota do Apendice A.
# ------------------------------------------------------------------------------

if (!exists("modelos")) source("R/03_modelos_logisticos.R")

# Colinearidade: VIF calculado sobre a matriz de preditores do Modelo 6
X6 <- model.matrix(modelos$M6)[, -1]
vif <- vif_manual(X6)
apendice_a <- data.frame(variavel = names(vif), rotulo = rotulos[names(vif)],
                         tolerancia = 1 / vif, vif = vif, row.names = NULL)
apendice_a <- apendice_a[order(apendice_a$tolerancia), ]

cat("\n== Ap\u00eandice A (Tabela 3) - colinearidade no Modelo 6 ==\n")
print(transform(apendice_a[, c("rotulo", "tolerancia", "vif")],
                tolerancia = round(tolerancia, 4), vif = round(vif, 4)), row.names = FALSE)
cat(sprintf("Maior VIF: %.2f (limiar convencional: 5)\n", max(vif)))

# Correlacoes mencionadas na nota do Apendice A
cat("\n== Correla\u00e7\u00f5es ==\n")
cat(sprintf("Hist\u00f3rico de desastres x experi\u00eancia declarada: r = %.2f\n",
            cor(amostra$exp_historico_desastres, amostra$exp_calamidade_ord)))
cat(sprintf("IDH-M x PIB per capita (ln): r = %.2f\n", cor(amostra$idh, amostra$pib_ln)))
cat(sprintf("IDH-M x i-QualiGov: r = %.2f\n", cor(amostra$idh, amostra$igem_geral)))

# Eventos por variavel (EPV): o evento e a categoria menos frequente (nao oferta)
eventos <- sum(amostra$Y_be_calamidade == 0)
parametros <- length(coef(modelos$M6)) - 1
cat("\n== Eventos por vari\u00e1vel (Modelo 6) ==\n")
cat(sprintf("Eventos (n\u00e3o oferta): %d; preditores: %d; EPV = %.1f (limiar conservador: 20)\n",
            eventos, parametros, eventos / parametros))

write.csv(apendice_a, "resultados/tabela3_apendice_a_vif.csv", row.names = FALSE,
          fileEncoding = "UTF-8")
