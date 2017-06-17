# Must be executed BEFORE rgl is loaded on headless devices.
options(rgl.useNULL=TRUE)

library(shiny)
library(ggplot2)
library(ggthemes)
library(dplyr)
library(ggrepel)
library(plotly)
#library(Cairo)


#x denote dataframe,y denote samplenames



shinyServer(function(input,output,session){

  textinput<-reactive({
    a<-input$markered
    a<-as.character(unlist(strsplit(a,"\n")))
    a
  })


    datasetInput <- reactive({

          example<-read.table("data/test.txt",header=T,sep="\t",row.names=1)
          example=example[sample(1:nrow(example),500),]
          #example<-read.table("/srv/shiny-server/vocalnoPlotOnline/test.txt",header=T,sep="\t",row.names=1)
           	inFile <- input$file1
            if (!is.null(inFile)){

                data<-read.table(inFile$datapath, header=input$header, sep=input$sep, quote=input$quote,row.names=1)

            }

           switch(input$dataset,
                    "example" = example,
                    "upload" = data
                    )
    	})



    #get plotdata
    plotdataInput<-reactive({
      a<-datasetInput()
      P.Value <- a[,2]
      FC<-a[,1]
      df<-data.frame(P.Value, FC)

      df$gene=row.names(a)

      # df$threshold<-as.factor(abs(df$FC) > input$FCcut & df$P.Value < input$pcut)
      # df
      #

      df=mutate(df,threshold = ifelse(df$P.Value >input$pcut,
                              yes = "none",
                              no = ifelse(df$FC < 0,
                                          yes = "Down-regulated",
                                          no = "Up-regulated")))
      df

    })



# output upload dataset or example dataset
    output$summary <- DT::renderDataTable(plotdataInput())
 #plotfunction
    getvocalnoPlot<-reactive({
      df<-plotdataInput()
      g <- ggplot(data=df, aes(x=FC, y=-log10(P.Value), colour=factor(threshold))) +
        geom_point( size=1.75) +
        ylim(c(0, input$ylmslider)) +
        xlab("log2 fold change") + ylab("-log10 p-value")+
        scale_y_continuous(trans = "log1p")+
        geom_vline(xintercept = 0, colour = "black") + # add line at 0
        geom_hline(yintercept = -log10(input$pcut), colour = "black")  # p(0.05) = 1.3
      if(input$theme=="default"){
      g=g+theme(legend.position = "none")+ theme_bw()+scale_color_manual(values = c("Down-regulated" = "#E64B35",
                                                                                    "Up-regulated" = "#3182bd",
                                                                                    "none" = "#636363"))
      }else if(input$theme=="Tufte"){
      g=g+geom_rangeframe() + theme_tufte()
      }else if(input$theme=="Economist"){
        g=g+ theme_economist()+ scale_colour_economist()
      }else if(input$theme=="Solarized"){
        g=g+ theme_solarized()+ scale_colour_solarized("blue")
      }else if(input$theme=="Stata"){
        g=g+ theme_stata() + scale_colour_stata()
      }else if(input$theme=="Excel 2003"){
        g=g+ theme_excel() + scale_colour_excel()
      }else if(input$theme=="Inverse Gray"){
        g=g+ theme_igray()
      }else if(input$theme=="Fivethirtyeight"){
        g=g+scale_color_fivethirtyeight()+ theme_fivethirtyeight()
      }else if(input$theme=="Tableau"){
        g=g+theme_igray()+ scale_colour_tableau()
      }else if(input$theme=="Stephen"){
        g=g+theme_few()+ scale_colour_few()
      }else if(input$theme=="Wall Street"){
        g=g+theme_wsj()+ scale_colour_wsj("colors6", "")
      }else if(input$theme=="GDocs"){
        g=g+theme_gdocs()+ scale_color_gdocs()
      }else if(input$theme=="Calc"){
        g=g+theme_calc()+ scale_color_calc()
      }else if(input$theme=="Pander"){
        g=g+theme_pander()+ scale_colour_pander()
      }else if(input$theme=="Highcharts"){
        g=g+theme_hc()+ scale_colour_hc()
      }
      if(input$Annotate){
        markedname=textinput()
        g=g+geom_text_repel(data=filter(df, gene%in%markedname), aes(label=gene))
      }
      return(g)
    })

    output$vocalnoPlot<-renderPlotly({
      g<-getvocalnoPlot()
      ggplotly(g,width=600,height=600)
      })







#download plot option
    output$downloadDataPNG <- downloadHandler(
      filename = function() {
        paste("output", Sys.time(), '.png', sep='')
      },

      content = function(file) {
        ggsave(file, getvocalnoPlot(),width = 10, height = 10, units = "in",pointsize=5.2)
      },
      contentType = 'image/png'
    )


    output$downloadDataPDF <- downloadHandler(
      filename = function() {
        paste("output", Sys.time(), '.pdf', sep='')
      },

      content = function(file) {
        ggsave(file, getvocalnoPlot(),width = 10, height = 10, units = "in",pointsize=5.2)
      },
      contentType = 'image/pdf'
    )

    output$downloadDataEPS <- downloadHandler(
      filename = function() {
        paste("output", Sys.time(), '.eps', sep='')
      },

      content = function(file) {
        ggsave(file, getvocalnoPlot(),width = 10, height = 10, units = "in",pointsize=5.2)
      },
      contentType = 'image/eps'
    )

    output$downloadDataTIFF <- downloadHandler(
      filename = function() {
        paste("output", Sys.time(), '.tiff', sep='')
      },

      content = function(file) {
        ggsave(file, getvocalnoPlot(),width = 10, height = 10, units = "in",pointsize=5.2)
      },
      contentType = 'image/eps'
    )







})



