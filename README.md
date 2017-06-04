# airfareR
Flight fares are not constant. They change by numerous factors such as the destination, travel time, amounts of connections, etc. All these factors are constant for a certain flight. But interestingly, flight fares for a certain flight change with time. For example, it is suggested to book a flight at ~90 days before the flight (e.g., https://www.tnooz.com/article/3-things-expedia-has-learned-from-analyzing-airfare-data/). It's also suggested that searching at certain days or hours may slightly change the airfares. In this project, I show how to build a simple search engine using R, that keeps looking at flight costs and send an email notification if the price is lower than a certain amount.

The required R packages to run the code are rweyant's googleflight R package:
```{r}
devtools::install_github('rweyant/googleflights')
```
and the mailR package:
```{r}
install.packages("mailR dfdf
```




    
