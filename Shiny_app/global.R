
# auteur: marc.agenis@gmail.com
# date de derniere mise a jour: 15/10/2017
# version du logiciel: R 3.2.3


#    CHARGEMENT DE PACKAGES
###########################
library(dplyr)
library(ggplot2)
library(zoo)
library(magrittr)

#    CHARGEMENT DE DONNEES PRE-CALCULEES
########################################
load(file="data_to_shiny.Rdata")

#    VARIABLES
##############
options(scipen = 999)

# code couleur des partis
mycolors = c(
  "DIV" = rgb(194/255, 194/255, 194/255),
  "COM" = rgb(1, 0, 0),
  "FN"  = rgb(5/255, 33/255, 96/255),
  "REM" = rgb(1, 192/255, 0),
  "EXG" = rgb(192/255, 0, 0),
  "FI"  = rgb(192/255, 0, 0),
  "ECO" = rgb(0, 178/255, 78/255),
  "DLF" = rgb(133/255, 103/255, 165/255),
  "SOC" = rgb(1, 51/255, 154/255),
  "RDG" = rgb(252/255, 101/255, 154/255),
  "UDI" = rgb(149/255, 179/255, 215/255),
  "MDM" = rgb(1, 153/255, 0),
  "LR"  = rgb(0, 113/255, 193/255),
  "DVG" = rgb(252/255, 101/255, 154/255),
  "DVD" = rgb(147/255, 179/255, 217/255),
  "REG" = rgb(171/255, 171/255, 171/255),
  "EXD" = rgb(12/255, 12/255, 12/255)
)
# on doit les trier dans l'ordre de leur position dans l'hémicycle
nuances.tries = names(mycolors)[c(5,6,2,9,10,14,7,16,4,12,11,15,13,8,3,17,1)]
# pour ggplot
cols1 <- scale_color_manual(values = mycolors)
cols2 <- scale_fill_manual(values = mycolors)


#    FONCTIONS
##############

# plot coordonnées polaire
ggparliament = function(data, party, seats1, seats2,
         style = c("dots", "arc", "bar", "pie", "rose"), 
         label = c("name", "seats", "both", "neither"),
         portion = 0.75, 
         nrows = 10,
         size = 2L,
         total = NULL,
         ...) {
  
  if (!missing(data)) {
    party <- data$party <- data[[as.character(substitute(party))]]
    seats1 <- data$seats1 <- data[[as.character(substitute(seats1))]]
    if (!missing(seats2)) {
      seats2 <- data$seats2 <- data[[as.character(substitute(seats2))]]
    }
  } else {
    party <- party
    seats1 <- seats1
    if (length(party) != length(seats1)) {
      stop("'party' and 'seats1' must be vectors of the same length")
    }
    if (!missing(seats2)) {
      seats2 <- seats2
      if (length(party) != length(seats2)) {
        stop("'party', 'seats1', and 'seats2' must be vectors of the same length")
      }
    }
  }
  
  # remove superfluous theme elements
  simple_theme <- theme(axis.text.x = element_blank(), 
                        axis.text.y = element_blank(), 
                        axis.ticks.x = element_blank(),
                        axis.ticks.y = element_blank(),
                        panel.grid.major = element_blank(), 
                        panel.grid.minor = element_blank())
  
  
  # labels
  label <- match.arg(label)
  labeltext1 <- switch(label,
                       name = party,
                       seats = as.character(seats1),
                       both = paste0(party, " (", seats1, ")"),
                       neither = rep("", length(party))
  )
  if (!missing(seats2)) {
    labeltext2 <- switch(label,
                         name = party,
                         seats = as.character(seats2),
                         both = paste0(party, " (", seats2, ")"),
                         neither = rep("", length(party))
    )
  }
  
  # plot type
  style <- match.arg(style)
  if (style %in% c("arc", "bar")) {
    
    if (style == "bar") {
      portion <- 1L
    }
    
    # post-election
    data$share <- portion * (seats1 / sum(seats1))
    data$xmax <- cumsum(data$share)
    data$xmin <- c(0, head(data$xmax, n= -1))
    data$xmid <- rowMeans(cbind(data$xmin, data$xmax))
    
    # pre-election
    if (!missing(seats2)) {
      data$share2 <- portion * (seats2 / sum(seats2))
      data$xmax2 <- cumsum(data$share2)
      data$xmin2 <- c(0, head(data$xmax2, n= -1))
      data$xmid2 <- rowMeans(cbind(data$xmin2, data$xmax2))
    }
    
    # setup plot
    p <- ggplot(data) + xlab("") + ylab("") + xlim(c(0, 1)) + ylim(c(0, 2.3))
    if (style == "arc") {
      p <- p + coord_polar(theta = "x", start = -(portion*pi))
    }
    
    # post-election
    if (label != "neither") {
      p <- p + geom_text(aes(y = 2.2, x = xmid, label = labeltext1, color = party))
    }
    p <- p + geom_rect(aes(fill = party, xmax = xmax, xmin = xmin, ymax = 2, ymin = 1.5), colour = NA)
    
    # pre-election
    if (!missing(seats2)) {
      if (label != "neither") {
        p <- p + geom_text(aes(y = 1.2, x = xmid2, label = labeltext2, colour = party))
      }
      p <- p + geom_rect(aes(fill = party, colour = party, xmax = xmax2, xmin = xmin2, ymax = 1, ymin = 0.5), colour = NA) 
    }
    if (!is.null(total)) {
      p <- p + geom_text(aes(x = 0.25, y = 0.2), label = sum(seats1), size = total, color = "black")
    }
    
  } else if (style == "dots") {
    
    # construct new data structure
    polar <- structure(list(azimuth = numeric(sum(seats1)),
                            radius = numeric(sum(seats1))),
                       class = "data.frame",
                       row.names = seq_len(sum(seats1)))
    
    # seats per row is circumference of each ring
    circ <- floor(2*(portion*nrows)*pi)
    nperrow <- floor(seq(12, circ, length.out = nrows))
    
    # modify for based upon excess seats
    remainder <- sum(nperrow) - nrow(polar)
    i <- nrows
    while (remainder > 0) {
      nperrow[i] <- nperrow[i] - 1L
      remainder <- remainder - 1L
      if (i == 3) {
        i <- nrows
      } else {
        i <- i - 1L
      }
    }
    while (remainder < 0) {
      nperrow[i] <- nperrow[i] + 1L
      remainder <- remainder + 1L
      if (i == 1) {
        i <- nrows
      } else {
        i <- i - 1L
      }
    }
    
    # y position (which ring)
    ring <- rep(seq_len(nrows) + 3L, times = nperrow)
    polar[["radius"]] <- head(ring, nrow(polar))
    # x position within ring
    pos <- unlist(lapply(nperrow, function(x) seq(0, portion, length.out = x)))
    polar[["azimuth"]] <- head(pos, nrow(polar))
    
    polar <- polar[order(polar$azimuth, polar$radius),]
    polar[["party"]] <- rep(levels(party), times = seats1)
    
    # make plot
    p <- ggplot(polar, aes(x = azimuth, y = radius, colour = party)) + 
      coord_polar(start = -(portion*pi)) + 
      xlab("") + ylab("") +
      xlim(c(0, 1)) + ylim(c(0, nrows + 8))
    
    if (label != "neither") {
      labeldata <- aggregate(azimuth ~ party, data = polar, FUN = mean, na.rm = TRUE)
      labeldata[["labeltext"]] <- labeltext1
      labeldata[["y"]] <- nrows
      p <- p + geom_text(aes(x = azimuth, y = y, label = labeltext), data = labeldata, nudge_y = 6, inherit.aes = FALSE)
    }
    
    if (!is.null(total)) {
      p <- p + geom_text(aes(x = 0.25, y = 0.2), label = sum(seats1), size = total, color = "black")
    }
    
    p <- p + geom_point(size = size)
    
  } else if (style == "pie") {
    stop("style 'pie' not currently implemented")
  } else if (style == "rose") {
    p <- ggplot(, aes(x = factor(party), y = seats1, fill = factor(party))) + 
      xlab("") + ylab("") + 
      geom_bar(width = 1, stat = "identity") + 
      coord_polar(theta = "x")
  }
  
  p + simple_theme
}

