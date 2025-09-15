# Function to read single or multiple shape files

read_shapefile_from_zip <- function(zip_path) {
  exdir <- file.path(tempdir(), paste0("shp_", as.integer(runif(1, 1e6, 9e6))))
  dir.create(exdir, showWarnings = FALSE, recursive = TRUE)
  unzip(zipfile = zip_path, exdir = exdir)
  shp_files <- list.files(exdir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)
  nshp <- length(shp_files)
  
  # If more than one shapefile, put shape files together into one.
  if (nshp == 0) {
    showModal(modalDialog(
      title = "Wrong Format!",
      "Your file is not provided in the correct format (ESRI Shapefile, Single Folder). 
      Please check and upload again",
      easyClose = TRUE,
      footer = NULL
    ))
  } else if (nshp > 1) {
    showModal(modalDialog(
      title = "More than one file!",
      "You uploaded more than one boundary files. Your files will be aggregated to a single file",
      easyClose = TRUE,
      footer = NULL
    ))
  }
  validate(need(nshp > 0, "No .shp file found in the ZIP."))
  if (nshp == 1) {
    st_read(shp_files, quiet = TRUE)
  } else if (nshp > 1) {
    tmp.shplist <- vector("list", length = nshp)
    for (i in 1:nshp) {
      tmp.shplist[[i]] <- sf::st_read(shp_files[i], quiet = TRUE)
    }
    do.call(rbind, tmp.shplist)
  }
  
}

# Function to zip shape file

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

# Function to create single polygon from polygons with same id
union_shapefile<-function(sfobject, idvar) {
  lid<-length(unique(sfobject[[idvar]]))
  if(lid<nrow(sfobject)) {
    sfobject <- sfobject %>% 
      dplyr::group_by(
        .data[[idvar]]
      ) %>% 
      dplyr::summarise(
        count = dplyr::n()
      )
    # ADD .lid after
    sfobject$.lid<-1:nrow(sfobject)
  }
  return(sfobject)
}




