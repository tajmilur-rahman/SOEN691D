jDevMPMP<-read.table("~/Documents/git/rupak/scripts/reports/rq34/j_dev_mpmp.rpt",sep="|",header=T)
jDevRPRP<-read.table("~/Documents/git/rupak/scripts/reports/rq34/j_dev_rprp.rpt",sep="|",header=T)

plot(jDevMPMP$release_pair, jDevMPMP$j_index, type="b", lwd=1.5, lty=1, col="red",xlab="release pairs", ylab="")
lines(jDevMPMP$release_pair, jDevRPRP$j_index, type="b", lwd=1.5, lty=2, col="blue")
