#Below is code for creating the function nse() that takes the input from compare_to_field() when as_value = FALSE and calculates NSE

nse<-function(rmse){
  
  i<-1
  os<-as.vector(NA)
  oo<-as.vector(NA)
  
  for(i in 1:length(rmse[,1]))
  {
    os[i]<-(rmse$obs[i] - rmse$mod[i])^2
  }
  
  for(i in 1:length(rmse[,1]))
  {
    oo[i]<-(rmse$obs[i] - mean(rmse$obs))^2
  }
  
  nse = 1-(sum(os) / sum(oo))
  print(nse)
}