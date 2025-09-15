# ` Shiny server Survey Solutions App for Spatail Resource Creation
#'
#'
#'
#' @keywords internal
#' @noRd



###########
main_server <- function(input, output, session) {
  ## START UP MODAL FOR MAPKEY AND USER
  startupkeyusr <- startupModalSRV("startupModal", ,
                                   useronly = TRUE,
                                   welcometitle = "Welcome to the Survey Solutions Spatial Resource Creation Application!")
  
  ## Create APP dir for storage of resources
  ###############################################
  fp <- reactiveVal(NULL)
  fpp <- reactiveVal(NULL)
  fppTPK <- reactiveVal(NULL)
  fppTPKerror <- reactiveVal(NULL)
  tpkLoadError <- reactiveVal(NULL)
  tpkDWLError <- reactiveVal(NULL)
  tpkCPError <- reactiveVal(NULL)
  observeEvent(startupkeyusr$user(), {
    usr <- req(startupkeyusr$user())
    appdir <- file.path(tools::R_user_dir("susobasemap", which = "data"), "susobasemap")
    if (!dir.exists(appdir)) {
      # !only if not exists
      # 1. Data dir
      dir.create(appdir, recursive = TRUE, showWarnings = FALSE)
    }
    # appdir
    appdir <- file.path(appdir, paste0(usr))
    fp(appdir)
    print(fp())
    # tif maps
    tifdir <- file.path(appdir, "basemaps_tif")
    if (!dir.exists(tifdir)) {
      # !only if not exists
      # 1. Data dir
      dir.create(tifdir, recursive = TRUE, showWarnings = FALSE)
    }
    fpp(appdir)
    # tpk maps
    tpkdir <- file.path(appdir, "basemaps_tpk")
    if (!dir.exists(tpkdir)) {
      # !only if not exists
      # 1. Data dir
      dir.create(tpkdir, recursive = TRUE, showWarnings = FALSE)
    }
    fppTPK(appdir)
    # tpk error maps
    tpkErrodir <- file.path(appdir, "mapError")
    if (!dir.exists(tpkErrodir)) {
      # !only if not exists
      # 1. Data dir
      dir.create(tpkErrodir, recursive = TRUE, showWarnings = FALSE)
    }
    fppTPKerror(appdir)
    
    notmessage <- HTML(
      sprintf(
        "Your files for this session will be stored in you personal user directory under, <b>%s/%s</b>.",
        appdir, usr
      ) %>%
        stringr::str_remove_all("\\n") %>%
        stringr::str_squish()
    )
    
    showNotification(
      ui = notmessage,
      duration = NULL,
      id = "userinfostart",
      type = "message",
      session = session,
      closeButton = T
    )
  })
  shp <- reactive({
    req(input$zip)
    # waiter::waiter_show(
    #   html = tagList(
    #     waiter::spin_fading_circles(),
    #     "Loading Boundaries..."
    #   )
    # )
    sfobj <- read_shapefile_from_zip(input$zip$datapath)
   
    if (is.na(st_crs(sfobj))) {
      showNotification("Warning: the shapefile has no CRS. Display may be inaccurate.", type = "warning")
    }
    sfobj <- st_make_valid(sfobj)
    sfobj <- st_transform(sfobj, 4326)
    # stable layer id for leaflet
    sfobj$.lid <- seq_len(nrow(sfobj))
    # waiter::waiter_hide()
    sfobj
    
  })
  ##############################################
  selected_ids <- reactiveVal(integer(0))
  observeEvent(shp(), { selected_ids(integer(0)) })
  
  output$shape_id_ui <- renderUI({
    req(shp())
    selectInput("shape_id_field", "Shapefile ID field", choices = c(names(shp())), selected = names(shp())[1])
  })
  
  output$csv_col_ui <- renderUI({
    req(input$csv)
    df <- tryCatch(read.csv(input$csv$datapath, check.names = FALSE), error = function(e) NULL)
    validate(need(!is.null(df), "Could not read the CSV."))
    selectInput("csv_id_col", "CSV ID column", choices = names(df), selected = names(df)[1])
  })
  
  output$map_id_ui <- renderUI({
    req(shp())
    selectInput("map_id_field", "Show attribute on hover (optional)",
                choices = c("Select Variable", names(shp())))
  })
  
  # Modify shape
  shp_mod<-reactiveVal(NULL)
  observeEvent(input$map_id_field, {
    req(shp())
    req(input$map_id_field!="Select Variable")
    sfobj<-shp()
    # Union if shape file contains sub segment
    sfobj <- union_shapefile(sfobj, input$map_id_field)
    shp_mod(sfobj)
  })
  
  output$map <- leaflet::renderLeaflet({
    req(shp())
    sfobj <- shp()
    # waiter::waiter_show(
    #   html = tagList(
    #     waiter::spin_fading_circles(),
    #     "Loading ..."
    #   )
    # )
    leaflet::leaflet(sfobj) |>    #, options = leafletOptions(preferCanvas = TRUE
      addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
               attribution = "Tiles &copy; Esri &mdash; Source: Esri, i-cubed, 
                              USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, 
                              UPR-EGP, and the GIS User Community") |>
      # addPolygons(
      #   layerId = ~.lid,
      #   weight = 1, color = "#444444", fillOpacity = 0.4,
      #   highlightOptions = highlightOptions(bringToFront = TRUE, weight = 2),
      #   label = if (!is.null(input$map_id_field) && input$map_id_field %in% names(sfobj)) {
      #     ~as.character(sfobj[[input$map_id_field]])
      #   } else NULL
      # ) |>
      addScaleBar(position = "bottomleft") |>
      fitBounds(
        lng1 = st_bbox(sfobj)[["xmin"]],
        lat1 = st_bbox(sfobj)[["ymin"]],
        lng2 = st_bbox(sfobj)[["xmax"]],
        lat2 = st_bbox(sfobj)[["ymax"]]
      )
    # waiter::waiter_hide()
  })
  
  observeEvent(input$map_id_field, {
    req(shp_mod())
    req(input$map_id_field!="Select Variable")
    print(input$map_id_field)
    sfobj <- shp_mod()
    # # Union if shape file contains sub segment
    # sfobj <- union_shapefile(sfobj, input$map_id_field)
    waiter::waiter_show(
      html = tagList(
        waiter::spin_fading_circles(),
        "Loading ..."
      )
    )
    #sfobj<-sfobj %>% sf::st_simplify()
    
    leaflet::leafletProxy("map", data = sfobj) |>
      clearShapes() |>
      addPolygons(
        layerId = ~.lid,
        weight = 1, fillColor = "#F05023",color = "#000000", fillOpacity = 0.5,
        highlightOptions = highlightOptions(bringToFront = TRUE, weight = 2),
        label = if (!is.null(input$map_id_field) && input$map_id_field %in% names(sfobj)) {
          ~as.character(sfobj[[input$map_id_field]])
        } else NULL
      )
    
    waiter::waiter_hide()
    
  }, ignoreInit = TRUE)
  
  observeEvent(input$map_shape_click, {
    req(input$mode == "map")
    id <- input$map_shape_click$id
    if (is.null(id)) return()
    id <- as.integer(id)
    current <- selected_ids()
    if (id %in% current) current <- setdiff(current, id) else current <- c(current, id)
    selected_ids(sort(unique(current)))
    
    # highight map
    isolate({
      sfobj <- shp_mod()
      ids <- current
      if (length(ids)) {
        leaflet::leafletProxy("map") |>
          addPolygons(
            data = sfobj[sfobj$.lid %in% ids, , drop = FALSE],
            weight = 2, color = "#FDB714",
            fillOpacity = 0.7, opacity = 1, dashArray = "3", group = "selected"
          )
      }
    })
  })
  
  observeEvent(input$clear_sel, {
    # reset table
    selected_ids(integer(0))
    # reset map
    req(shp_mod())
    sfobj <- shp_mod()
    waiter::waiter_show(
      html = tagList(
        waiter::spin_fading_circles(),
        "Loading ..."
      )
    )
    # sfobj<-sfobj %>% sf::st_simplify()
    
    leaflet::leafletProxy("map", data = sfobj) |>
      clearShapes() |>
      addPolygons(
        layerId = ~.lid,
        weight = 1, fillColor = "#F05023",color = "#000000", fillOpacity = 0.5,
        highlightOptions = highlightOptions(bringToFront = TRUE, weight = 2),
        label = if (!is.null(input$map_id_field) && input$map_id_field %in% names(sfobj)) {
          ~as.character(sfobj[[input$map_id_field]])
        } else NULL
      ) |>
      fitBounds(
        lng1 = st_bbox(sfobj)[["xmin"]],
        lat1 = st_bbox(sfobj)[["ymin"]],
        lng2 = st_bbox(sfobj)[["xmax"]],
        lat2 = st_bbox(sfobj)[["ymax"]]
      )
    
    waiter::waiter_hide()
    
    })
  
  observeEvent(selected_ids, {
    req(shp_mod())
    sfobj <- shp_mod()
    ids <- selected_ids()
    # base pipe cannot take a { } block; wrap in an anon function instead
    (\(m) {
      m <- clearGroup(m, "selected")
      if (length(ids)) {
        addPolygons(
          m,
          data = sfobj[sfobj$.lid %in% ids, , drop = FALSE],
          weight = 2, color = "#000000",
          fillOpacity = 0.7, opacity = 1, dashArray = "3", group = "selected"
        )
      } else {
        m
      }
    })(leafletProxy("map"))
  }, ignoreInit = TRUE)
  
  selected_sf <- reactive({
    req(shp_mod())
    sfobj <- shp_mod()
    if (input$mode == "map") {
      ids <- selected_ids()
      return(if (!length(ids)) sfobj[0, ] else sfobj[sfobj$.lid %in% ids, ])
    }
    # CSV mode
    req(input$csv, input$shape_id_field)
    df <- tryCatch(read.csv(input$csv$datapath, check.names = FALSE), error = function(e) NULL)
    validate(need(!is.null(df), "Could not read the CSV."))
    id_col <- if (!is.null(input$csv_id_col) && input$csv_id_col %in% names(df)) input$csv_id_col else names(df)[1]
    ids_csv <- unique(df[[id_col]])
    shp_ids <- as.character(sfobj[[input$shape_id_field]])
    keep <- which(shp_ids %in% as.character(ids_csv))
    sfobj[keep, , drop = FALSE]
  })
  
  output$sel_info <- renderPrint({
    req(shp_mod())
    n_total <- nrow(shp_mod()); n_sel <- nrow(selected_sf())
    cat("Selected polygons:", n_sel, "of", n_total, "\n")
    if (n_sel > 0) {
      cat("Preview of selected attribute names:\n")
      print(head(names(selected_sf())))
      cat("\nFirst few rows of selected attributes:\n")
      print(utils::head(st_drop_geometry(selected_sf())))
    } else {
      cat("No polygons selected yet.")
    }
  })
  
  sample_seed<-reactiveVal(1234)
  zipfilepath <- modal_createshape_server("dl_shp",
                                          sample_seed = sample_seed,
                                          shape_boundaries = selected_sf,
                                          sampType = reactive({
                                            "Random Cluster"
                                          })
  )
  shapeNameForDownload <- reactive({
    SYT <- stringr::str_remove_all(Sys.time(), "([:punct:])|([:space:])")
    SEE <- NULL
    paste0(paste("Shapefiles", SYT, "seed", SEE, sep = "_"), ".zip")
  })
  zipFileDwl_server("shapeboundaries",
                    file_name = shapeNameForDownload,
                    path_to_zip = zipfilepath
  )
  
  TPKpath <- modal_createbasemap_server("dl_map",
                                        fpp = fpp(), fppTPK = fppTPK(), fppTPKerror = fppTPKerror(),
                                        sample_seed = sample_seed,
                                        shape_boundaries = selected_sf,
                                        sampType = reactiveVal(
                                          "Random Cluster"
                                        )
  )
  mapNameForDownload <- reactive({
    SYT <- stringr::str_remove_all(Sys.time(), "([:punct:])|([:space:])")
    SEE <- sample_seed()
    paste0(paste("BaseMapFiles", SYT, "seed", SEE, sep = "_"), ".zip")
  })
  zipFileDwl_server("basemap",
                    file_name = mapNameForDownload,
                    path_to_zip = TPKpath
  )
  csvNameForDownload <- reactive({
    SYT <- stringr::str_remove_all(Sys.time(), "([:punct:])|([:space:])")
    SEE <- sample_seed()
    paste0(paste("Table", SYT, "seed", SEE, sep = "_"), ".zip")
  })
  tableForDownload<-reactive({
    req(shp_mod())
    shinyjs::enable("dl_table")
    tmp<-shp_mod() %>% sf::st_set_geometry(NULL)
    return(tmp)
  })
  download_csv_server("dl_table",
                      file_name = csvNameForDownload,
                      content = tableForDownload
                      )
  
  #########################
  # Survey Solutions Assignment
  susomapadmin <- mapadminSRV("susomapassign", boundaryfile = zipfilepath, mapfile = TPKpath)
  
  
}














