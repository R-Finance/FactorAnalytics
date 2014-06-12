context("Test fitTimeSeriesFactorModel")

test_that("fitTimeSeriesFactorModel is as expected", {

  # fit Carhart 4-factor model using lm
  fpath <- system.file("extdata", "timeSeriesReturns.csv", package="factorAnalytics")
  returns.z <- read.zoo(file=fpath,header=TRUE,sep=",",as.is=TRUE,FUN=as.yearmon)
  returns.z <- window(returns.z,start="2008-01-01",end="2012-12-31")  
  assets <- names(returns.z)[1:30]
  ex.rets <- returns.z[,assets]-returns.z$rf
  carhart <- returns.z[,c("mktrf","smb","hml","umd")]  
  ff4 <- lm(ex.rets ~ carhart)
  sum4 = summary(ff4)
  rsq4 <- as.numeric(sapply(X = sum4, FUN = "[", "r.squared"))
  Sigma.F <- var(carhart)
  beta.hat <- coef(ff4)[-1,]
  Sigma.eps <- diag(as.numeric(sapply(X = sum4, FUN = "[", "sigma")))
  Sigma.R <- t(beta.hat) %*% Sigma.F %*% beta.hat + Sigma.eps^2

  # fit Carhart 4-factor mode via fitTimeSeriesFactorModel
  ff.mod <- fitTimeSeriesFactorModel(
    assets.names = assets,
    factors.names = c("mktrf","smb", "hml","umd"),
    data = cbind(ex.rets,carhart),
    fit.method = "OLS")

  expect_that(ff.mod$beta,is_equivalent_to(t(coef(ff4)[-1,])))
  expect_that(as.numeric(ff.mod$r2),equals(as.numeric(sapply(X = sum4, FUN = "[", "r.squared"))))
  
})
