relDCOP <- read.table("~/Documents/git/rupak/scripts/reports/cumul_churn_ownp.rpt",sep="|",header=T)

plot(relDCOP$d_mp, relDCOP$f_mp, type="l", lwd=1.5, lty=1, col="red",xlab="Cumulative number of developers", ylab="")
lines(relDCOP$d_mp, relDCOP$ownp_mp, type="l", lwd=1.5, lty=2, col="orange")
lines(relDCOP$d_mp, relDCOP$f_rp, type="l", lwd=1.5, lty=3, col="blue")
lines(relDCOP$d_mp, relDCOP$ownp_rp, type="l", lwd=1.5, lty=4, col="green")

legend("bottomright", lty=c(1,2,3,4), col = c("red","orange","green","blue"), legend = c("files MP","ownership MP","files RP","ownership RP"))

-------
plot(relDCOP$f_mp, relDCOP$ownp_mp, type="l", lwd=1.5, lty=1, col="red",xlab="Cumulative number of files", ylab="")
lines(relDCOP$f_mp, relDCOP$ownp_rp, type="l", lwd=1.5, lty=2, col="orange")

legend("bottomright", lty=c(1,2), col = c("red","orange"), legend = c("ownership MP","ownership RP"))
