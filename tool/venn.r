library("grid");
library("VennDiagram");
args <- commandArgs("T")
profile <- read.table(args[1], head = T, check.names = F)
#profile[which(profile > 0)]  <- 1
f <- function(x, y){
  y[which(x != 0)]
}
list.venn <- lapply(profile, f, y = rownames(profile))
col = c("red", "yellow", "green", "blue", "purple", "orange")
i = ncol(profile)
venn.diagram(list.venn[1:i], imagetype = "png", fill = col[1:i], args[2], margin = 0.05)
