#` Shiny UI Survey Solutions App for Spatail Resource Creation
#'
#'
#'
#' @keywords internal
#' @noRd


main_ui<-function(request){
  fpwww <- system.file("www", package = "susobasemap")
  style<-sass::sass(sass::sass_file(file.path(fpwww, "styles.scss")))
  fluidPage(
    shiny::tags$head(
      shiny::tags$style((style))
    ),
    shiny::tags$header(
      style = "padding-bottom: 0px; background-color: #002244; color: white; text-align: center; height: 5vh",
      shiny::div(
        style = "float: left;",
        shiny::img(src = file.path("www", "logoWBDG.png"), height = "63vh")  # Adjust image path and size
      ),
      shiny::h2("Survey Solutions App for Spatial Resource Creation", style = "margin-left: 60px;")  # Adjust margin to align with your image
    ),
    waiter::use_waiter(),
    sidebarLayout(
      sidebarPanel(
        tabsetPanel(
          tabPanel(
            "Process",
            h4("1) Upload shapefile (ZIP)"),
            fileInput("zip", "Zipped shapefile", accept = c(".zip")),
            hr(),
            h4("2) Choose selection mode"),
            radioButtons(
              "mode", label = NULL,
              choices = c("Select by clicking on the map" = "map",
                          "Select by uploading a CSV of IDs" = "csv")
            ),
            conditionalPanel(
              "input.mode == 'csv'",
              fileInput("csv", "CSV with IDs", accept = c(".csv", "text/csv")),
              uiOutput("csv_col_ui"),
              uiOutput("shape_id_ui"),
              helpText("Pick the shapefile attribute that matches your CSV IDs.")
            ),
            conditionalPanel(
              "input.mode == 'map'",
              uiOutput("map_id_ui"),
              actionButton("clear_sel", "Clear map selection")
            ),
            hr(),
            h4("3) Selection summary"),
            verbatimTextOutput("sel_info"),
            hr(),
            h4("4) Download"),
            shiny::fluidRow(
              column(6,
                     modal_createshape_ui ("dl_shp", style = "color: #FFFFFF; width: 220px;background-color: #002244;border-color: #002244")
              ),
              column(6,
                     zipFileDwl_ui("shapeboundaries")),
              br()),
            shiny::fluidRow(
              column(6,
                     modal_createbasemap_ui("dl_map",
                                            style = "color: #FFFFFF; width: 220px;background-color: #002244;border-color: #002244")
              ),
              column(6,
                     zipFileDwl_ui("basemap"))
            )
          ),
          tabPanel(
            "admin",
            modal_createbasemap_provider_ui("dl_map"),
            startupModalUI(
              "startupModal"
            )
          )
        )
      ),
      mainPanel(leaflet::leafletOutput("map", height = "60vh", width = "100%"))
    )
  )
}
