library(tidyverse)
library(lubridate)
mendota.volume = 39581169 * 12.8

#mean discharge
77.5e6 #m3 yr

y.in = read_csv('Inflow/YaharaTemp.csv') %>% 
  select(time = Date, Temp)

mjs = read_csv('mendota/MJS/Yahara_Windsor_ScaledDischarge_MJS.csv',guess_max = 15000) %>% 
  mutate(time = as.Date(time)) %>% 
  left_join(y.in) %>% 
  select(time,FLOW,SALT,TEMP = Temp)

write_csv(mjs,'Inflow/Yahara_Windsor_ScaledDischarge_MJS_temp.csv')
ggplot(mjs) + geom_line(aes(time,TEMP))


# Check residence time 
rt = mjs %>% group_by(year = year(time)) %>% 
  summarise(flow.m3 = sum(FLOW) * 3600*24, rt = mendota.volume / (sum(FLOW) * 3600*24))

ggplot(rt) + geom_bar(aes(year,rt),stat = 'identity')



