
<!-- README.md is generated from README.Rmd. Please edit that file -->

<a href='https://docs.mysurvey.solutions/'>
<img src="man/figures/susospatial.png" align="right" height="139"
    style="float:right; height:139px;"/></a>

# R/Shiny Application for Spatial Resource Creation

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

<div align="justify">

An R Shiny application to process shapefiles and generate boundary files
and base maps for the World Bank’s Survey Solutions CAPI system.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Start the Application](#-start-the-application)
- [How it Works](#-how-it-works)

------------------------------------------------------------------------

## ✨ Features

- **Upload Shapefiles**: Easily upload your own zipped shapefiles.
- **Interactive Map**: View your polygons on an interactive Leaflet map.
- **Download Table**: Download the polygon data in tabular
  representation for further processing.
- **Select Polygons**:
  - Click directly on the map to select individual polygons.
  - Upload a `.csv` or `.txt` file containing a list of polygon IDs to
    select them in bulk.
- **Generate Survey Solutions Files**:
  - Create the boundary file in *ESRI shape file format* required for
    geography questions.
  - Generate `.tpk` or `.tif` base maps for offline use in the Survey
    Solutions Interviewer App.
- **Download Outputs**: Download the generated files directly from the
  application.
- **UPCOMING**: Send spatial resources directly to the Survey Solutions
  server through the API interface.

## Important Note

The tool leverages external base map tile providers. Please be aware
that these services have their own Terms of Use. Some may require a free
API key or have usage limits.

For the production of [Open Street
Map](https://www.openstreetmap.org/#map=5/38.00/-95.84), [ESRI world
imagery](https://www.arcgis.com/home/item.html?id=10df2279f9684e4a9f6a7f08febac2a9),
and [Mapbox](https://www.mapbox.com/) Maps, the tool uses the [R
basemaps package](https://github.com/16EAGLE/basemaps). Additionally
Mapbox maps also require a valid license key.

For the production of [ESRI .tpk
files](https://www.esri.com/en-us/arcgis/products/user-types/explore/creator),
you require a valid license key. The module uses its own API calls, and
credentials must be provided through the app.

We welcome your feedback! Please share your thoughts, suggestions, or
any issues you encounter in this thread.

## Installation

- Install R: <https://cran.r-project.org/mirrors.html> (version 4.1.1 or
  greater)

- Install R Studio: <https://rstudio.com/products/rstudio/download/>
  (version 1.2.5001-3 or newer)

- Make sure the *devtools* package is installed, if not install it with:

``` r
install.packages("devtools")
```

- After that install the actual package:

``` r
devtools::install_github("michael-cw/susobasemap")
```

## 🚀 Start the application

### From RStudio

``` r
library(susobasemap)
susobasemap::runBaseMapApp()
```

### On a Shiny Server

In case you are considering to run the application on a shiny server,
you just need to create the following app.R script in your shiny server
app directory:

``` r
library(susobasemap)
susobasemap::runBaseMapAppServer()
```

## How it works

\[TBA\]

</div>
