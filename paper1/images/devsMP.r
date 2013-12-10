devsMPRP <- read.table("~/Documents/git/rupak/scripts/reports/devsMPRP.rpt",header=T,sep="|")
plot(devsMPRP$release, devsMPRP$devs_mp)
lines(devsMPRP$release, devsMPRP$devs_mp, type='h')
