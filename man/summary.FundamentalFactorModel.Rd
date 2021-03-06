\name{summary.FundamentalFactorModel}
\alias{summary.FundamentalFactorModel}
\title{summary FundamentalFactorModel object}
\usage{
  \method{summary}{FundamentalFactorModel} (object,
    digits = max(3, .Options$digits - 3), ...)
}
\arguments{
  \item{object}{An object created by
  \code{fitFundamentalFactorModel}.}

  \item{digits}{integer indicating the number of decimal
  places. Default is 3.}

  \item{...}{Other arguments for \code{print} methods.}
}
\description{
  Generic function of summary method for
  \code{fitFundamentalFactorModel}.
}
\examples{
data(Stock.df)
# there are 447 assets
exposure.names <- c("BOOK2MARKET", "LOG.MARKETCAP")
test.fit <- fitFundamentalFactorModel(data=stock,exposure.names=exposure.names,
                                       datevar = "DATE", returnsvar = "RETURN",
                                       assetvar = "TICKER", wls = TRUE,
                                       regression = "classic",
                                       covariance = "classic", full.resid.cov = TRUE,
                                       robust.scale = TRUE)

summary(test.fit)
}
\author{
  Yi-An Chen.
}

