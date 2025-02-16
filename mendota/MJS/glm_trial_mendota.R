## Clear workspace and console
rm(list=ls()); cat("\014")
# Load required packages
library(FSA); library(dplyr); library(magrittr);library(lubridate)
library(ggplot2)

#library(devtools)

#devtools::install_github('USGS-R/glmtools',ref='ggplot_overhaul')
#devtools::install_github('GLEON/GLM3r')

library(glmtools)
library(GLM3r)

setwd("/Users/hollyembke/Desktop/UW/Classes/GLM sem (fall 2019)/files/mendota")
sim_folder = getwd()

run_glm()

out_file = file.path(sim_folder, 'outputs/output.nc')
plot_var(nc_file = out_file, var_name='temp')

plot_var_compare(nc_file = out_file, field_file = 'field_mendota.csv', var_name = 'temp')

temp_rmse = compare_to_field(out_file, field_file = 'field_mendota.csv', metric='water.temperature', as_value=F)
print(paste(round(temp_rmse,2),'deg C RMSE'))

# 1.5 = very good fit - so 1.55 is good - this was achieved just with base value
# base value: wind_factor=1.0, kw (Light extinction)= 0.22, Lw_factor=0.91

# change values: wind_factor=0.9 -- RMSE = 1.37
# change values: kw =0.24 -- RMSE = 1.45
# change values: kw = 0.20, RMSE = 1.67
# change values: wind_factor = 0.9, kw = 0.24 -- RMSE = 1.37
