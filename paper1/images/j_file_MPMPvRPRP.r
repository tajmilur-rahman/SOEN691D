jFileMPMP<-read.table("~/Documents/git/rupak/scripts/reports/rq34/j_file_mpmp.rpt",sep="|",header=T)
jFileRPRP<-read.table("~/Documents/git/rupak/scripts/reports/rq34/j_file_rprp.rpt",sep="|",header=T)

plot(jFileMPMP$release_pair, jFileMPMP$j_index, ylim=c(0,0.40), type="b", lwd=1.5, lty=1, col="red",xlab="release pairs", ylab="")
lines(jFileMPMP$release_pair, jFileRPRP$j_index, type="b", lwd=1.5, lty=2, col="blue")
legend("topright", lty=c(1,2), col = c("red","blue"), legend = c("J index for DP","J index for RP"))
