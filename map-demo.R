# Load libraries
library(sf)
library(tigris)
library(tidyverse)

# 1. Download Elementary and Unified school districts for California
# (Merced has a mix of both types)
ca_unified <- school_districts(state = "CA", type = "unified", cb = TRUE)
ca_elem <- school_districts(state = "CA", type = "elementary", cb = TRUE)

# 2. Filter for Merced County districts
# We filter by Name based on the labels in your image
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

# 4. Create the dissolved Trustee Areas
trustee_areas <- 
  merced_districts %>%
  group_by(Trustee_Area) %>%
  summarize(geometry = st_union(geometry))

trustee_areas$Trustee_Area <- 
  factor(trustee_areas$Trustee_Area, 
         levels = c("Area 1", "Area 2", "Area 3", "Area 4", "Area 5"))

# 5. Plot the result
p <- ggplot() +
  geom_sf(data = trustee_areas, aes(fill = Trustee_Area), alpha = 0.6) +
  geom_sf(data = merced_districts, color = "white", size = 0.2, fill = NA) +
  scale_fill_manual(values = c("Area 1" = "magenta", "Area 2" = "green", 
                               "Area 3" = "orange", "Area 4" = "yellow", 
                               "Area 5" = "skyblue")) +
  theme_minimal() + labs(title = "Merced County Trustee Boundary Plan B
                         (Approximate)")

print(p)
