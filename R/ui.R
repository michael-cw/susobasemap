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
      shiny::h2("Survey Solutions App for Spatail Resource Creation", style = "margin-left: 60px;")  # Adjust margin to align with your image
    ),
    waiter::use_waiter(),
    sidebarLayout(
      sidebarPanel(
        moduleUI1("mymodule") # Use the module UI here
      ),
      mainPanel(
        moduleUI2("mymodule") # Use the table UI here
      )
    )
  )
}
