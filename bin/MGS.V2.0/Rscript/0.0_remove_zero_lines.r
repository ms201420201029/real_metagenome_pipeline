# $1: profile file : LF_1000.profile
# $2: threshold of numbers of abundances greater than 0 in one line
args <- commandArgs("T")
profile=read.table(args[1]) #$1

save_or_rm <- function(vector){
  number_greater_0 = length(which(vector > 0))
  if(number_greater_0 >= as.numeric(args[2])){ 
    T
  }else{
    F
  }
}

check = apply(profile, 1, save_or_rm)
profile_final=profile[check,]
write.table(profile_final, paste("reduced_", args[1], sep=""), quote=F)

