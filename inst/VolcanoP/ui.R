library(shiny)
library(shinydashboard)
library(DT)
library(shinyBS)
library(plotly)
#difined a text area input
inputTextarea <- function(inputId, value="", nrows, ncols) {
  tagList(
    singleton(tags$head(tags$script(src = "textarea.js"))),
    tags$textarea(id = inputId,
                  class = "inputtextarea",
                  rows = nrows,
                  cols = ncols,
                  as.character(value))
  )
}


dashboardPage(
  dashboardHeader(title = "Vocalno Plot Online"),
  dashboardSidebar(
    tags$link(rel="stylesheet",type="text/css",href="main.css"),
    sidebarMenu(
    menuItem("ReadMe", tabName = "read", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    # First tab content
    tabItem("read",
            fluidRow(
              box(
                width = 4, status = "info", solidHeader = TRUE,collapsible = TRUE,
                title = "Data Input",
                radioButtons("dataset", "", c(Example = "example", Upload = "upload",Input="Inputlist"),selected = 'example'),
                downloadLink("downloadExample", "Download Example"),
                conditionalPanel(
                  condition = "input.dataset == 'upload'",

                  fileInput('file1', 'Choose CSV/text File',
                            accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),

                  checkboxInput('header', 'Header', FALSE),
                  radioButtons('sep', 'Separator',
                               c(Comma=',',
                                 Semicolon=';',
                                 Tab='\t'),
                               '\t'),
                  radioButtons('quote', 'Quote',
                               c(None='',
                                 'Double Quote'='"',
                                 'Single Quote'="'"),
                               '')
                ),


                  p("A volcano plot displays unstandardized signal (e.g. log-fold-change) against noise-adjusted/standardized signal (e.g. t-statistic or -log(10)(p-value) from statistic test(t-test,anova,etc)",
                    br(),
                    br(),
                    strong("This application was created by "),
                    tags$a(href="mailto:zhaoqi3@mail2.sysu.edu.cn",strong("Qi Zhao")),
                    strong(' from '),
                    tags$a(href="http://gps.biocuckoo.org/",strong("Ren Lab")),
                    strong(" in "),
                    tags$a(href="http://www.sysu.edu.cn/2012/en/index.htm",strong("SYSU")),
                    strong('. Please let us know if you find bugs or have new feature request.This application uses the'),
                    tags$a(href="http://www.rstudio.com/shiny/",strong("shiny package from RStudio."))
                  ),
                tags$button(id="goPlot",type="button",class="btn btn-primary action-button","GO PLOT!")
                ),
                box(width = 8, status = "success",solidHeader = TRUE,collapsible = TRUE,
                  title = "Data Summary",
                    DT::dataTableOutput("summary")
              ),

              bsModal("KEGGPlotModal", h3("Fancy Plot"), "goPlot", size = "large",
                      box(title = "Controls", width = 3, status = "info", solidHeader = TRUE,collapsible = TRUE,
                          numericInput("pcut",strong("P.Value threshold"),0.05),
                          numericInput("FCcut",strong("Fold change threshold"),1),
                          sliderInput("xlmslider", strong("Xlim range"), 1, 10, 5, step = 0.5,animate = TRUE),
                          sliderInput("ylmslider", strong("ylim range"), 1, 50, 5, step = 0.5,animate = TRUE),
                          selectInput("theme", "Plot Theme:",
                                      c("default","Tufte","Economist","Solarized","Stata","Excel 2003","Inverse Gray","Fivethirtyeight","Tableau","Stephen","Wall Street","GDocs","Calc","Pander","Highcharts")),

                          checkboxInput('Annotate', 'Annotate', FALSE),
                          conditionalPanel(
                            condition = "input.Annotate == true",
                            h4("Marked label"),
                            inputTextarea("markered","ENSDARG00000088353\nENSDARG00000079727\nENSDARG00000079727",10,10)
                          )
                      ),
                      box(title = "Volcano", width = 9, status = "success", solidHeader = TRUE,collapsible = TRUE,
                      div(
                        downloadLink('downloadDataPNG', 'Download PNG-file',class="downloadLinkblack"),
                        downloadLink('downloadDataPDF', 'Download PDF-file',class="downloadLinkred"),
                        downloadLink('downloadDataEPS', 'Download EPS-file',class="downloadLinkblue"),
                        downloadLink('downloadDataTIFF', 'Download TIFF-file',class="downloadLinkgreen"),
                        htmltools::div( plotlyOutput("vocalnoPlot", width = 300, height = 600))
                      )
                      )


              )

            )
    )
  )
)
