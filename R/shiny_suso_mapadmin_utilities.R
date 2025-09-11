#' Loop for maps
#'
#' @noRd
#' @keywords internal
#'
.loopForMapsApi<-function(tab, ...) {
  if(!is.null(tab) && nrow(tab)==100) {
    tabList<-list()
    skip<-0
    nmaps<-100
    tabList[[paste0("skip_", skip)]]<-tab
    while(nmaps==100){
      skip<-skip+100
      tab<-SurveySolutionsAPI::suso_mapinfo(..., take = 100, skip = skip)
      nmaps<-nrow(tab)
      tabList[[paste0("skip_", skip)]]<-tab
    }
    tab<-data.table::rbindlist(tabList)
  }
  return(tab)
}


#' Modal with error
#'
#' @noRd
#' @keywords internal
#'

.runWithModalOnError <- function(func) {
  ### ATTENTION ####
  # IN SPATSAMPLE INCLUDED 
  # UNDER SERVER UTILITIES
  result <- tryCatch(
    {
      func
    },
    error = function(err) {
      # Display the error message in a Shiny modal
      shiny::showModal(modalDialog(
        title = HTML("<div align='center'>ERROR</div>"),
        HTML(paste("<div align='center'>An error occurred:", err$message, "</div>")),
        easyClose = TRUE
      ))
      return(NULL)
    }
  )
  
  return(result)
}