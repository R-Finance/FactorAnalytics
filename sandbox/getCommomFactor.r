# Acquire data for factors

# Script downloads, parses, and transforms data for a small set
# of common factors to be included as example data within 
# FactorAnalytics.  For more information, see the help file
# for ?factors

# Peter Carl

### Needed packages
require(gdata)
require(quantmod)
require(RQuantLib)

## Factor set of several commonly used factors

# @TODO: Find a better source for VIX
# @TODO: Find a source for TR of SP500

# setup perl
perl = "C:/Program Files/MATLAB/R2010b/sys/perl/win32/bin/perl.exe"
setwd("C:/Users/Yi-An Chen/Documents/R-project/R FA project")

### Equities
# Get S&P price returns from FRED for now, TR later
# @TODO: Get total returns for S&P factor rather than price returns
getSymbols("SP500", src="FRED") # daily price series
index(SP500) = as.Date(as.yearmon(index(SP500)), frac=1)
# Calculate monthly returns
SP500.R=monthlyReturn(SP500)
colnames(SP500.R)="SP500"
# Calculate quarterly returns
SP500.Q.R=quarterlyReturn(SP500)
colnames(SP500.Q.R)="SP500"

### Bonds
# Calculate total returns from the yeild of the 10 year constant maturity 
# index maintained by the Fed
getSymbols("GS10", src="FRED") #load US Treasury 10y yields from FRED
# Dates should be end of month, not beginning of the month as reported
index(GS10) = as.Date(as.yearmon(index(GS10)), frac=1)
GS10.pr <- GS10  #set this up to hold price returns
GS10.pr[1,1] <- 0
colnames(GS10.pr) <- "Price Return"
for (i in 1:(NROW(GS10)-1)) {
  GS10.pr[i+1,1] <- FixedRateBondPriceByYield(yield=GS10[i+1,1]/100, issueDate=Sys.Date(), maturityDate=advance("UnitedStates/GovernmentBond", Sys.Date(), 10, 3), rates=GS10[i,1]/100,period=2)[1]/100-1
}
#total return will be the price return + yield/12 for one month
GS10.R <- GS10.pr + lag(GS10,k=1)/12/100
colnames(GS10.R)<-"GS10TR"

GS10.idx =cumprod(1 + na.omit(GS10.R))
GS10.Q.idx=to.quarterly(GS10.idx)
GS10.Q.R=quarterlyReturn(Cl(GS10.Q.idx))
colnames(GS10.Q.R)<-"GS10TR"
index(GS10.Q.R) = as.Date(as.yearqtr(index(GS10.Q.R)), frac=1)

### Currencies
# Trade Weighted U.S. Dollar Index: Major Currencies - TWEXMMTH
getSymbols("TWEXMMTH", src="FRED") # index values
# Dates should be end of month, not beginning of the month as reported
index(TWEXMMTH) = as.Date(as.yearmon(index(TWEXMMTH)), frac=1)
USDI.R=ROC(TWEXMMTH)
colnames(USDI.R)="USD Index"

USDI.idx =cumprod(1 + na.omit(USDI.R))
USDI.Q.idx=to.quarterly(USDI.idx)
USDI.Q.R=quarterlyReturn(Cl(USDI.Q.idx))
colnames(USDI.Q.R)<-"USD Index"
index(USDI.Q.R) = as.Date(as.yearqtr(index(USDI.Q.R)), frac=1)

### Credit Spread
# Yield spread of Merrill Lynch High-Yield Corporate Master II Index
# minus 10-year Treasury
getSymbols("BAMLH0A0HYM2EY",src="FRED")
CREDIT=BAMLH0A0HYM2EY/100-GS10/100
colnames(CREDIT)="Credit Spread"
CREDIT.Q=CREDIT[endpoints(CREDIT, on="quarters"),]
colnames(CREDIT.Q)="Credit Spread"

### Liquidity
getSymbols("TB3MS",src="FRED")
index(TB3MS) = as.Date(as.yearmon(index(TB3MS)), frac=1)
getSymbols("MED3",src="FRED")
index(MED3) = as.Date(as.yearmon(index(MED3)), frac=1)
TED=MED3/100-TB3MS/100
colnames(TED)="TED Spread"
TED.Q=TED[endpoints(TED, on="quarters"),]
colnames(TED.Q)="TED Spread"

### Real estate
# Use the NAREIT index

### Commodities
## Use the DJUBS Commodities index
# Remove the old file if it exists
if(file.exists("DJUBS_full_hist.xls"))
  system("rm DJUBS_full_hist.xls")
# Download the most recent file
print("Downloading excel spreadsheet from DJUBS web site...")
# Can't get it directly, sorry windows users
system("wget http://www.djindexes.com/mdsidx/downloads/xlspages/ubsci_public/DJUBS_full_hist.xls")
if(!file.exists("DJUBS_full_hist.xls"))
  stop(paste("No spreadsheet exists.  Download the spreadsheet to be processed from www.djindexes.com into ", filesroot, "/.incoming", sep=""))

# Parse the spreadsheet
print("Reading sheet... This will take a moment...")


x = read.xls("DJUBS_full_hist.xls", sheet="Total Return",perl=perl)
x=x[-1:-2,] # Get rid of the headings  
x=x[-dim(x)[1],] # Get rid of the last line, which contains the disclaimer
ISOdates = as.Date(x[,1], "%m/%d/%Y") # Get dates

# Make an xts object of prices
x.xts = as.xts(as.numeric(as.vector(x[,2])), order.by=ISOdates)

# Construct a monthly series from the daily series
x.m.xts = to.monthly(x.xts)
x.m.xts = ROC(Cl(x.m.xts)) # Calc monthly returns
x.q.xts = to.quarterly(x.xts)
x.q.xts = ROC(Cl(x.q.xts)) # Calc monthly returns
# @ TODO Want to delete the last line off ONLY IF the month is incomplete
#  if(tail(index(x.xts),1) != as.Date(as.yearmon(tail(index(x.xts),1)), frac=1)) {
# That test isn't quite right, but its close.  It won't work on the first
# day of a new month when the last business day wasn't the last day of 
# the month.  It will work for the second day.
#     x.m.xts = x.m.xts[-dim(x.m.xts)[1],]
#   }

# Index is set to last trading day of the month.  
# Reset index to last day of the month to make alignment easier with other monthly series.  
index(x.m.xts)=as.Date(index(x.m.xts), frac=1)
index(x.q.xts)=as.Date(index(x.q.xts), frac=1)
DJUBS.R = x.m.xts
DJUBS.Q.R = x.q.xts
colnames(DJUBS.R)="DJUBSTR"
colnames(DJUBS.Q.R)="DJUBSTR"

### Volatility
# as per Lo, the first difference of the end-of-month value of the CBOE Volatility Index (VIX)

# Older VIX data is available at:
# http://www.cboe.com/publish/ScheduledTask/MktData/datahouse/vixarchive.xls
# Daily from 1990-2003


x= read.xls( "http://www.cboe.com/publish/ScheduledTask/MktData/datahouse/vixarchive.xls",
             perl = perl)
ISOdates = as.Date(x[,1], "%m/%d/%y") # Get dates
x.xts = as.xts(as.numeric(as.vector(x[,5])), order.by=ISOdates)
x.m.xts = to.monthly(x.xts)
x.q.xts = to.quarterly(x.xts)
getSymbols("VIXCLS", src="FRED")
# Calculate monthly returns
VIX=to.monthly(VIXCLS)
VIX.Q=to.quarterly(VIXCLS)
VIX=rbind(x.m.xts,VIX)
VIX.Q=rbind(x.q.xts,VIX.Q)
index(VIX)=as.Date(index(VIX), frac=1)
index(VIX.Q)=as.Date(index(VIX.Q), frac=1)
dVIX=diff(Cl(VIX))
dVIX.Q=diff(Cl(VIX.Q))
colnames(dVIX)="dVIX"
colnames(dVIX.Q)="dVIX"

### Term spread
# 10 year yield minus 3 month
TERM = GS10/100-TB3MS/100
colnames(TERM)="Term Spread"
TERM.Q=TERM[endpoints(TERM, on="quarters"),]
colnames(TERM.Q)="Term Spread"

### Gold
# Monthly return on gold spot price

### Oil
# Monthly returns of spot price of West Texas Intermediate
getSymbols("OILPRICE", src="FRED")
index(OILPRICE) = as.Date(as.yearmon(index(OILPRICE)), frac=1)
OIL.R = ROC(OILPRICE)
OIL.Q.R = ROC(Cl(to.quarterly(OILPRICE)))
index(OIL.Q.R) = as.Date(as.yearqtr(index(OIL.Q.R)), frac=1)

### PUT
system("wget https://www.cboe.com/micro/put/PUT_86-06.xls")
setwd("C:/Users/Yi-An Chen/Documents/R-project/R FA project")
x = read.xls("PUT_86-06.xls",perl=perl)
x=na.omit(x[-1:-4,1:2])
ISOdates = as.Date(x[,1], "%d-%b-%Y") # Get dates
PUT1 = xts(as.numeric(as.vector(x[,2])), order.by=ISOdates)

# link fails
system("wget https://www.cboe.com/publish/ScheduledTask/MktData/datahouse/PUTDailyPrice.csv")
y=read.csv("PUTDailyPrice.csv")
y=y[-1:-4,]
ISOdates = as.Date(y[,1], "%m/%d/%Y") # Get dates
PUT2 = xts(as.numeric(as.vector(y[,2])), order.by=ISOdates)

PUT = rbind(PUT1,PUT2)
colnames(PUT)="Close"
PUT = ROC(Cl(to.monthly(PUT)))
index(PUT) = as.Date(as.yearmon(index(PUT)), frac=1)


lastquarter=format(as.Date(as.yearqtr(Sys.Date())-.25, frac=1), "%Y-%m")


factors=cbind(SP500.R, GS10.R, USDI.R, TERM, CREDIT, DJUBS.R, dVIX, TED, OIL.R, TB3MS/100)
factors=factors["1997::",]
factors.Q=cbind(SP500.Q.R, GS10.Q.R, USDI.Q.R, TERM.Q, CREDIT.Q, DJUBS.Q.R, dVIX.Q, TED.Q, OIL.Q.R, TB3MS[endpoints(TB3MS, on="quarters"),]/100)
factors.Q=factors.Q[paste("1997::",lastquarter,sep=""),]

setwd("C:/Users/Yi-An Chen/Documents/R-project/returnanalytics/pkg/FactorAnalytics/data")
save(factors,factors.Q,file="CommomFactors.RData")