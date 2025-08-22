read_shapefile_from_zip <- function(zip_path) {
  exdir <- file.path(tempdir(), paste0("shp_", as.integer(runif(1, 1e6, 9e6))))
  dir.create(exdir, showWarnings = FALSE, recursive = TRUE)
  unzip(zipfile = zip_path, exdir = exdir)
  shp_files <- list.files(exdir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)
  validate(need(length(shp_files) > 0, "No .shp file found in the ZIP."))
  st_read(shp_files[[1]], quiet = TRUE)
}

zip_shapefile <- function(x, zipfile) {
  tmp <- file.path(tempdir(), paste0("out_", as.integer(runif(1, 1e6, 9e6))))
  dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
  layer_name <- "selection"
  st_write(x, dsn = file.path(tmp, paste0(layer_name, ".shp")),
           layer = layer_name, driver = "ESRI Shapefile", delete_dsn = TRUE, quiet = TRUE)
  old <- setwd(tmp); on.exit(setwd(old), add = TRUE)
  files <- list.files(".", full.names = FALSE)
  utils::zip(zipfile, files = files)
  zipfile
}