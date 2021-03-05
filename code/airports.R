#' - **Author:** Lorena Abad
#' - **Date:** January 2021
#' - **Description:** Recreating the spatial network visualization example from Katherine Ognyanova.
#' - **Reference:** https://kateto.net/sunbelt2019#overlaying-networks-on-geographic-maps

# Get data
airports = read.csv("https://raw.githubusercontent.com/kateto/R-Network-Visualization-Workshop/master/Data%20files/Dataset3-Airlines-NODES.csv")
flights = read.csv("https://raw.githubusercontent.com/kateto/R-Network-Visualization-Workshop/master/Data%20files/Dataset3-Airlines-EDGES.csv")

# Convert to network
library(sf)
library(sfnetworks)
library(tidygraph)
nodes = st_as_sf(airports, coords = c("longitude", "latitude"), crs = 4326) %>%
  mutate(ID = as.character(ID))
edges = flights %>%
  mutate(from = as.character(Source), to = as.character(Target))
net = sfnetwork(nodes, edges, node_key = "ID") %>%
  st_transform(2163)

# Get background country data
library(rnaturalearth)
usa = ne_countries(scale = "medium", country = "United States of America", returnclass = "sf") %>%
  st_cast("POLYGON") %>%
  mutate(area = st_area(geometry)) %>%
  filter(area == max(area)) %>%
  st_transform(2163)

# Plot
# remotes::install_github("loreabad6/ggraph")
library(ggplot2)
library(ggraph)
g = net %>%
  filter(centrality_degree() > 10) %>%
  ggraph(layout = 'sf') +
  geom_sf(data = usa, color = NA, fill = "grey30") +
  geom_edge_arc(aes(width = Freq, color = Freq), alpha = 0.7, strength = 0.2) +
  geom_node_sf(aes(size = Visits), shape = 21, color = "white", fill = "orange") +
  scale_edge_color_gradient("Connection frequency", low = "orange red", high = "orange") +
  scale_size("No. of visits", range = c(1, 5)) +
  scale_edge_width("Connection frequency", range = c(0.1, 0.7)) +
  scale_edge_alpha(guide = 'none') +
  guides(
    edge_color = guide_legend(override.aes = list(shape = NA)),
    width = guide_legend(override.aes = list(shape = NA)),
    size = guide_legend(order = 1)
  ) +
  labs(title = "Busiest Airports in the U.S.") +
  theme(
    text = element_text(color = 'white', size = 9),
    panel.background = element_rect(fill = "grey10"),
    plot.background = element_rect(fill = "grey10"),
    legend.position = 'bottom',
    legend.spacing = grid::unit(1, 'mm'),
    legend.key = element_rect(fill = 'transparent'),
    legend.background = element_rect(fill = 'transparent'),
    legend.box = 'vertical', legend.direction = 'horizontal'
  )
ggsave(g, filename = "figs/us_airports.png", dpi = 300,
       device = "png", width = 10.75, height = 10, units = "cm")
knitr::plot_crop("figs/us_airports.png")
