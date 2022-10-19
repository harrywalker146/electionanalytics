**The Ground Game - Week 6**

The “Ground Game”, Political Campaigns’ strategy to mobilize and
persuade voters is critically important when trying to win elections.
While persuading voters is becoming increasingly difficult as the
country becomes more partisan, both political parties are realizing that
success is predicated on turnout. There have been many large scale
“get-out-the-vote” campaigns in recent years. For example, in 2018
during the Gubnatorial race, Stacey Abrams’s Campaign helped register
hundreds of thousands of
[voters](https://www.independent.co.uk/voices/georgia-election-stacey-abrams-biden-b1675670.html)

From the plot below, we can see that congressional districts, even in
the same state, have very different levels of turnout. For example, in
Texas, we can see that rural regions have lower turnout (corresponding
to purple and blue shades). Urban areas have higher turnout, indicated
by brighter shades of red. At first glance, this map seems to confirm an
assumption both the Democrats and Republicans operate under: higher
turnout helps the Democrats. This is because in rural states that are
more conservative, turnout appears to be lower than urban areas.
However, this concept may be misleading. For example, even though a
rural, conservative district may have low turnout, there may not
necessarily be liberal people who do not vote. Instead, it is possible
that the district is politically homogenous, and higher turnout would
lead to more conservatives voting. We can see this from the plot of
contested races in 2018 compared to turnout. There is only a small
linear relationship between turnout and Democratic vote share, meaning
increased turnout only has a small positive relationship with Democratic
success.

    ## Reading layer `districts114' from data source 
    ##   `/private/var/folders/ry/qlvkbbt57l9_3tv9fw638k3m0000gn/T/RtmpTXIJCy/districtShapes/districts114.shp' 
    ##   using driver `ESRI Shapefile'
    ## Simple feature collection with 436 features and 15 fields (with 1 geometry empty)
    ## Geometry type: MULTIPOLYGON
    ## Dimension:     XY
    ## Bounding box:  xmin: -179.1473 ymin: 18.91383 xmax: 179.7785 ymax: 71.35256
    ## Geodetic CRS:  NAD83

<img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

<img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

``` r
train_data = polls_cvap_vp_df %>% 
  filter(year == '2018' | year == '2020') %>%
  group_by(st_cd_fips, state) %>% 
  filter(n() > 1) %>% # Filtering out single data rows
  group_nest() %>% 
  mutate(data = map(data, ~unnest(., cols = c())))


models = train_data %>% 
  mutate(model_dem = map(data, ~glm(cbind(DemVotes, cvap-DemVotes) ~ DEM, data = .x, family="binomial"))) %>% 
  mutate(model_rep = map(data, ~glm(cbind(RepVotes, cvap-RepVotes) ~ REP, data = .x, family="binomial"))) %>% 
  select(-data)

model_results <- models %>% 
  mutate(standard_error_dem = map_dbl(model_dem, ~summary(.x)$coefficients[, 2][2]),
         standard_error_rep = map_dbl(model_rep, ~summary(.x)$coefficients[, 2][2])
         )
```

*Building a Model* While turnout may not be useful in a linear model, we
can use recent polls as a predictor and then simulate turnout for each
party. In this method, we make a generalized linear model for each
district, with every recent poll as an observation. Doing 10,000
simulations for each district, using the poll results as the probability
of someone voting for a Democrat or Republican, we can get an average
margin of victory in each district. From the histograms below, we can
see that there are a wide range of outcomes for each seat that we have
data for (32 districts in total). Unfortunately, when observing these
results, we can see that this model may be problematic. For example, in
many instances, neither party gets close to 50% of the vote. Obviously,
this does not make sense because in most cases, there is only a Democrat
and Republican candidate. While we will eventually predict all the house
seats, in our district-level map, it probably makes sense to ignore
these results for now. While simulation may be a good idea as we
approach our final prediction, turnout is clearly not a useful
predictor.

<img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-3.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-4.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-5.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-6.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-7.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-8.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-9.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-10.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-11.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-12.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-13.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-14.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-15.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-16.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-17.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-18.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-19.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-20.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-21.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-22.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-23.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-24.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-25.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-26.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-27.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-28.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-29.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-30.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-31.png" style="display: block; margin: auto;" /><img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-7-32.png" style="display: block; margin: auto;" />

| state          | st_cd_fips |  pred_dem |  pred_rep | mean_democrat_win_margin |
|:---------------|:-----------|----------:|----------:|-------------------------:|
| California     | 0622       | 0.2220354 | 0.2906073 |               -20.458891 |
| Florida        | 1213       | 0.3686113 | 0.3263571 |                10.128388 |
| Florida        | 1227       | 0.3166663 | 0.2684526 |                 8.771930 |
| Illinois       | 1713       | 0.2593444 | 0.3457982 |               -15.630252 |
| Iowa           | 1901       | 0.3046030 | 0.2418445 |                 9.760589 |
| Iowa           | 1902       | 0.3064553 | 0.2736335 |                 6.049822 |
| Iowa           | 1903       | 0.3158108 | 0.2550524 |                14.532872 |
| Kansas         | 2003       | 0.3521102 | 0.3032105 |                 9.502262 |
| Maine          | 2301       | 0.4947502 | 0.2556307 |                32.620321 |
| Maine          | 2302       | 0.3014435 | 0.3196930 |                 2.819237 |
| Michigan       | 2603       | 0.3459113 | 0.3894398 |                -6.364922 |
| Michigan       | 2608       | 0.3158895 | 0.2919566 |                 5.331179 |
| Minnesota      | 2701       | 0.3234932 | 0.3771824 |                -4.885058 |
| Minnesota      | 2702       | 0.3653585 | 0.3655082 |                 4.324324 |
| Minnesota      | 2703       | 0.3995444 | 0.3174953 |                10.072993 |
| Nebraska       | 3102       | 0.3017581 | 0.5467812 |               -31.177829 |
| Nevada         | 3201       | 0.2462418 | 0.1148674 |                37.688442 |
| Nevada         | 3202       | 0.2363129 | 0.3294454 |               -11.545293 |
| Nevada         | 3203       | 0.2635670 | 0.2175362 |                11.344538 |
| New Jersey     | 3403       | 0.2823976 | 0.2747623 |                 7.826087 |
| New Jersey     | 3407       | 0.3267295 | 0.3243389 |                -5.070423 |
| New Mexico     | 3502       | 0.2285342 | 0.1719934 |                14.081146 |
| New York       | 3611       | 0.2166927 | 0.1432826 |                14.454277 |
| New York       | 3619       | 0.2680315 | 0.2408428 |                 4.077670 |
| North Carolina | 3711       | 0.3166000 | 0.4075260 |               -15.659341 |
| North Carolina | 3713       | 0.2307081 | 0.2610819 |                -6.976744 |
| Ohio           | 3901       | 0.2767639 | 0.2901091 |                -8.289242 |
| Pennsylvania   | 4201       | 0.3139580 | 0.3282828 |                -2.523659 |
| Pennsylvania   | 4208       | 0.3152016 | 0.1779728 |                25.106383 |
| Pennsylvania   | 4217       | 0.4006544 | 0.3826833 |                 7.341772 |
| Virginia       | 5102       | 0.2633871 | 0.2366750 |                 6.358382 |
| Washington     | 5308       | 0.3240912 | 0.2942258 |                -2.597403 |

<img src="/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/Users/hwalker/Desktop/Senior Fall/Election Analytics/electionanalytics/posts/week6_files/figure-markdown_github/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

*Looking Ahead*

Going forward, I think pooling all the past congressional races (for
which we have data) makes the most sense for predicting the upcoming
midterms. While grouping the models by district makes sense in theory, I
have not added any data that helps describe the characteristics of a
district. For example, we have yet to incorporate levels of education,
or how rural or urban the district is. Instead, like in this exercise, I
made a model for each district, but each one had very few observations,
leading to results that did not make sense.
