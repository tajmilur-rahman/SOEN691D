cumulOP <- read.table("~/Documents/git/rupak/scripts/reports/rq34/cumul_churn_ownp.rpt",sep="|",header=T)

plot(cumulOP$d_mp, relDCOP$f_mp, type="l", lwd=1.5, lty=1, col="red",xlab="Cumulative number of developers", ylab="")
lines(cumulOP$d_mp, relDCOP$ownp_mp, type="l", lwd=1.5, lty=2, col="orange")
lines(cumulOP$d_mp, relDCOP$f_rp, type="l", lwd=1.5, lty=3, col="blue")
lines(cumulOP$d_mp, relDCOP$ownp_rp, type="l", lwd=1.5, lty=4, col="green")

legend("bottomright", lty=c(1,2,3,4), col = c("red","orange","green","blue"), legend = c("% files DP","% ownership DP","files RP","ownership RP"))

-------
plot(cumulOP$d_mp, cumulOP$ownp_mp, type="l", lwd=1.5, lty=1, col="red",xlab="Cumulative number of Developers", ylab="")
lines(cumulOP$d_mp, cumulOP$ownp_rp, type="l", lwd=1.5, lty=2, col="orange")
legend("bottomright", lty=c(1,2), col = c("red","orange"), legend = c("% ownership DP","% ownership RP"))
