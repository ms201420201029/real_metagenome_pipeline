arg <- commandArgs("T")
profile.file <- arg[1]
rows.file <- arg[2]
cols.file <- arg[3]
out.file <- arg[4]
profile.total <- read.table(profile.file,header = T,row.names = 1,sep = "\t",check.names=F)
rows <- read.table(rows.file,header = FALSE,stringsAsFactors = FALSE,check.names=F)[,1]
cols <- rownames(read.table(cols.file,header=FALSE,row.names = 1,sep = "\t",check.names=F))
filter.profile <- profile.total[rows,cols]
filter.profile.out <- cbind(rownames(filter.profile),filter.profile)
colnames(filter.profile.out) <- c("rowName",cols)
write.table(filter.profile.out,file = out.file,row.names = FALSE,col.names = T,quote = FALSE,sep = "\t")
