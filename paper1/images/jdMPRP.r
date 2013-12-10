jdMPRDP <- read.table("~/Documents/git/rupak/scripts/reports/rq2/jdMPRP.rpt",sep="|",header=T)
plot(jacMPRP$jd_merge_rel, type="b",lwd=2,cex=0.8, xlab="releases", ylab="dj(mp,rp)")
