# install.packages("INLA",repos=c(getOption("repos"),INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
require('INLA')
set.seed(2345)

# simulate continuous predictor
x <- rnorm(400, mean = 0, sd = 2)

## binomial component
XmatBF <- model.matrix(~ 1 + x)# X
coefB <- c(0.5, 2)
fixedEffectsB <- matrix(coefB, 2, 1) # Beta

# factor with 4 levels
n.groups <- 4
n.sample <- 100
n <- n.groups * n.sample
RFB <- gl(n = n.groups, k = 100, length = n) 	
XmatBR <- model.matrix(~ RFB:x - 1)# Z
coefBR <- rnorm(4, mean = 0, sd = 2)
raneffectsB <- matrix(coefBR, 4, 1)# u
# 
lin.predB <- XmatBF %*% fixedEffectsB + XmatBR %*% raneffectsB
binomResponse <- plogis(lin.predB)

## gamma component
XmatGF <- model.matrix(~ 1 + x)# X
coefG <- c(-1.5, -1)
fixedEffectsG <- matrix(coefG, 2, 1)# Beta

# factor with 4 levels
n.groups <- 4
n.sample <- 100
n <- n.groups * n.sample
RFG <- gl(n = n.groups, k = 100, length = n) 	
XmatGR <- model.matrix(~ RFG:x - 1)# Z
coefGR <- rnorm(4, mean = 0, sd = 1)
raneffectsG <- matrix(coefGR, 4, 1)# u

lin.predG <- XmatGF %*% fixedEffectsG + XmatGR %*% raneffectsG
gammaResponse <- exp(lin.predG)

## inla model
# data frame
data <- data.frame(binomResponse = c(binomResponse, rep(NA, 400)),
        gammaResponse = c(rep(NA,400),gammaResponse),
        interceptB = c(rep(1, 400),rep(NA, 400)), interceptG = c(rep(NA, 400), rep(1, 400)),
        xB = c(x, rep(NA, 400)), xG = c(rep(NA, 400), x),
        RFB = c(as.numeric(RFB), rep(NA, 400)), RFG = c(rep(NA, 400), as.numeric(RFG) + 4))

# model formula
formulaHURDLE <- data[, c(1:2)] ~ 0 + interceptB + interceptG + xB + xG + f(RFB, xB, model = 'iid') + f(RFG, xG, model = 'iid')

# (Beta + b)
lcsB <- inla.make.lincombs(RFB = diag(4),
        xB = rep(1, 4))
lcsG <- inla.make.lincombs(RFG = diag(4),
        xG = rep(1, 4))
names(lcsG) <- paste(names(lcsB), "G", sep = "")

# run the model
mod <- inla(formulaHURDLE, data = data,
            family = c("binomial", "gamma"), Ntrials = 1, control.family = list(list(link = 'logit'), list(link = 'log'))
            ,verbose = T, control.predictor = list(link = c(rep(1 ,400), rep(2, 400)))
            ,lincomb = c(lcsB, lcsG))

summary(mod)

# extract the posteriors of (Beta + b)
allMarginals <- lapply(seq_len(length(mod$marginals.lincomb.derived)), 
             function(p) data.frame(inla.tmarginal(function(x) x,mod$marginals.lincomb.derived[[p]], n = 800), var = names(mod$marginals.lincomb.derived)[p], estimates = inla.emarginal(function(x) x, mod$marginals.lincomb.derived[[p]])))
allMarginals <- do.call(rbind, allMarginals)

# plot (Beta + b) (binomial component)
layout(matrix(c(1:4), 2, 2, byrow = TRUE),
       widths=c(1,1), heights=c(1,1))
r <- 0
for (i in unique(allMarginals$var)[1:4]) {
        r <- r + 1
        plot(allMarginals[which(allMarginals$var == i), c(1, 2)], t = "l", xlab = expression(beta[1]^{B} + b[j]^{B}), ylab = "")
        abline(v = unique(allMarginals[which(allMarginals$var == i), 4]))
        abline(v = rbind(fixedEffectsB[2, 1] + raneffectsB, fixedEffectsG[2, 1] + raneffectsG)[r], col = 'red', lty = 2)
}
# plot (Beta + b) (gamma component)
r <- 4
for (i in unique(allMarginals$var)[5:8]) {
        r <- r + 1
        plot(allMarginals[which(allMarginals$var == i), c(1, 2)], t = "l", xlab = expression(beta[1]^{G} + b[j]^{G}), ylab = "")
        abline(v = unique(allMarginals[which(allMarginals$var == i), 4]))
        abline(v = rbind(fixedEffectsB[2, 1] + raneffectsB, fixedEffectsG[2, 1] + raneffectsG)[r], col = 'red', lty = 2)
}

# print("LinComb BINOMIAL"); inla.emarginal(function(x) x, mod$marginals.lincomb.derived$lc1)
# print("LinComb BINOMIAL manually calculated"); (inla.emarginal(function(x) x, mod$marginals.fixed$xB) + inla.emarginal(function(x) x, mod$marginals.random$RFB$index.1))
# print("LinComb GAMMA"); inla.emarginal(function(x) x, mod$marginals.lincomb.derived$lc1G)
# print("LinComb GAMMA manually calculated"); (inla.emarginal(function(x) x, mod$marginals.fixed$xG) + inla.emarginal(function(x) x, mod$marginals.random$RFG$index.1))