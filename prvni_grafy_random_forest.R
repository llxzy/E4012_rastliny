#### NOTES ####
# pro kazdy typ grafu jsem nechala jen jeden, pro prehlednost
#
# BLUE - vykresleni dulezitosti a medianu spektra
# DRY - vykresleni vsech spekter + medianu spektra


#### Knihovny, načtení dat, úprava čísel ####
# nejsou potřeba všechny, je to pokusný skript
library(keras)
library(mlbench)
library(dplyr)
library(magrittr)
library(ggplot2)
library(scales)
library(randomForest)
library(datasets)
library(caret)
library(patchwork)
library(hrbrthemes)
library(party)

setwd("C:/Users/h337/H/Dokumenty/Skola/Podzim 2022/PROJEKT/Klasifikace-studenti")

dt <- read.csv2("All_N_rex 5 nm SR 895.csv", header = TRUE, dec =".")
# nemusím pak vypisovat dt$promenna, ale staci jen promenna
attach(dt)
#kategorialni promenne jako faktory
dt %<>% mutate(ROI.name = as.factor(ROI.name))
dt %<>% mutate_if(is.character, as.numeric)
#
summary(dt)
# výběr kompletních 
dt <- dt[complete.cases(dt),]
#### Rozdělit na skupinky #
blue <- dt[which(dt$ROI.name == 'blue'),]
green <- dt[which(dt$ROI.name == 'green'),]
soil <- dt[which(dt$ROI.name == 'soil'),]
tech <- dt[which(dt$ROI.name == 'tech'),]
dry <- dt[which(dt$ROI.name == 'dry'),]
#### Rozdělit na trénovací a testovací #
dti = sort(sample(nrow(dt), nrow(dt)*.7))
train<-dt[dti,]
test<-dt[-dti,]

#### Random les ####
attach(dt)
rf.fit <- randomForest(ROI.name ~ X430+X450+X470+X490+X510+X530+X550+X570+X590+X610+X630+X650+X670+X690+X710+X730+X750+X770+X790+X810+X830+X850+X870+X890,
                       data=train, ntree=750,
                       importance=TRUE)
# testovaci skup
ROI.name.predict <- predict(rf.fit, newdata = test)
# tabulka shod, confusion matrix
table(test$ROI.name,ROI.name.predict)
confusionMatrix(ROI.name.predict, test$ROI.name)

#### > Důležitost proměnných ####
ImpData <- as.data.frame(importance(rf.fit))
ImpData$Var.Names <- row.names(ImpData)
# do grafu - oriznout xka, aby na ose x spojite cisla
xilabs <- ImpData$Var.Names
for (i in 1:length(xilabs)) {
  xilabs[i] <- substring(xilabs[i],2,4)
}
xilabs
# vykresleni dulezitosti - osklivy graf, jen pro pruzkum
x11()
plot(x = xilabs, y = ImpData$blue, type = 'l', lwd = 5, col = 'slateblue2')
lines(x = xilabs, y = ImpData$dry, lwd = 5, col = 'darkgoldenrod3')
lines(x = xilabs, y = ImpData$green, lwd = 5, col = 'chartreuse2')
lines(x = xilabs, y = ImpData$tech, lwd = 5, col = 'lavenderblush4')
lines(x = xilabs, y = ImpData$soil, lwd = 5, col = 'tan4')

#### Vykreslit spektra s dulezitosti ####
dt[1,]
xlabs <- names(dt)
for (i in 5:length(names(dt))) {
  xlabs[i] <- substring(names(dt)[i],2,4)
}
xlabs <- xlabs[5:length(names(dt))]
xlabs

####> BLUE #####
x11()
# >>importance ####
im <- c()
for (i in 1:length(xlabs)){
  if (xlabs[i] %in% xilabs){
    im[i] <- ImpData$blue[which(ImpData$Var.Names == paste('X',xlabs[i], sep=""))]
  } else {
    im[i] <- NA
  }
}
im
# barplot - importance
bp<-barplot(height = im, col = alpha("lightsteelblue3",0.85),
     xlab = 'Vlnová délka [nm]', ylab = 'Intenzita')
#>> Medián křivka ####
med <- c()
for (i in 5:length(names(dt))){
  med[i-4] <- median(blue[,i])
}
med
# vykreslit
lines(x = bp, y = med, col = 'slateblue2', lwd = 2 , type = 'l')
# tady by to chtelo udelat dve osy ypsilon, s ruznym meritkem
# aby to bylo videt

####> DRY - vykreslení spekter všech #####
x11()
plot(x = xlabs, y = dry[1, 5:length(names(dt)) ], type = "l", col = alpha("goldenrod1",0.015),
     xlab = 'Vlnová délka [nm]', ylab = 'Intenzita')
for (i in 2:length(dry$Tray)){  
  lines(x = xlabs, y = dry[i, 5:length(names(dt))], col = alpha("goldenrod1", 0.015))
}

#>> Medián křivka #
med <- c()
for (i in 5:length(names(dt))){
  med[i-4] <- median(dry[,i])
}
med
# vykreslit
lines(x = xlabs, y = med, col = 'darkgoldenrod3', lwd = 2 )
