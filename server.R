shinyServer(
  function(input, output, session){
    
    output$myPlot <- renderPlot({
      
      distType <- input$Distribution
      size <- input$sampleSize
      
      if(distType == "Normal"){
        
        randomVec <-rnorm(size, mean = as.numeric(input$mean), sd=as.numeric(input$sd))
      }
      else {
        
        randomVec <- rexp(size, rate = 1/ as.numeric(input$lambda))
      }
      
      hist(randomVec, col="blue")
    })
  }
)