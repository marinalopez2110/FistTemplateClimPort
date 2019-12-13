shinyServer (
  pageWithSidebar(
    headerPanel("Portraits Climatiques du Québec - MFFP"),
    
    sidebarPanel(
      selectInput("Variable", "Séléctionez la variable climatique:",
                  choices=c("Températures moyennes, min et max","Précipitations totales et sous forme de neige",
                            "Degrés-jours de croissance", "Évènements gel-dégel", "Saison de croissance")),
      conditionalPanel(condition = "input.Variable == 'Températures moyennes, min et max'",
                       actionButton("Moyenne", "Températures moyennes (°C)"),
                       actionButton("Maximum", "Moyenne des température maximales quotidiennes (°C)"),
                       actionButton("Minimum", "Moyenne des températures minimales quotidiennes (°C)")),
      conditionalPanel(condition = "input.Variable == 'Précipitations totales et sous forme de neige'",
                       actionButton("PrecTotale", "Précipitations totales (mm)"),
                       actionButton("Neige", "Précipitations sous forme de neige (cm)")),
      selectInput("Echele", "Séléctionez l'échele:",
                 choices=c("Domaines et sous-domaines bioclimatiques", "Régions et sous-région écologiques", 
                           "Territoires guides", "Secteurs des opérations régionales",
                           "Régions forestières", "Unités d’aménagement (UA)")),
      selectInput("Saisonalite", "Séléctionez la saisonalité:",
                  choices=c("Annuel", "Saissioniers", "Mensuel" )),
      conditionalPanel(condition = "input.Saisonalite == 'Saissioniers'",
                       actionButton("Hiver", "Hiver"),
                       actionButton("Printemps", "Printemps"),
                       actionButton("Été", "Été"),
                       actionButton("Automne", "Automne")),
      conditionalPanel(condition = "input.Saisonalite == 'Mensuel'",
                       selectInput("Mois", "Séléctionez le mois:",
                                   choices=c("Janvier", "Février", "Mars", "Avril","Mai","Juin",
                                             "Julliet","Aout","Septembre","Octobre","Novembre","Decembre")),
                       ),
      numericInput("n", "n", 1),
      selectInput("Scenario", "Séléctionez le scenario d'émissions:",
                  choices=c("Modérées (RCP4.5)", "Élevées" )),
      selectInput("Horizon", "Séléctionez l'horizon de temps:",
                  choices=c("Historique", "2071-2100", "2041-2070")),
      sliderInput("Percentile", "Séléctionez le percentile:",
                  min=10, max=90, value= 50, step=40),
      
    ),
    
    mainPanel(
      imageOutput("myImage")
    )
    
  )
  
  
)