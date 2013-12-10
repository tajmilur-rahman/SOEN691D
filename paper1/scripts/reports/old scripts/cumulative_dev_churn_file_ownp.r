relDCOP <- read.csv("~/Documents/git/rupak/scripts/reports/cumulative_dev_churn_file_ownp.rpt")

xrange <- range(relDCOP$devs)

plot(relDCOP$devs, relDCOP$churns, type="l", lwd=1.5, lty=1, col="red",xlab="Cumulative number of developers", ylab="")
lines(relDCOP$devs, relDCOP$ownp, type="l", lwd=1.5, lty=2, col="blue")

legend(xrange[1],150000,c("churns","ownership"), col=c("red","blue"),lty=c("solid","dashed"))
