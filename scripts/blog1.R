#load libraries and data
library(tidyverse)
library(usmap)
library(ggplot2)

# Read in datasets
pvstate_df <- read_csv("../data/week1/house party vote share by district 1948-2020.csv")

margin = pvstate_df %>%
  filter(raceYear>=1980) %>%
  select(raceYear, State, RepVotes, DemVotes) %>%
  # summarize party vote share by state and year
  group_by(State,raceYear) %>%
  # get republican vote share
  mutate(R_votemargin_st = (sum(RepVotes))/
           sum(RepVotes + DemVotes) - (sum(DemVotes))/sum(RepVotes + DemVotes)) %>%
  select(raceYear,State, R_votemargin_st) %>%
  #filter only for midterm years
  rename(state = State)%>% distinct() %>% filter(raceYear == 2018 | 
                                                   raceYear == 2014 | 
                                                   raceYear == 2010 |
                                                   raceYear == 2006 | 
                                                   raceYear == 2002 | 
                                                   raceYear == 1998 |
                                                   raceYear == 1994 | 
                                                   raceYear == 1990 | 
                                                   raceYear == 1986 | 
                                                   raceYear == 1982)

#plotting Republican Win Share for Each Midterms
plot_usmap(data = margin, regions = "state", values = "R_votemargin_st") +
  facet_wrap(facets = raceYear~.) +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    name = "Vote Share Margin") + 
  labs(
    title = "Vote Share for Two Major Parties in Midterm Elections",
    subtitle = "Red corresponds to a larger vote share for Republicans and blue corresponds to a larger vote share for Democrats") + 
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 15),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 15))

ggsave("margin.png", height = 6, width = 12)

swing_state_df <- pvstate_df %>%
  #filter for years over 1976
  filter(raceYear >= 1976) %>%
  select(raceYear,State,RepVotes, DemVotes) %>%
  #groupby state and race year
  group_by(State,raceYear) %>%
  mutate(RepVotesTotal = sum(RepVotes),DemVotesTotal = sum(DemVotes)) %>%
  select(raceYear,State,RepVotesTotal,DemVotesTotal) %>% distinct() %>%
  #create "partisanship" variable that represents Republican vote share
  mutate(partisanship = RepVotesTotal/(RepVotesTotal + DemVotesTotal)) %>%
  group_by(State) %>%
  #create swing variable based off of partisanship and lagged 4 year prior partisanship by state
  mutate(swing = case_when(
    raceYear == 1986 ~ partisanship - partisanship[raceYear==1982],
    raceYear == 1990 ~ partisanship - partisanship[raceYear==1986],
    raceYear == 1994 ~ partisanship - partisanship[raceYear==1990],
    raceYear == 1998 ~ partisanship - partisanship[raceYear==1994],
    raceYear == 2002 ~ partisanship - partisanship[raceYear==1998],
    raceYear == 2006 ~ partisanship - partisanship[raceYear==2002],
    raceYear == 2010 ~ partisanship - partisanship[raceYear==2006],
    raceYear == 2014 ~ partisanship - partisanship[raceYear==2010],
    raceYear == 2018 ~ partisanship - partisanship[raceYear==2014]))%>%na.omit() 

colnames(swing_state_df) = c("raceYear","state","RepVotesTotal","DemVotesTotal","partisanship","swing")

#plot swing metric by state
plot_usmap(data = swing_state_df, regions = "state", values = "swing") +
  facet_wrap(facets = raceYear~.) +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       name = "Swing Margin") + 
  labs(
    title = "Swing States for U.S. Presidential Elections over Time",
    subtitle = "Positive Numbers corresponds to a larger vote share for Republicans compared to the last election") + 
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.text = element_text(size = 15),
        legend.title = element_text(size = 15),
        plot.title = element_text(size = 20),
        plot.subtitle = element_text(size = 15))

ggsave("swing.png", height = 6, width = 12)