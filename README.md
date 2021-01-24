# ggraph-spatial-examples

Showcasing the possibilities of using `ggraph` with a layout that understands geographical space positions via `sf`. These examples use `sfnetworks` and my implementation of `ggraph` still under construction before a PR is possible, and can be installed as:

```r
remotes::install_github("loreabad6/ggraph")
```

## Airports in the U.S.

This example is inspired on this [wonderful blogpost on Network Visualization](https://kateto.net/sunbelt2019#overlaying-networks-on-geographic-maps), where I tried to recreate the last plot. 

![](figs/us_airports.png)

Code [here](code/airports.R).
