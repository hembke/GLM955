## Clear workspace and console
rm(list=ls()); cat("\014")
# Load required packages
#library(FSA); library(dplyr); library(magrittr);library(lubridate)
library(ggplot2)

#library(devtools)

#devtools::install_github('USGS-R/glmtools',ref='ggplot_overhaul')
#devtools::install_github('GLEON/GLM3r')

library(glmtools)
library(GLM3r)

setwd("~/Documents/GLM955-South/mendota/FreshFiles-from-2019-11-20/PQT/")
sim_folder = getwd()

set.seed(123)

run_glm()

out_file = file.path(sim_folder, 'outputs/output.nc')

pdf("Simulations/A4_Mendota.PDF", width=11, height=8.5) 
plot_var(nc_file = out_file, var_name='temp')
plot_var(nc_file = out_file, var_name='salt')
dev.off()


#plot_var_compare(nc_file = out_file, field_file = 'field_mendota.csv', var_name = 'temp')

temp_rmse = compare_to_field(out_file, field_file = 'field_mendota.csv', metric='water.temperature', as_value=F)
print(paste(round(temp_rmse,3),'deg C RMSE'))

rmse = compare_to_field(out_file, field_file = 'field_mendota.csv', metric='water.temperature', as_value=T)

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

nse(rmse)

# I get 1.48 RMSE for the baseline

# 1.5 = very good fit - so 1.55 is good - this was achieved just with base value
# base value: wind_factor=1.0, kw (Light extinction)= 0.22, Lw_factor=0.91

# change values: wind_factor=0.9 -- RMSE = 1.37
# change values: kw =0.24 -- RMSE = 1.45
# change values: kw = 0.20, RMSE = 1.67
# change values: wind_factor = 0.9, kw = 0.24 -- RMSE = 1.37

# RLAKEANALYZER
sim_folder <- getwd()
out_file <- file.path(sim_folder, 'outputs/output.nc')

output_data <- get_var(file = out_file,var_name = 'temp', reference = 'surface',z_out = seq(0,24,1))
output_data_salt <- get_var(file = out_file,var_name = 'salt', reference = 'surface',z_out = seq(0,24,1))

sim_vars(out_file)

colnames(output_data) <- c('datetime',
                           paste0('wtr_',seq(0,24,1)))

colnames(output_data_salt) <- c('datetime',
                           paste0('salt_',seq(0,24,1)))

head(output_data)

#wtr.heat.map(output_data)

bath_data <- load.bathy('hypso.txt')
head(bath_data)

schmidt <-ts.schmidt.stability(output_data,bath_data)
buoyancy <- ts.buoyancy.freq(output_data, at.thermo = TRUE, na.rm = TRUE)
thermo <- ts.thermo.depth(output_data, Smin = 0.1, na.rm = FALSE)

ME.df <- data.frame("Datetime"= output_data$datetime,"Schmidt" = schmidt$schmidt.stability, 
                    "N2" = buoyancy$n2, 
                    "Thermocline" = thermo$thermo.depth, 
                    "Tempdiff" = output_data$wtr_1-output_data$wtr_24)

ME.df.salt <- data.frame("Datetime"= output_data_salt$datetime,"Schmidt" = schmidt$schmidt.stability, 
                    "N2" = buoyancy$n2, 
                    "Thermocline" = thermo$thermo.depth, 
                    "Tempdiff" = output_data$wtr_1-output_data$wtr_24)

# Plot Physical features:
library(ggplot2)
g1 <- ggplot(ME.df, aes(Datetime, Schmidt),colour = "black") +
  geom_line() +
  ggtitle('Schmidt Stability [J/m2]')+
  theme_bw()
g2 <- ggplot(ME.df, aes(Datetime, N2),colour = 'black') +
  geom_line() +
  ggtitle('Buoyancy Frequency [s-2]')+
  theme_bw()
g3 <- ggplot(ME.df, aes(Datetime, Thermocline), colour= "black") +
  geom_line() +
  ggtitle('Thermocline Depth [m]')+
  theme_bw() +
  scale_y_reverse()
g4 <- ggplot(ME.df, aes(Datetime, Tempdiff), colour = "black") +
  geom_line() +
  ggtitle("Diff Epi-Hypo [deg C]")+
  theme_bw()
g5 <- ggplot(output_data_salt)+
  geom_line(aes(x=datetime, y=output_data_salt$salt_0,color="Surface (0m)"))+
  geom_line(aes(x=datetime, y=output_data_salt$salt_24,color="Bottom (24m)"))+
  scale_color_manual(values = c(
    'Surface (0m)' = 'red',
    'Bottom (24m)' = 'blue')) +
  labs(color = 'Depth')+
  ylab("Salinity g/kg")+
  theme_bw()+
  theme(legend.position="bottom")

g6 <- ggplot(output_data)+
  geom_line(aes(x=datetime, y=output_data$wtr_0,color="Surface (0m)"))+
  geom_line(aes(x=datetime, y=output_data_salt$salt_24,color="Bottom (24m)"))+
  scale_color_manual(values = c(
    'Surface (0m)' = 'red',
    'Bottom (24m)' = 'blue')) +
  labs(color = 'Depth')+
  ylab("Temperature (C)")+
  theme_bw()+
  theme(legend.position="bottom")

library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)

library(ggpubr)
#g <- grid.arrange(g1, g2, g3, g4,g5, ncol =1, top=textGrob("Lake Mendota, Scenario A3, Constant salt [10]"))

#plot.compare <- grid.arrange(g5, g6, ncol=1)

#install.packages("egg")
library(egg)
g <- egg::ggarrange(g1, g2, g3, g4,g5, ncol=1)
g
g.compare <- egg::ggarrange(g5, g6, ncol=1)
g.compare

pdf("Simulations/A4_Mendota_compare.PDF", width=11, height=8.5) 
g
g.compare
dev.off()
