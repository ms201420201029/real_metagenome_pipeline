source("{{ tool_default_dir }}/labels2colors.R")
profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
pdf.file = "{{ pdf_file }}"

dataraw  <- read.table(profile.table,header = T,row.names = 1,sep = "\t",check.names = F,quote = "")
group  <- read.table(group.file,header = F,row.names = 1,sep = "\t",check.names = F,quote = "")
dataraw = dataraw[,rownames(group)]
g_class <- tapply(1:nrow(group),group,c)
g_class_names = names(g_class)
for(g in c(1:length(g_class),0)){
  if(g==0){
    data <- dataraw
  }else{
    data <- dataraw[,g_class[[g]]]
  }

  pdf(paste(substr(pdf.file,0,nchar(pdf.file)-4),g_class_names[g],".pdf",sep=""), height = 10, width = 10)
  dpar <- par(no.readonly=T)
  layout(matrix(c(1, 2, 2, 3, 3, 3), ncol = 3, byrow = T))


  #set top value default is 5
  top_phylum <- sort(apply(data[which(lapply(strsplit(rownames(data),split = "|",fixed = T),length)==2),],1,sum),decreasing = T)[1:5]
  phylum_color  <- cols_brewer[1:length(top_phylum)]
  names(phylum_color) <- names(top_phylum)
  phylum.profile <- data[names(top_phylum),]
  par(mar = c(15, 5, 4, 4))
  boxplot(t(phylum.profile), cex = 0.5, pch = 19, col = phylum_color, xaxt="n")
  lines(x = (1 : nrow(phylum.profile)), y = apply(phylum.profile, 1, mean), cex = 0.5,type="b",pch=17)
  text(labels = as.character(lapply(strsplit(rownames(phylum.profile),split = "|",fixed = T),function(x) substr(x[2],start = 4,stop = nchar(x[2])))), x = (1 : nrow(phylum.profile)), y = rep((min(phylum.profile) - max(phylum.profile)) / 10, nrow(phylum.profile)), srt = 60, xpd = T, adj = 1)

  #genus
  genus.profile <- c()
  for(i in 1:length(names(top_phylum))){
    tmp_name <- grep(rownames(data),pattern = strsplit(names(top_phylum)[i],split="|",fixed=T)[[1]][2])
    tmp_data <- data[tmp_name,]
    tmp2_data <- tmp_data[which(lapply(strsplit(rownames(data)[tmp_name],split = "|",fixed = T),length)==6),]
    genus.profile <- rbind(genus.profile,tmp2_data)
  }
  top_genus <- sort(apply(genus.profile,1,sum),decreasing = T)[1:15]

  phylum_genus <- as.character(lapply(strsplit(names(top_genus),split="|",fixed = T),function(x) paste(x[1],x[2],sep = "|")))
  names(phylum_genus) <- names(top_genus)
  genus_color <- phylum_color[phylum_genus]
  genus.profile <- genus.profile[names(top_genus),]
  par(mar = c(15, 0, 4, 2))
  boxplot(t(genus.profile), cex = 0.5, pch = 19, col = genus_color, xaxt="n")
  lines(x = (1 : nrow(genus.profile)), y = apply(genus.profile, 1, mean), cex = 0.5,type="b",pch=17)
  # axis(1, labels = FALSE, at = (1 : nrow(genus.profile)))
  text(labels = as.character(lapply(strsplit(rownames(genus.profile),split = "|",fixed = T),function(x) substr(x[6],start = 4,stop = nchar(x[6])))), x = (1 : nrow(genus.profile)), y = rep((min(genus.profile) - max(genus.profile)) / 10, nrow(genus.profile)), srt = 60, xpd = T, adj = 1)

  #species
  species.profile <- c()
  for(i in 1:length(names(top_phylum))){
    tmp_name <- grep(rownames(data),pattern = strsplit(names(top_phylum)[i],split="|",fixed=T)[[1]][2])
    tmp_data <- data[tmp_name,]
    tmp2_data <- tmp_data[which(lapply(strsplit(rownames(data)[tmp_name],split = "|",fixed = T),length)==7),]
    species.profile <- rbind(species.profile,tmp2_data)
  }
  top_species <- sort(apply(species.profile,1,sum),decreasing = T)[1:20]
  phylum_species <- as.character(lapply(strsplit(names(top_species),split="|",fixed = T),function(x) paste(x[1],x[2],sep = "|")))
  names(phylum_species) <- names(top_species)
  species_color <- phylum_color[phylum_species]
  species.profile <- species.profile[names(top_species),]
  par(mar = c(15, 5, 1, 2))
  boxplot(t(species.profile), cex = 0.5, pch = 19, col = species_color, xaxt="n")
  lines(x = (1 : nrow(species.profile)), y = apply(species.profile, 1, mean), cex = 0.5,type="b",pch=17)
  # axis(1, labels = FALSE, at = (1 : nrow(species.profile)))
  text(labels = as.character(lapply(strsplit(rownames(species.profile),split = "|",fixed = T),function(x) substr(x[7],start = 4,stop = nchar(x[7])))), x = (1 : nrow(species.profile)), y = rep((min(species.profile) - max(species.profile)) / 10, nrow(species.profile)), srt = 60, xpd = T, adj = 1)
  dev.off()







  png(paste(substr(pdf.file,0,nchar(pdf.file)-4),g_class_names[g],".png",sep=""),height = 1200,width = 1200,pointsize = 18,type = c("cairo"))
  dpar <- par(no.readonly=T)
  layout(matrix(c(1, 2, 2, 3, 3, 3), ncol = 3, byrow = T))


  #set top value default is 5
  top_phylum <- sort(apply(data[which(lapply(strsplit(rownames(data),split = "|",fixed = T),length)==2),],1,sum),decreasing = T)[1:5]
  phylum_color  <- cols_brewer[1:length(top_phylum)]
  names(phylum_color) <- names(top_phylum)
  phylum.profile <- data[names(top_phylum),]
  par(mar = c(15, 5, 4, 4))
  boxplot(t(phylum.profile), cex = 0.5, pch = 19, col = phylum_color, xaxt="n")
  lines(x = (1 : nrow(phylum.profile)), y = apply(phylum.profile, 1, mean), cex = 0.5,type="b",pch=17)
  text(labels = as.character(lapply(strsplit(rownames(phylum.profile),split = "|",fixed = T),function(x) substr(x[2],start = 4,stop = nchar(x[2])))), x = (1 : nrow(phylum.profile)), y = rep((min(phylum.profile) - max(phylum.profile)) / 10, nrow(phylum.profile)), srt = 60, xpd = T, adj = 1)

  #genus
  genus.profile <- c()
  for(i in 1:length(names(top_phylum))){
    tmp_name <- grep(rownames(data),pattern = strsplit(names(top_phylum)[i],split="|",fixed=T)[[1]][2])
    tmp_data <- data[tmp_name,]
    tmp2_data <- tmp_data[which(lapply(strsplit(rownames(data)[tmp_name],split = "|",fixed = T),length)==6),]
    genus.profile <- rbind(genus.profile,tmp2_data)
  }
  top_genus <- sort(apply(genus.profile,1,sum),decreasing = T)[1:15]

  phylum_genus <- as.character(lapply(strsplit(names(top_genus),split="|",fixed = T),function(x) paste(x[1],x[2],sep = "|")))
  names(phylum_genus) <- names(top_genus)
  genus_color <- phylum_color[phylum_genus]
  genus.profile <- genus.profile[names(top_genus),]
  par(mar = c(15, 0, 4, 2))
  boxplot(t(genus.profile), cex = 0.5, pch = 19, col = genus_color, xaxt="n")
  lines(x = (1 : nrow(genus.profile)), y = apply(genus.profile, 1, mean), cex = 0.5,type="b",pch=17)
  # axis(1, labels = FALSE, at = (1 : nrow(genus.profile)))
  text(labels = as.character(lapply(strsplit(rownames(genus.profile),split = "|",fixed = T),function(x) substr(x[6],start = 4,stop = nchar(x[6])))), x = (1 : nrow(genus.profile)), y = rep((min(genus.profile) - max(genus.profile)) / 10, nrow(genus.profile)), srt = 60, xpd = T, adj = 1)

  #species
  species.profile <- c()
  for(i in 1:length(names(top_phylum))){
    tmp_name <- grep(rownames(data),pattern = strsplit(names(top_phylum)[i],split="|",fixed=T)[[1]][2])
    tmp_data <- data[tmp_name,]
    tmp2_data <- tmp_data[which(lapply(strsplit(rownames(data)[tmp_name],split = "|",fixed = T),length)==7),]
    species.profile <- rbind(species.profile,tmp2_data)
  }
  top_species <- sort(apply(species.profile,1,sum),decreasing = T)[1:20]
  phylum_species <- as.character(lapply(strsplit(names(top_species),split="|",fixed = T),function(x) paste(x[1],x[2],sep = "|")))
  names(phylum_species) <- names(top_species)
  species_color <- phylum_color[phylum_species]
  species.profile <- species.profile[names(top_species),]
  par(mar = c(15, 5, 1, 2))
  boxplot(t(species.profile), cex = 0.5, pch = 19, col = species_color, xaxt="n")
  lines(x = (1 : nrow(species.profile)), y = apply(species.profile, 1, mean), cex = 0.5,type="b",pch=17)
  # axis(1, labels = FALSE, at = (1 : nrow(species.profile)))
  text(labels = as.character(lapply(strsplit(rownames(species.profile),split = "|",fixed = T),function(x) substr(x[7],start = 4,stop = nchar(x[7])))), x = (1 : nrow(species.profile)), y = rep((min(species.profile) - max(species.profile)) / 10, nrow(species.profile)), srt = 60, xpd = T, adj = 1)
  dev.off()




}

