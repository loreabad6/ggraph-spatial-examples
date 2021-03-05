#' - **Author:** Lorena Abad
#' - **Date:** March 2021
#' - **Description:** Recreating "THREE WAYS OF VISUALIZING A GRAPH ON A MAP" from Markus Konrad
#' - **Reference:** https://datascience.blog.wzb.eu/2018/05/31/three-ways-of-visualizing-a-graph-on-a-map/
#' - **Note:** Several code sections were copied from
#'             https://gist.github.com/internaut/a9a274c72181eaa7f5c3ab3a5f54b996
#'             to recreate the maps on the blog.

library(tidyverse)
# remotes::install_github("luukvdmeer/sfnetworks")
library(sfnetworks)
library(sf)
# remotes::install_github("loreabad6/ggraph")
library(ggraph)
library(tidygraph)

# -------------------------------------- #
# Preparation: generate some random data #
# -------------------------------------- #

set.seed(123)

N_EDGES_PER_NODE_MIN = 1
N_EDGES_PER_NODE_MAX = 4
N_CATEGORIES = 4

country_coords_txt = "
 1     3.00000  28.00000       Algeria
 2    54.00000  24.00000           UAE
 3   139.75309  35.68536         Japan
 4    45.00000  25.00000 'Saudi Arabia'
 5    9.00000   34.00000       Tunisia
 6     5.75000  52.50000   Netherlands
 7   103.80000   1.36667     Singapore
 8   124.10000  -8.36667         Korea
 9    -2.69531  54.75844            UK
10    34.91155  39.05901        Turkey
11  -113.64258  60.10867        Canada
12    77.00000  20.00000         India
13    25.00000  46.00000       Romania
14   135.00000 -25.00000     Australia
15    10.00000  62.00000        Norway"

# nodes come from the above table and contain geo-coordinates for some
# randomly picked countries
nodes = read.delim(text = country_coords_txt, header = FALSE,
                    quote = "'", sep = "",
                    col.names = c('id', 'lon', 'lat', 'name'))

### Convert nodes to an `sf` object ###
nodes_sf = st_as_sf(nodes, coords = c("lon", "lat"), crs = 4326)

# edges: create random connections between countries (nodes)
edges = map_dfr(nodes$id, function(id) {
  n = floor(runif(1, N_EDGES_PER_NODE_MIN, N_EDGES_PER_NODE_MAX+1))
  to = sample(1:max(nodes$id), n, replace = FALSE)
  to = to[to != id]
  categories = sample(1:N_CATEGORIES, length(to), replace = TRUE)
  weights = runif(length(to))
  tibble(from = id, to = to, weight = weights, category = categories)
})

edges = edges %>% mutate(category = as.factor(category))

### Create `sfnetwork` object ###
g = sfnetwork(nodes_sf, edges, directed = F)

# common plot theme
maptheme = theme(panel.grid = element_blank()) +
  theme(axis.text = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(axis.title = element_blank()) +
  theme(legend.position = "bottom") +
  theme(panel.grid = element_blank()) +
  theme(panel.background = element_rect(fill = "#596673")) +
  theme(plot.margin = unit(c(0, 0, 0.5, 0), 'cm'))

# common polygon geom for plotting the country shapes
### Obtain country shapes from rnaturalearth instead of world data ###
country_shapes = geom_sf(
  data = rnaturalearth::ne_countries(scale = 110, returnclass = "sf"),
  fill = "#CECECE", color = "#515151", size = 0.15
)

### plot with sfnetworks and ggraph ###
ggraph(g, "sf") +
  country_shapes +
  geom_edge_arc(
    aes(color = category, edge_width = weight),
    strength = 0.33, alpha = 0.5
    ) +
  scale_edge_width_continuous(range = c(0.5, 2),             # scale for edge widths
                              guide = FALSE) +
  geom_node_point(aes(size = centrality_degree()), shape = 21,            # draw nodes
                  fill = "white", color = "black",
                  stroke = 0.5) +
  scale_size_continuous(range = c(1, 6), guide = FALSE) +    # scale for node widths
  geom_node_text(aes(label = name), repel = TRUE, size = 3,
                 color = "white", fontface = "bold") +
  maptheme

ggsave(filename = "figs/graph_on_a_map.png", dpi = 300,
       device = "png", width = 25, height = 20, units = "cm")
knitr::plot_crop("figs/graph_on_a_map.png")
