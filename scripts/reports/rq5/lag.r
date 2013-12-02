rplag <- read.table('~/Documents/git/rupak/scripts/reports/rq5/rp_lag.rpt', sep = '|', header = T)
mplag <- read.table('~/Documents/git/rupak/scripts/reports/rq5/mp_lag.rpt', sep = '|', header = T)
summary(rplag)
summary(mplag)
wilcox.test(mplag$lag, rplag$lag)
qqnorm(rplag$lag)
qqnorm(mplag$lag)
boxplot(rplag$lag+1, mplag$lag+1, log = 'y')
length(rplag$lag)
length(mplag$lag)
