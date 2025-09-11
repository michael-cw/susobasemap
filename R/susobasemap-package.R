#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @rawNamespace import(shiny, except=c(dataTableOutput, renderDataTable))
#' @importFrom DT datatable dataTableOutput DTOutput 
#' formatStyle renderDataTable renderDT
#' @importFrom waiter spin_fading_circles
#' @importFrom waiter use_waiter
#' @importFrom waiter waiter_hide
#' @importFrom waiter waiter_show
#' @importFrom sf st_area st_as_sf st_bbox st_crs st_drop_geometry st_geometry 
#' st_intersection st_is_longlat st_make_grid st_make_valid st_read st_sample 
#' st_sf st_transform st_write st_set_geometry st_sfc st_linestring st_cast
#' @importFrom leaflet addPolygons addScaleBar addTiles clearGroup clearShapes 
#' fitBounds highlightOptions leaflet leafletOptions leafletOutput 
#' leafletProxy renderLeaflet
#' @importFrom shinyalert shinyalert
#' @importFrom shinyjs disable disabled enable hidden hide show useShinyjs
#' @importFrom stats kmeans runif setNames
#' @importFrom stars write_stars st_set_bbox
#' @importFrom httr parse_url build_url GET content POST write_disk
#' @importFrom utils URLencode download.file head read.csv unzip
#' @importFrom lwgeom st_split
#' @importFrom SurveySolutionsAPI suso_get_api_key
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table :=
## usethis namespace: end
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "3.3.0")  {
  utils::globalVariables(c(
    ".", ".data",
    "fileName",
    "shapeType",
    "shapesCount",
    "UserName",
    "IsLocked",
    "text",
    "Reset",
    "Maps",
    "importDateUtc"
  )
  )
}