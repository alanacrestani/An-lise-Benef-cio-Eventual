# ------------------------------------------------------------------------------
# Funcoes auxiliares usadas pelos scripts de replicacao.
# Somente R base: nenhum pacote externo e necessario.
# ------------------------------------------------------------------------------

# Estrelas de significancia, convencao do artigo (o nivel de 10% nao e usado)
estrelas <- function(p) {
  ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", "")))
}

# Numero com virgula decimal, como nas tabelas do artigo
virgula <- function(x, casas = 2) {
  out <- formatC(x, format = "f", digits = casas)
  gsub(".", ",", out, fixed = TRUE)
}

# R2 de Nagelkerke para um modelo glm binomial
nagelkerke <- function(modelo) {
  n <- length(modelo$y)
  ll_modelo <- as.numeric(logLik(modelo))
  ll_nulo <- as.numeric(logLik(update(modelo, . ~ 1)))
  cox_snell <- 1 - exp((2 / n) * (ll_nulo - ll_modelo))
  maximo <- 1 - exp((2 / n) * ll_nulo)
  cox_snell / maximo
}

# Efeito marginal medio de levar uma variavel de um valor "de" a um valor "para",
# mantidas as demais variaveis nos valores observados de cada municipio.
# O erro-padrao vem do metodo delta, com gradiente analitico.
efeito_marginal <- function(modelo, variavel, de, para) {
  X <- model.matrix(modelo)
  beta <- coef(modelo)
  V <- vcov(modelo)

  X_de <- X;   X_de[, variavel] <- de
  X_para <- X; X_para[, variavel] <- para

  p_de <- as.vector(plogis(X_de %*% beta))
  p_para <- as.vector(plogis(X_para %*% beta))

  efeito <- mean(p_para) - mean(p_de)
  gradiente <- colMeans(p_para * (1 - p_para) * X_para) -
               colMeans(p_de * (1 - p_de) * X_de)
  ep <- sqrt(as.numeric(t(gradiente) %*% V %*% gradiente))
  p_valor <- 2 * pnorm(-abs(efeito / ep))

  data.frame(variavel = variavel,
             prob_de = mean(p_de),
             prob_para = mean(p_para),
             mudanca = efeito,
             erro_padrao = ep,
             p_valor = p_valor)
}

# Fator de inflacao da variancia (VIF) para cada coluna de uma matriz de
# preditores: 1 / (1 - R2) da regressao de cada preditor sobre os demais.
vif_manual <- function(X) {
  X <- as.data.frame(X)
  sapply(names(X), function(v) {
    r2 <- summary(lm(X[[v]] ~ ., data = X[, setdiff(names(X), v), drop = FALSE]))$r.squared
    1 / (1 - r2)
  })
}
