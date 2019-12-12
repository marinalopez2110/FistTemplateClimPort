shinyServer(
  function(input, output, session){
    randomVals <- eventReactive(input$Hiver, {
      runif(input$n) })
    
    output$plot <- renderPlot({
      hist(randomVals()) })
  }
)