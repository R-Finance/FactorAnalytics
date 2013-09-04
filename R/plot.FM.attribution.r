#' plot FM.attribution class
#' 
#' Generic function of plot method for factorModelPerformanceAttribution.
#' Either plot all fit models or choose a single asset to plot.
#' 
#' 
#' @param fm.attr FM.attribution object created by
#' factorModelPerformanceAttribution.
#' @param which.plot integer indicating which plot to create: "none" will
#' create a menu to choose. Defualt is none. 1 = attributed cumulative returns,
#' 2 = attributed returns on date selected by user, 3 = time series of
#' attributed returns
#' @param max.show Maximum assets to plot. Default is 6.
#' @param date date indicates for attributed returns, the date format should be
#' xts compatible.
#' @param plot.single Plot a single asset of lm class. Defualt is FALSE.
#' @param fundName Name of the portfolio to be plotted.
#' @param which.plot.single integer indicating which plot to create: "none"
#' will create a menu to choose. Defualt is none. 1 = attributed cumulative
#' returns, 2 = attributed returns on date selected by user, 3 = time series of
#' attributed returns
#' @param ...  more arguements for \code{chart.TimeSeries} used for plotting
#' time series
#' @author Yi-An Chen.
#' @examples
#' \dontrun{
#' data(managers.df)
#' fit.ts <- fitTimeSeriesFactorModel(assets.names=colnames(managers.df[,(1:6)]),
#'                                   factors.names=c("EDHEC.LS.EQ","SP500.TR"),
#'                                   data=managers.df,fit.method="OLS")
#'  fm.attr <- factorModelPerformanceAttribution(fit.ts)
#' # plot all
#' plot(fm.attr,legend.loc="topleft",max.show=6)
#' dev.off()
#' # plot only one assets "HAM1
#' plot(fm.attr,plot.single=TRUE,fundName="HAM1")
#' }
#' @method plot FM.attribution  
#' @export
#' 
plot.FM.attribution <- function(fm.attr, which.plot=c("none","1L","2L","3L"),max.show=6,
                                date=NULL,plot.single=FALSE,fundName,
                                which.plot.single=c("none","1L","2L","3L"),...) {
  # ... for  chart.TimeSeries
  require(PerformanceAnalytics)
  if (is.null(date)){
    date = index(fm.attr[[3]][[1]])[1]
  }
  
  # plot single assets
  if (plot.single==TRUE){
    
    which.plot.single<-which.plot.single[1]
    
    if (which.plot.single=="none")
      which.plot.single<-menu(c("attributed cumulative returns",
                                paste("attributed returns","on",date,sep=" "),
                                "Time series of attributed returns"),
                              title="performance attribution plot \nMake a plot selection (or 0 to exit):\n")
    switch(which.plot.single,
           "1L" =  {  
             bar <- c(fm.attr$cum.spec.ret[fundName],fm.attr$cum.ret.attr.f[fundName,])
             names(bar)[1] <- "specific.returns"
             barplot(bar,horiz=TRUE,main="cumulative attributed returns",las=1)
           },
           "2L" ={
             bar <- coredata(fm.attr$attr.list[[fundName]][as.Date(date)])
             tryCatch( {barplot(bar,horiz=TRUE,main=fundName,las=1)
                        },error=function(e){cat("\nthis date is not available for this assets.\n")})
           },
           "3L" = {
             chart.TimeSeries(fm.attr$attr.list[[fundName]],
                              main=paste("Time series of attributed returns of ",fundName,sep=""),... )
           },
           invisible())
  }
  # plot all assets 
  else {
    which.plot<-which.plot[1]
    fundnames <- rownames(fm.attr$cum.ret.attr.f) 
    n <- length(fundnames)
    
    if(which.plot=='none') 
      which.plot<-menu(c("attributed cumulative returns",
                         paste("attributed returns","on",date,sep=" "),
                         "time series of attributed returns"),
                       title="performance attribution plot \nMake a plot selection (or 0 to exit):\n") 
    if (n >= max.show) {
      cat(paste("numbers of assets are greater than",max.show,", show only first",
                max.show,"assets",sep=" "))
      n <- max.show 
    }
    switch(which.plot,
           
           "1L" = {
             par(mfrow=c(2,n/2))
             for (i in fundnames[1:n]) {
               bar <- c(fm.attr$cum.spec.ret[i],fm.attr$cum.ret.attr.f[i,])
               names(bar)[1] <- "specific.returns"
               barplot(bar,horiz=TRUE,main=i,las=1)  
             }
             par(mfrow=c(1,1))
           },
           "2L" ={
             par(mfrow=c(2,n/2))
             for (i in fundnames[1:n]) {
               tryCatch({
               bar <- coredata(fm.attr$attr.list[[i]][as.Date(date)])
               barplot(bar,horiz=TRUE,main=i,las=1)
               }, error=function(e) {
                cat("\nDate for some assets returns is not available.\n")
                dev.off()
                } )
               }
             par(mfrow=c(1,1))
           }, 
           "3L" = {
             par(mfrow=c(2,n/2))
             for (i in fundnames[1:n]) {
               chart.TimeSeries(fm.attr$attr.list[[i]],main=i,...)
             }
             par(mfrow=c(1,1))
           },     
           invisible()
    )
    
  }
}
