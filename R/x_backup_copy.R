## Income  {data-height=350}

### Income domain regional overview {.first-box}
```{r}
charts_deprivation$barchart$Income[["{{x}}"]]
```

### Income domain regional map {.first-box}
```{r}
charts_deprivation$region_maps$Income[["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Income[["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps$Income[["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps$Income[["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps$Income[['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Employment  {data-height=350}

### Employment domain regional overview {.first-box}
```{r}
charts_deprivation$barchart$Employment[["{{x}}"]]
```

### Employment domain regional map {.first-box}
```{r}
charts_deprivation$region_maps$Employment[["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Employment[["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps$Employment[["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps$Employment[["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps$Employment[['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Health  {data-height=350}

### Health domain regional overview {.first-box}
```{r}
charts_deprivation$barchart$Health[["{{x}}"]]
```

### Health domain regional map {.first-box}
```{r}
charts_deprivation$region_maps$Health[["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps$Health[["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps$Health[["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps$Health[["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps$Health[['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Education  {data-height=350}

### Education domain regional overview {.first-box}
```{r}
charts_deprivation$barchart[["Education, Skills and Training"]][["{{x}}"]]
```

### Education domain regional map {.first-box}
```{r}
charts_deprivation$region_maps[["Education, Skills and Training"]][["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps[["Education, Skills and Training"]][["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps[['Education, Skills and Training']][['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Housing {data-height=350}

### Housing domain regional overview {.first-box}
```{r}
charts_deprivation$barchart[['Housing']][["{{x}}"]]
```

### Housing domain regional map {.first-box}
```{r}
charts_deprivation$region_maps[['Housing']][["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Housing']][["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps[['Housing']][["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps[['Housing']][["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps[['Housing']][['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Crime {data-height=350}

### Crime domain regional overview {.first-box}
```{r}
charts_deprivation$barchart[['Crime']][["{{x}}"]]
```

### Crime domain regional map {.first-box}
```{r}
charts_deprivation$region_maps[['Crime']][["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Crime']][["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps[['Crime']][["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps[['Crime']][["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps[['Crime']][['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```

## Access {data-height=350}

### Access domain regional overview {.first-box}
```{r}
charts_deprivation$barchart[['Access to Services']][["{{x}}"]]
```

### Access domain regional map {.first-box}
```{r}
charts_deprivation$region_maps[['Access to Services']][["{{x}}"]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[1]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[2]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[3]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[4]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[5]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[6]]
```

## Row {data-height=300}

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[7]]
```

### Constituency {.no-title}
```{r}
charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[8]]
```

### Constituency {.no-title}
```{r}
try(charts_deprivation$const_maps[['Access to Services']][["{{x}}"]][[9]], silent = TRUE)
```

```{r}
# Some regions have 10 constituencies and need another row for charts 
is10 <- length(charts_deprivation$const_maps[['Access to Services']][["{{x}}"]]) == 10
```

```{r eval=is10, results = 'asis'}

out <- list(knitr::knit_expand(text = "## Row 5 {data-height=300} \n"),
            knitr::knit_expand(text = "### Constituency {data-width=1 .no-title} \n"),
            knitr::knit_expand(text = "`r charts_deprivation$const_maps[['Access to Services']][['{{x}}']][[10]]` \n"),
            knitr::knit_expand(text = "### Empty box {data-width=2 .no-title .empty-box}"))

res = knitr::knit_child(text = unlist(out), quiet = TRUE)
cat(res, sep = '\n')

```















