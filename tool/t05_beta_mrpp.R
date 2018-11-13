profile.table = "{{ profile_table }}"
group.file = "{{ group_file }}"
txt.file = "{{ txt_file }}"
library('vegan')

profile <- read.table(profile.table, header = T, check.names=F,row.names=1,sep="\t",quote="")
group=read.table(group.file,header=F,row.names=1,check.names=F,quote="")
profile <- profile[,rownames(group)]
weighted_unifrac = as.matrix(vegdist(t(profile), method = "bray", diag = T, upper = T))
weighted_unifrac = weighted_unifrac[rownames(group),rownames(group)]

mrpp.weighted_unifrac = mrpp(as.dist(weighted_unifrac), group[,1])

group_name = as.character(unique(group[,1]))
group_name = paste0(group_name, collapse = "~")

# t = as.data.frame(c('weited_unifrac',
t = as.data.frame(c(group_name,
                     mrpp.weighted_unifrac$A,
                     mrpp.weighted_unifrac$delta,
                     mrpp.weighted_unifrac$E.delta,
                     mrpp.weighted_unifrac$Pvalue))
t = t(t)
rownames(t) = 'weited_unifrac'
# colnames(t) = c('beta_div', 'A', 'observe_delta', 'expect_delta', 'p_value')
colnames(t) = c('Group', 'A', 'ObserveDelta', 'ExpectDelta', 'Significance')
write.table(t, file=txt.file, quote=F, sep='\t', row.names=F)
