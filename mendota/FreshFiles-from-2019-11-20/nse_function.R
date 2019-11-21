nse<-function(rmse){
  
  i<-1
  os<-as.vector(NA)
  oo<-as.vector(NA)
  
  for(i in 1:length(rmse[,1]))
  {
    os[i]<-(rmse$mod[i] - rmse$obs[i])^2
  }
  
  for(i in 1:length(rmse[,1]))
  {
    oo[i]<-(rmse$mod[i] - mean(rmse$obs))^2
  }
  
  nse = 1-(sum(os) / sum(oo))
  print(nse)
}
