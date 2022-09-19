library(tidyverse)
library(ggplot2)
library(knitr)

#read in the data
cpi_monthly = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/CPI_monthly.csv")
GDP_quarterly = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/GDP_quarterly.csv")

unemployment_national = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/unemployment_national_quarterly_final.csv")

unemployment_state_monthly = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/unemployment_state_monthly.csv") %>% 
  #filter election years and October
  filter((Year %%2 ==0) & (Month==10)) %>%
  select("State and area","Year","Unemployed_prct") %>%
  filter(Year %in% c(2018,2014,2010,2006,2002,1998,1994,1990,1986,1982,1978,1974,1970,1966,1962))

cpi_df = cpi_monthly %>%
  #code from week 2 class to split strings into year and month
  mutate(Year = as.numeric(str_split(cpi_monthly$DATE,"-",simplify=T)[,1]),
         Month = as.numeric(str_split(cpi_monthly$DATE,"-",simplify=T)[,2])) %>% 
  group_by(Month) %>% arrange(DATE) %>%
  #using lag function to calculate YoY Inflation for the Month of October
  mutate(Inflation_yoy=100*(CPIAUCSL - lag(CPIAUCSL,1))/lag(CPIAUCSL,1)) %>%
  ungroup() %>% arrange(DATE) %>%
  filter((Year %% 2 == 0) & (Month ==10))

gdp_df = GDP_quarterly %>%
  filter((year %% 2 == 0) & (quarter_yr ==4)) %>% rename(Year=year)

unemployment_national_df = unemployment_national %>%
  filter((year %% 2 == 0) & (quarter_yr == 4))%>% rename(Year=year) %>%
  select(Year,UNRATE)

house_popvote = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/house_popvote_seats.csv") %>% rename(Year=year)

#left joining dataframes into one large DF
df = left_join(left_join(left_join(house_popvote,cpi_df,by=c("Year")), gdp_df, by="Year"),unemployment_national_df,by="Year")%>% 
  #select only the columns we need
  select(Year,
         R_seats,
         D_seats,
         winner_party,
         R_majorvote_pct,
         D_majorvote_pct,
         president_party,
         H_incumbent_party_winner,
         H_incumbent_party_majorvote_pct,
         H_incumbent_party,
         Inflation_yoy,
         GDP_growth_pct,
         UNRATE) %>% na.omit() %>%
  #filter for only midterms
  filter(Year %in% c(2018,2014,2010,2006,2002,1998,1994,1990,1986,1982,1978,1974,1970,1966,1962)) %>%
  #create variable that takes how the democrats do when there is a democratic in the WH, same with Republicans
  mutate(president_party_house_vote = case_when(
    president_party == "D" ~ D_majorvote_pct,
    president_party == "R" ~ R_majorvote_pct
  ))

#read in the but only getting our 2022 economy so we can make a prediction at the end
cpi2022 = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/CPI_monthly.csv") %>%
  mutate(Year = as.numeric(str_split(cpi_monthly$DATE,"-",simplify=T)[,1]),
         Month = as.numeric(str_split(cpi_monthly$DATE,"-",simplify=T)[,2])) %>% 
  group_by(Month) %>% arrange(DATE) %>%
  mutate(Inflation_yoy=100*(CPIAUCSL - lag(CPIAUCSL,1))/lag(CPIAUCSL,1)) %>%
  ungroup() %>% arrange(DATE) %>%
  filter((Year == 2022)& (Month==6))

gdp2022= read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/GDP_quarterly.csv") %>%
  filter((year == 2022) &(quarter_yr == 2)) %>% rename(Year=year)

unemployment2022 = read_csv("/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/data/week2/unemployment_national_quarterly_final.csv") %>%
  filter((year == 2022) &(quarter_yr == 2))%>% rename(Year=year) %>% select(Year,UNRATE)

economy.2022 = left_join(left_join(cpi2022, gdp2022, by="Year"),unemployment2022,by="Year") %>% 
  select(Year,
         Inflation_yoy,
         GDP_growth_pct,
         UNRATE) 


#plots from lab session
df %>%
  ggplot(aes(x=Inflation_yoy, y=president_party_house_vote,
             label=Year)) + 
  geom_text() +
  geom_hline(yintercept=50, lty=2) + # median
  xlab("YoY Inflation in October of the Election Year") +
  ylab("Congressional Vote Share Nationally") +
  ggtitle("Inflation vs Current President party House Vote Share")+
  theme_bw() +
  theme(
    axis.text = element_text(size = 10))

# ggsave("InflationVsHouseVoteShare.png", height = 6, width = 12)


df %>%
  ggplot(aes(x=UNRATE, y=president_party_house_vote,
             label=Year)) + 
  geom_text() +
  geom_hline(yintercept=50, lty=2) + # median
  xlab("Unemployment in October of the Election Year") +
  ylab("Congressional Vote Share Nationally") +
  ggtitle("Unemployment vs Current President party House Vote Share")+
  theme_bw() +
  theme(
    axis.text = element_text(size = 10))
# ggsave("UnemploymentVsHouseVoteShare.png", height = 6, width = 12)

df %>%
  ggplot(aes(x=GDP_growth_pct, y=president_party_house_vote,
             label=Year)) + 
  geom_text() +
  geom_hline(yintercept=50, lty=2) + # median
  xlab("Q2-Q3 GDP Growth of the Election Year") +
  ylab("Congressional Vote Share Nationally") +
  ggtitle("GDP Growth vs Current President party House Vote Share")+
  theme_bw() +
  theme(
    axis.text = element_text(size = 10))

# ggsave("GDPvsHouseVoteShare.png", height = 6, width = 12)

#plot from lab session
df %>%
  ggplot(aes(x=Inflation_yoy, y=D_majorvote_pct,
             label=Year)) + 
  geom_text(size = 5) +
  geom_smooth(method="lm", formula = y ~ x) +
  geom_hline(yintercept=50, lty=2) +
  geom_vline(xintercept=0.0, lty=2) + # median
  xlab("Inflation") +
  ylab("Democrat Popular Vote Share") +
  theme_bw() +
  theme(axis.text = element_text(size = 10),
        axis.title = element_text(size = 10),
        plot.title = element_text(size = 10))

# ggsave("InflationvsDemocrats.png", height = 6, width = 12)

#creating linear models for using our three metrics 
r_inflation_model = lm(R_majorvote_pct ~ Inflation_yoy,data = df)
d_inflation_model = lm(D_majorvote_pct ~ Inflation_yoy,data = df)

r_gdp_model = lm(R_majorvote_pct ~ GDP_growth_pct,data = df)
d_gdp_model = lm(D_majorvote_pct ~ GDP_growth_pct,data = df)

r_unemployment_model = lm(R_majorvote_pct ~ UNRATE,data = df)
d_unemployment_model = lm(D_majorvote_pct ~ UNRATE,data = df)

# at most 4 decimal places
kable(cbind(Metric.Republican_Voteshare = c("Inflation","GDP Growth","Unemployment"),
            Coefficient = c(
              round(summary(r_inflation_model)$coef[2],digits=3),
              round(summary(r_gdp_model)$coef[2],digits=3),
              round(summary(r_unemployment_model)$coef[2], digits=3)), 
            P.Value = c(
              round(summary(r_inflation_model)$coef[8],digits=3),
              round(summary(r_gdp_model)$coef[8],digits=3),
              round(summary(r_unemployment_model)$coef[8],digits=3)),
            Predictions.2022 = c(
              round(predict(r_inflation_model, economy.2022), digits=3),
              round(predict(r_gdp_model,economy.2022), digits=3),
              round(predict(r_unemployment_model,economy.2022), digits=3)
            )))

kable(cbind(Metric.Democrat_Voteshare = c("Inflation","GDP Growth","Unemployment"),
            Coefficient = c(
              round(summary(d_inflation_model)$coef[2],digits=3),
              round(summary(d_gdp_model)$coef[2],digits=3),
              round(summary(d_unemployment_model)$coef[2], digits=3)), 
            P.Value = c(
              round(summary(d_inflation_model)$coef[8],digits=3),
              round(summary(d_gdp_model)$coef[8],digits=3),
              round(summary(d_unemployment_model)$coef[8],digits=3)),
            Predictions.2022 = c(
              round(predict(d_inflation_model, economy.2022), digits=3),
              round(predict(d_gdp_model,economy.2022), digits=3),
              round(predict(d_unemployment_model,economy.2022), digits=3)
            )))
