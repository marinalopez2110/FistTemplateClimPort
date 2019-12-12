shinyServer(
  function(input, output, session){
    # Send a pre-rendered image, and don't delete the image after sending it
    output$myImage <- renderImage({
      # When input$n is 3, filename is ./images/image3.jpeg
      filename <- normalizePath(file.path('../images',
                                          paste('image', input$n, '.png', sep='')))
      
      # Return a list containing the filename and alt text
      list(src = filename,
           alt = paste("Image number", input$n))
      
    }, deleteFile = FALSE)
  }
)