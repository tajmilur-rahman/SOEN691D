devsMPRP <- read.table("~/Documents/git/rupak/scripts/reports/devs_mp_rp.csv",header=T,sep=",")
boxplot(devsMPRP$devs_mp, devsMPRP$devs_rp, names=c("Developers in MP","Developers in RP"))
