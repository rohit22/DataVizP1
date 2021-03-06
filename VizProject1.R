library(gdata)
library(ggplot2)
library(plyr)
## Set your own working directory!!!
setwd("../../../Downloads")
survey <- read.xls("Survey+Response.xlsx", stringsAsFactors = F)

########################
#### DATA CLEANING ####
#######################

## Add ID variable.
survey <- cbind(1:nrow(survey), survey)

## Drop useless columns and rename the good ones.
survey <- survey[,colSums(is.na(survey))<nrow(survey)]
names(survey)
newNames <- c("id", "Waitlist", "Program", "Tools", "R - Data Manipulation", "Gender", "Pref. Editor", "R - Graphic Skills",
              "R - Adv. Multivariate Analysis Skills", "R - Reproducibility Skills", "Matlab Skills", "Github Skills")
names(survey) <- newNames

## Get list of all available "tools".
toolsList <- as.character(survey$Tools)
toolsList <- strsplit(toolsList, ",")
toolsList <- unique(trim(unlist(toolsList)))
toolsList
lg <- length(toolsList)

## Make binary variables for each tool.
test <- data.frame(survey$id, survey$Tools, stringsAsFactors = F)
names(test) <- c("id", "tools")
out <- data.frame(matrix(ncol=lg, nrow=0))
names(out) <- toolsList

make_row = function(x) {
  m <- c(rep(NA,lg))
  names(m) <- toolsList
  v = as.character(unique(trim(unlist(strsplit(x[1,2], ",")))))
  m[v] = 1
  m
}

outFile <- ddply(.data=test, .variables=.(id), .fun=make_row)

surveyNew <- merge(survey, outFile, by="id")
surveyNew <- surveyNew[!(names(surveyNew) %in% c("Tools"))]
names(surveyNew)[c(19,20,21,23,27)] <- c("Dropbox", "Google Drive", "RegEx", "Shell", "Web")

## Turn to binary variable.
surveyNew[is.na(surveyNew)] <- 0

## Clean program options.
sort(unique(surveyNew$Program))

surveyNew[surveyNew$Program == "Ms in ds",]$Program <- "IDSE (master)"
surveyNew[surveyNew$Program == "MSDS",]$Program <- "IDSE (master)"
surveyNew[surveyNew$Program == "Data Science",]$Program <- "IDSE (master)"
surveyNew[surveyNew$Program == "QMSS (master)",]$Program <- "QMSS"
surveyNew[surveyNew$Program == "Data Science Certification",]$Program <- "IDSE (certificate)"
surveyNew[surveyNew$Program == "PhD Biomedical Informatics",]$Program <- "Ph.D."

#ggplot(surveyNew, aes(Program, fill=Program)) + geom_bar() +
#  geom_text(aes(label = format(..count.., digits=2, drop0trailing=TRUE), y= ..count.. ), stat= "count", vjust = -.5) +
#  theme(legend.position = "bottom")

## Clean text editor.
sort(unique(surveyNew$`Pref. Editor`))
surveyNew[surveyNew$`Pref. Editor` == "Any (20 years C++/Java experience)",]$`Pref. Editor` <- "Any"
surveyNew[grepl("sublime", surveyNew$`Pref. Editor`, ignore.case=T),]$`Pref. Editor` <- "Sublime"
surveyNew[surveyNew$`Pref. Editor` == "I used jupyter last semester",]$`Pref. Editor` <- "Jupiter"
surveyNew[surveyNew$`Pref. Editor` == "textwrangler",]$`Pref. Editor` <- "textWrangler"
surveyNew[surveyNew$`Pref. Editor` == "Text Wrangler",]$`Pref. Editor` <- "textWrangler"
surveyNew[surveyNew$`Pref. Editor` == "python",]$`Pref. Editor` <- "iPython"
surveyNew[surveyNew$`Pref. Editor` == "ipynb",]$`Pref. Editor` <- "iPython"
surveyNew[surveyNew$`Pref. Editor` == "Webstorm, pycharm",]$`Pref. Editor` <- "iPython"
surveyNew[surveyNew$`Pref. Editor` == "notepad++",]$`Pref. Editor` <- "Notepad++"
surveyNew[surveyNew$`Pref. Editor` == "xcode",]$`Pref. Editor` <- "XCode"
surveyNew[surveyNew$`Pref. Editor` == "vi/vim",]$`Pref. Editor` <- "Vi/Vim"
surveyNew[surveyNew$`Pref. Editor` == "haven't used any",]$`Pref. Editor` <- "None"


## Clean gender.
sort(unique(surveyNew$Gender))
surveyNew[surveyNew$Gender == "",]$Gender <- "he/him"
surveyNew[surveyNew$Gender == "doesn't matter",]$Gender <- "she/her"

#ggplot(surveyNew, aes(`Pref. Editor`, fill=`Pref. Editor`)) + geom_bar() +
#  geom_text(aes(label = format(..count.., digits=2, drop0trailing=TRUE), y= ..count.. ), stat= "count", vjust = -.5) +
#  theme(legend.position = "bottom")


###########################
#### CLUSTER ANALYSIS ####
#########################

## Training an labeled data.
inputCluster <- surveyNew[12:31]
programs <- (surveyNew[,3])

## Cluster Dendogram.
d <- dist(t(inputCluster), method = "binary")
hc <- hclust(d)
plot(hc)

library(stats)
pca <- prcomp(inputCluster)
plot(pca, type = "l")
summary(pca)


library(devtools)
install_github("ggbiplot", "vqv")

library(ggbiplot)
g <- ggbiplot(pca, obs.scale = 1, var.scale = 1, groups = programs,
              ellipse = TRUE, circle = TRUE)
g <- g + scale_color_discrete(name = '')z
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)