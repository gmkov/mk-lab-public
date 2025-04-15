Written by Edgar Signe and Gabriela Montejo-Kovacevich

## 🌍 TL;DR Example output of Interactive GBIF Map

[Click here to view the live interactive map](https://gmkov.github.io/mk-lab-public/map.gbif.photos.html)


# 🗘️ Interactive GBIF Map Tutorial

This tutorial demonstrates how to download GBIF occurrence records, enrich them with elevation and metadata, and render an interactive map using `leaflet` in R. It includes optional image previews and mock or real data integration.

---

## 📂 What's in this folder?

| File | Description |
|------|-------------|
| `output/map.gbif.photos.html` | Fully rendered interactive map (with images from GBIF). |
| `interactive.gbif.map.Rmd` | Source R Markdown file that generates the HTML map. |
| `interactive.gbif.map.R` | R script to generate HTML map. |
| `output/` | Other map outputs. |

---

## 🧪 What this tutorial does

1. Queries GBIF for species occurrences using `rgbif`
2. Filters valid records with coordinates and image links
3. Retrieves elevation data via `elevatr`
4. Visualises points using `leaflet`
5. Adds mock data points (optional)
6. Outputs a self-contained HTML file

---

## 🖥️ How to run it

1. Open `interactive.gbif.map.Rmd` in **RStudio**
2. Install required R packages:

```r
install.packages(c("rgbif", "leaflet", "dplyr", "sf", "elevatr", "kableExtra", "htmlwidgets"))
```

3. Set the working directory to the folder containing the `.Rmd`
4. Click **Knit > Knit to HTML**

---

## 🌐 How to view the map

Download and open html map files in a browser, e.g.: map.gbif.photos.html

As GitHub Pages is enabled, one example can be viewed [here](https://gmkov.github.io/mk-lab-public/map.gbif.photos.html) 


---

## 🛠️ Optional extensions

- Change the species (currently `Euphydryas editha`) to another GBIF-registered name
- Add your own occurrence data or locality points
- Customise leaflet styling, popup content, or colours

---

## ℹ️ Credits

Built with R, `rgbif`, and `leaflet`. Maintained by [@gmkov](https://github.com/gmkov).
