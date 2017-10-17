
# auteur: marc.agenis@gmail.com
# date de derniere mise a jour: 15/10/2017
# version du logiciel: R 3.2.3

#    SCRIPT    =>    faire une version bilingue avec updateControls.
###########

fluidPage(
  
  titlePanel("Influence de la taille des circonscriptions sur un scrutin législatif"),
  
  sidebarLayout(
    
    sidebarPanel(
      h5("Normalement chaque député est élu par suffrage majoritaire à 2 tours, sur l'une des 577 circonscriptions. Toutes les circonscriptions sont construites pour regrouper environ 70 à 80 000 électeurs inscrits. La représentativité des partis à l'AN dépend donc de l'hétérogénéité spatiale des opinions politiques."),
      h5("Que se passerait-il si on faisait varier la taille des circonscriptions? Chaque incrément du slider suivant multiplie par 4 la taille de la circonscription"),
      sliderInput("aggr", "Echelle d'agrégation des voix:",
                  min = 0, max = 8, value = 2, step=1),
      h6("Votre circonscription moyenne représente..."),
      verbatimTextOutput("MaCirco"),
      h4("Autres options de scrutin:"),
      radioButtons("TypeScrutin", "Type de scrutin:",
                   c("Majoritaire à 1 tour" = "1Tour",
                     "Majoritaire à 2 tour" = "2Tours")),
      sliderInput("TauxProportionnelle", "Dose de proportionnelle (%):",
                  min = 0, max = 100, value = 0, step=1),
      sliderInput("SeuilProportionnelle", "Seuil pour être représenté à la proportionnelle (%):",
                  min = 0, max = 10, value = 0, step=0.5),
      sliderInput("PrimeMajoritaire", "Prime majoritaire (nombre de députés bonus pour le vainqueur:",
                  min = 0, max = 200, value = 0, step=10),
      checkboxInput("ANreelle", "Afficher la composition réelle de l'AN?", value=FALSE)
    ),
  
  mainPanel(
    h3("Résultats"),
    plotOutput("PlotHemicycle")
  ))
  
)
#     
#   
#   wellPanel(
#     fluidRow(
#       column(width=6,
#              radioButtons("TypeScrutin", "Type de scrutin:",
#                           c("Majoritaire à 1 tour" = "1Tour",
#                             "Majoritaire à 2 tour" = "2Tours")),
#              h5("Taille des circonscriptions: l'échelle augmente d'un facteur 4 à chaque fois"),
#              sliderInput("aggr", "Echelle d'agrégation des voix:",
#                          min = 0, max = 8, value = 2, step=1),
#              h5("Une circonscription classique est construite pour représenter 80 000 inscrits environ"),
#              h6("Votre circonscription moyenne représente..."),
#              verbatimTextOutput("MaCirco")
#       ),
#       column(width=6,
#              h4("Autres options de scrutin:"),
#              sliderInput("TauxProportionnelle", "Dose de proportionnelle (%):",
#                          min = 0, max = 100, value = 0, step=1),
#              sliderInput("SeuilProportionnelle", "Seuil pour être représenté à la proportionnelle (%):",
#                          min = 0, max = 10, value = 0, step=0.5),
#              sliderInput("PrimeMajoritaire", "Prime majoritaire (nombre de députés bonus pour le vainqueur:",
#                          min = 0, max = 200, value = 0, step=10)
#       )
#     )
#   ),
#   
#   mainPanel(
#     
#     h3("Résultats"),
#     plotOutput("PlotHemicycle")
#     
#   )
# )

# mainPanel(
#   tabsetPanel(type = "tabs", 
#               
#               tabPanel("Résultats", 
#                        h5("blablabla"),
#                        plotOutput("PlotHemicycle"),
#                        h5("blablabla")
#               ), 
#               
#               tabPanel("Explications", 
#                        h5("blablabla"),
#                        # plotOutput("GIF ANIME"),
#                        h5("blablabla")
#               )
#   )
# )
# 
