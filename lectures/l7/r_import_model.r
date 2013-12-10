
fi <- read.table('~/Dropbox/tmp/file_info.in', sep = '|', header= T)

summary(fi)

cor(fi, method = 'spearman')
cor.text(commits, authors, method='spearman')
cor.test(time, authors, method='spearman')
plot(fi)


m <- lm(authors ~ commits + time, data = fi)
summary(m)
plot(m)
