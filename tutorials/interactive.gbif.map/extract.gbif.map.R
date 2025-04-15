# Load Required Libraries
library(rgbif)        # GBIF data
library(kableExtra)   # Tables
library(dplyr)        # Data wrangling
library(leaflet)      # Interactive maps
library(readxl)       # Read Excel
library(elevatr)      # Elevation data
library(sf)           # Spatial features
library(htmlwidgets) # To store html map


######## DATA from GBIF ########
# Function: Retrieve GBIF occurrence data with coordinates, image, and get elevation
get_gbif_data_with_altitude_photos <- function(species_name, limit = 50) {
  # Query GBIF for occurrence data
  occurrences <- occ_search(
    scientificName = species_name,
    hasCoordinate = TRUE,
    hasGeospatialIssue = FALSE,
    limit = limit
  )
  
  # Extract occurrence and media data
  occurrences_data <- occurrences$data
  occurrences_media <- occurrences$media
  
  # Extract image links (if any) for each record
  occurrences_data$Image <- sapply(1:nrow(occurrences_data), function(y) {
    tryCatch(occurrences_media[[y]][[as.character(occurrences_data$key[y])]][[1]]$identifier, 
             error = function(e) NA)
  })
  
  # Clean and format the GBIF records, 
  # take whatever columns you are interested, there are 165 
  records <- occurrences_data %>%
    transmute(
      Number = row_number(),
      ID = key,
      Scientific_Name = scientificName,
      Latitude = decimalLatitude,
      Longitude = decimalLongitude,
      Country = coalesce(country, "Unknown"),
      State_Province = coalesce(stateProvince, "Unknown"),
      Date = as.Date(eventDate),
      Record_Type = coalesce(basisOfRecord, "Unknown"),
      Source = coalesce(datasetName, "Unknown"),
      InstitutionCode = coalesce(institutionCode, "Unknown"),
      Observer = coalesce(recordedBy, "Unknown"),
      Sex = coalesce(sex, "Unknown"),
      Life_Stage = coalesce(lifeStage, "Unknown"),
      GBIF_Link = paste0("https://www.gbif.org/occurrence/", ID),
      Image = Image,
      SourceType = "GBIF"
    ) %>%
    filter(!is.na(Latitude) & !is.na(Longitude))
  
  # Convert to spatial object and fetch elevation
  locations <- st_as_sf(records, coords = c("Longitude", "Latitude"), crs = 4326)
  elevation_data <- get_elev_point(locations, src = "aws")
  records$Altitude <- elevation_data$elevation
  
  return(records)
}


# Example usage, set a limit of occurrences to download
species_name <- "Euphydryas editha"
gbif_data <- get_gbif_data_with_altitude_photos(species_name, limit = 5000)
str(gbif_data)

# Visualise first 10 rows in HTML table
gbif_data %>%
  head(10) %>%
  kable(format = "html", escape = FALSE) %>%
  kable_styling("striped", full_width = FALSE)

######## MAPS #######

### Visualise on an interactive map, no photos
# pop ups will have info from different columns, edit as you wish
leaflet(gbif_data) %>%
  addTiles() %>%
  addCircleMarkers(
    ~Longitude, ~Latitude,
    color = ~ifelse(SourceType == "GBIF", "red", "blue"),
    radius = 4, stroke = FALSE, fillOpacity = 0.7,
    popup = ~paste0("<b>Scientific Name:</b> ", Scientific_Name,
                    "<br><b>Date:</b> ", format(Date, "%Y-%m-%d"),
                    "<br><b>Altitude:</b> ", round(Altitude, 2), " m",
                    "<br><b>InstitutionCode:</b> ", InstitutionCode,
                    "<br><b>Source:</b> ", SourceType,
                    ifelse(SourceType == "GBIF", paste0("<br><a href='", GBIF_Link, "' target='_blank'>View on GBIF</a>"), ""))
  )

### Visualise on an interactive map, with photos
# Plot all data on the map
map.gbif.photos <- leaflet(gbif_data) %>%
  addTiles() %>%
  addCircleMarkers(
    ~Longitude, ~Latitude,
    color = ~case_when(
      SourceType == "GBIF" ~ "red"
    ),  
    radius = 4, stroke = FALSE, fillOpacity = 0.7,
    popup = ~paste0("<b>Scientific Name:</b> ", Scientific_Name,
                    "<br><b>Altitude:</b> ", round(Altitude, 2), " m",
                    "<br><b>InstitutionCode:</b> ", InstitutionCode,
                    "<br><b>Date:</b> ", Date,
                    "<br><b>Source:</b> ", SourceType,
                    ifelse(SourceType == "GBIF", paste0("<br><a href='", GBIF_Link, "' target='_blank'>View on GBIF</a>"), ""),
                    ifelse(!is.na(Image), paste0("<br><img src='", Image, "' width='150' height='150'>"), ""))
  ); map.gbif.photos

# Save to HTML
saveWidget(map.gbif.photos, file = "map.gbif.photos.html", selfcontained = TRUE)


### Visualise on an interactive map, with photos and your own data
# load your dataset (here we just make up toy dataset with localities)
set.seed(123)  # for reproducibility

# Create 30 random coordinates roughly within California's bounds
toy_data <- data.frame(
  Longitude = runif(30, min = -124.4, max = -114.1),
  Latitude = runif(30, min = 32.5, max = 42.0),
  Scientific_Name = "test",
  Altitude = "test",
  Date = "test",
  SourceType = "test"
); head(toy_data)

# plot gbif and toy dataset
map_with_toy <- leaflet(gbif_data) %>%
  addTiles() %>%
  addCircleMarkers(
    data = gbif_data,
    ~Longitude, ~Latitude,
    color = ~case_when(
      SourceType == "GBIF" ~ "red"
    ),  
    radius = 4, stroke = FALSE, fillOpacity = 0.7,
    popup = ~paste0("<b>Scientific Name:</b> ", Scientific_Name,
                    "<br><b>Altitude:</b> ", round(as.numeric(Altitude), 2), " m",
                    "<br><b>InstitutionCode:</b> ", InstitutionCode,
                    "<br><b>Date:</b> ", Date,
                    "<br><b>Source:</b> ", SourceType,
                    ifelse(SourceType == "GBIF", paste0("<br><a href='", GBIF_Link, "' target='_blank'>View on GBIF</a>"), ""),
                    ifelse(!is.na(Image), paste0("<br><img src='", Image, "' width='150' height='150'>"), ""))
  ) %>%
  addCircleMarkers(
    data = toy_data,
    ~Longitude, ~Latitude,
    color = "yellow",
    radius = 6, stroke = FALSE, fillOpacity = 0.8,
    popup = ~paste0("<b>Scientific Name:</b> ", Scientific_Name,
                    "<br><b>Altitude:</b> ", Altitude,
                    "<br><b>Date:</b> ", Date,
                    "<br><b>Source:</b> ", SourceType)
  ); map_with_toy

# Save to HTML
saveWidget(map_with_toy, file = "map.gbif.photos.toydata.html", selfcontained = TRUE)

