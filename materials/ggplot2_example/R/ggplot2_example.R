# load libraries
library(dplyr)
library(readr)
library(magrittr)
library(RcppRoll)
library(ggplot2)
library(ggrepel)
library(scales)
library(gghighlight)
library(gganimate)

# download county-level aggregated data from NY Times
nyt_data = 'https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv' %>% url %>% read_csv

# filter to get Massachusetts data
ma_nyt = nyt_data %>% filter(state == 'Massachusetts')

# reverse the cumulative sum of covid-19 counts and name that column new_cases
ma_nyt %<>% group_by(county) %>% arrange(date) %>% mutate(new_cases = c(cases[1], diff(cases))) %>% ungroup()

# take a weekly rolling sum of new_cases
ma_week = ma_nyt %>% group_by(county) %>% arrange(date) %>% mutate(week_sum = roll_sum(new_cases, 7, align = 'right', fill = NA)) %>% ungroup()

# set minimum number of total confirmed cases to 10
ma_week %<>% filter(cases >= 10 & !is.na(week_sum))

# remove data where county is unknown or Martha's Vineyard or Nantucket
ma_week %<>% filter(!county %in% c('Unknown', 'Dukes', 'Nantucket'))

# plot
ggplot(data = ma_week, aes(x = cases, y = week_sum, group = county)) +
  geom_line(color = 'grey') +
  scale_x_log10() +
  scale_y_log10() +
  theme_bw() +
  xlab('total confirmed cases') + 
  ylab('new confirmed cases (in the past week)') + 
  geom_text_repel(data = ma_week %>% filter(date == max(date)), aes(label = county)) +
  geom_point(data = ma_week %>% filter(date == max(date)), color = 'red') 

# yet another way to plot
ggplot(data = ma_week, aes(x = cases, y = week_sum, group = county)) +
  geom_line() + 
  geom_point(data = ma_week %>% filter(date == max(date)), size = 2, color = 'red') +
  facet_wrap(~county) + 
  gghighlight(county == county, use_direct_label = FALSE) +
  scale_x_log10(labels = trans_format('log10', math_format(10^.x))) +
  scale_y_log10(labels = trans_format('log10', math_format(10^.x))) +
  theme_bw() +
  xlab('total confirmed cases') + 
  ylab('new confirmed cases (in the past week)')

# animate
anime = ggplot(data = ma_week, aes(x = cases, y = week_sum, group = county)) + 
    geom_line(color = 'grey') +
    geom_point(size = 2, color = 'red') +
    geom_text_repel(aes(label = county)) +
    transition_reveal(date) +
    scale_x_log10() +
    scale_y_log10() +
    theme_bw() +
    xlab('total confirmed cases') + 
    ylab('new confirmed cases (in the past week)') + 
    labs(title = "Date: {format(frame_along, '%Y-%m-%d')}")

anime
