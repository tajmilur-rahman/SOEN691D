plot(devsMPRP$devs_mp,type="b",lwd=2,xaxt="n",ylim=c(0,20000),col="black",xlab="release",ylab="developers",main="developers during merge period and release periods for releases")
axis(1,at=1:length(devsMPRP$release),labels=devsMPRP$release)
lines(devsMPRP$devs_rp,col="red",type="b",lwd=2)

legend("topright",legend=c("Devs in MP","Devs in RP"),lty=1,lwd=2,pch=21,col=c("black","red"),ncol=2,bty="n",cex=0.8,text.col=c("black","red"),inset=0.01)
