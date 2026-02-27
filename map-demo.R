library(sf)
library(tigris)
library(tidyverse)
library(ggrepel)

# 1a. Download Elementary and Unified school districts for California
ca_unified <- school_districts(state = "CA", type = "unified", cb = TRUE)
ca_elem <- school_districts(state = "CA", type = "elementary", cb = TRUE)
# 1b. Download towns > 10k pop
ca_places <- places(state = "CA", cb = TRUE) 
merced_towns <- ca_places %>%
  filter(NAME %in% c("Merced", "Atwater", "Livingston", "Los Banos", "Gustine", "Turlock")) %>%
  st_transform(st_crs(merced_districts))

# 2. Filter for Merced County districts
merced_districts <- 
  bind_rows(ca_unified, ca_elem) %>%
  filter(str_detect(NAME, 
    "Merced|Atwater|Livingston|Los Banos|Gustine|Hilmar|Delhi|Winton|McSwain|Planada|Le Grand|Plainsburg|Snelling|Ballico|El Nido|Weaver|Dos Palos")
  )

# 3. Assign Districts to the 5 Trustee Areas
merced_districts <- merced_districts %>%
  mutate(
    Trustee_Area = factor(
      case_when(
        NAME %in% c("Merced City Elementary School District", 
                    "Weaver Union Elementary School District") ~ "Area 1",
        NAME %in% c("Planada Elementary School District", 
                    "Le Grand Union Elementary School District", 
                    "Plainsburg Union Elementary School District") ~ "Area 2",
        NAME %in% c("Snelling-Merced Falls Union Elementary School District", 
                    "Merced River Union Elementary School District", 
                    "Winton School District", 
                    "Atwater Elementary School District", 
                    "McSwain Union Elementary School District") ~ "Area 3",
        NAME %in% c("Ballico-Cressey Elementary School District", 
                    "Delhi Unified School District", 
                    "Livingston Union School District", 
                    "Hilmar Unified School District", 
                    "Gustine Unified School District") ~ "Area 4",
        NAME %in% c("El Nido Elementary School District", 
                    "Los Banos Unified School District", 
                    "Dos Palos-Oro Loma Joint Unified School District") ~ "Area 5",
        TRUE ~ "Other"
      ), 
      levels = c("Area 1", "Area 2", "Area 3", "Area 4", "Area 5", "Other")
    )
  )

# 4. Create the Trustee Areas
trustee_areas <- merced_districts %>%
  group_by(Trustee_Area) %>%
  summarize(geometry = st_union(geometry)) %>%
  filter(Trustee_Area != "Other")

# 5. Plot with ggrepel
p <- ggplot() +
  # 1. Fill the Trustee Areas
  geom_sf(data = trustee_areas, aes(fill = Trustee_Area), alpha = 0.6) +
  
  # 2. Draw District boundaries
  geom_sf(data = merced_districts, color = "black", alpha = 0.5, linewidth = 0.1, fill = NA) +

  # Town Points & Labels
  geom_sf(data = st_centroid(merced_towns), size = 1.5, color = "red") +
  geom_text_repel(
    data = merced_towns,
    aes(label = NAME, geometry = geometry),
    stat = "sf_coordinates", 
    size = 3.5, 
    color = "red", 
    fontface = "italic", 
    bg.color = "white",
    bg.r = 0.1
  ) +
  
  # 3. Label District Names (Cleaned for clarity)
  geom_text_repel(
    data = merced_districts,
    aes(label = str_remove_all(NAME, " (Elementary|Unified|Union|Joint|School District)"), 
        geometry = geometry),
    stat = "sf_coordinates",
    size = 3,
    fontface = "bold",
    color = "black",
    box.padding = 0.3,
    max.overlaps = 15
  ) +
  
  scale_fill_manual(values = c("Area 1" = "magenta", "Area 2" = "green", 
                               "Area 3" = "orange", "Area 4" = "yellow", 
                               "Area 5" = "skyblue")) +
  theme_minimal() + 
  labs(
    title = "Map of Merced County Districts and Trustee Areas 1-5",
    x = "Longitude",
    y = "Latitude"
  )

print(p)
