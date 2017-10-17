
# auteur: marc.agenis@gmail.com
# date de derniere mise a jour: 15/10/2017
# version du logiciel: R 3.2.3


#    SCRIPT
###########

function(input, output) {
  
  # CALCUL DU RESULTAT AGREGE
  
  NuanceMajoritaire = Proportionnel1Tour[[1]] %>% top_n(1, voix) %>% .$nuance
  
  toPlot <- reactive({
    
  temp = left_join(Proportionnel1Tour[[1]], switch(input$TypeScrutin, "1Tour"=Majoritaire1Tour[[input$aggr+1]], "2Tours"=Majoritaire2Tour[[input$aggr+1]]), by="nuance") %>%
    mutate(nb.deputes.x.cut = ifelse(nb.deputes.x/577>input$SeuilProportionnelle/100, nb.deputes.x, 0)) %>%
    mutate(nb.deputes.x.cut = nb.deputes.x.cut*577/sum(nb.deputes.x.cut) ) %>%
    mutate_at(vars(-nuance), function(x) {zoo::na.fill(x, fill = 0)}) %>% 
    mutate(nb.deputes.final = nb.deputes.x.cut*input$TauxProportionnelle/100 + nb.deputes.y*(1-input$TauxProportionnelle/100)) %>%
    mutate(nb.deputes.final = round(nb.deputes.final*(577-input$PrimeMajoritaire)/sum(nb.deputes.final)))
  
  temp[temp$nuance==NuanceMajoritaire, 'nb.deputes.final'] <- temp[temp$nuance==NuanceMajoritaire, 'nb.deputes.final'] + input$PrimeMajoritaire
  
  temp['ANreelle'] = c(0,17,10,30,3,12,1,5,308,42,18,6,112,1,8,1,1)
  
  return(temp)
  })
  
  # PLOT
  
    
  output$PlotHemicycle <- renderPlot({
    switch(input$ANreelle+1, 
    ggparliament(toPlot(), party=nuance, seats1=nb.deputes.final, style = "arc", portion = 0.5, nrows = 6, size = 5) + cols2 + cols1 +
      theme_void() + ggtitle(paste0("Composition fictive de l'Assemblée Nationale 2017 \n agrégation par circonscription de taille variable")) + theme(legend.position="none"),
    ggparliament(toPlot(), party=nuance, seats1=nb.deputes.final, seats2=ANreelle, style = "arc", portion = 0.5, nrows = 6, size = 5) + cols2 + cols1 +
      theme_void() + ggtitle(paste0("Composition fictive de l'Assemblée Nationale 2017 \n agrégation par circonscription de taille variable")) + theme(legend.position="none"))
  }, 
  height = 1000, units="px")
  
  # OUTPUT TEXT
  
  TailleCircoReactive <- reactive({
    mytext <- TailleCirconscription[[input$aggr+1]] %>%
      format(big.mark=" ") %>%
      paste0(" électeurs")
    return(mytext)
  })
  
  output$MaCirco <- renderText(TailleCircoReactive())
  
}