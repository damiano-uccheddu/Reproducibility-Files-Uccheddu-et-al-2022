# *-----------------------------------------------------------------------------------------------* 
# *>> Sequence and cluster analysis performed in R (Version 4.1.2 - November, 2021)
# *-----------------------------------------------------------------------------------------------* 

# capture log close 
# log using "$share_logfile/Data Analysis (SA).log", replace

# *-----------------------------------------------------------------------------------------------* 
# Load data and libraries 
# *-----------------------------------------------------------------------------------------------* 

# Install RTools
# https://cran.rstudio.com/bin/windows/Rtools/

# Set the working directory 
setwd("$r_output")

# Time 
Sys.time() 

# Libraries 
install.packages("readstata13")
install.packages("TraMineR")
install.packages("WeightedCluster")

library("WeightedCluster")
library("readstata13")
library("TraMineR")


# *-----------------------------------------------------------------------------------------------* 
# Sequence analysis for women
# *-----------------------------------------------------------------------------------------------* 

# Data 
Fertility_women     	<- read.dta13("$r_output/SHARE_for_SA_Women_Fertility.dta")
Employment_women  		<- read.dta13("$r_output/SHARE_for_SA_Women_Employment.dta")
Marital_women 			<- read.dta13("$r_output/SHARE_for_SA_Women_Marital.dta")

# Define the sequences (Build sequence objects)
Fertility_seq_women		<- seqdef(Fertility_women,   2:36, informat = "STS") # "STS" is the wide format
Employment_seq_women	<- seqdef(Employment_women,  2:36, informat = "STS")
Marital_seq_women		<- seqdef(Marital_women,     2:36, informat = "STS")

# Use transition rates to compute substitution costs on each channel. Dynamic Hamming distance (DHD) 
mcdist_women <- seqdistmc(channels=list(Fertility_seq_women, Employment_seq_women, Marital_seq_women), method="DHD")


# *-----------------------------------------------------------------------------------------------* 
# First step: Choose the best clustering method 
# *-----------------------------------------------------------------------------------------------* 

# Automatic comparison of clustering methods 
allClust_women <- wcCmpCluster(mcdist_women, maxcluster=20, method=c("average", "pam", "beta.flexible", "ward.D2", "diana", "agnes"), pam.combine=FALSE)

summary(allClust_women, max.rank=20)

# Plot PBC, RHC and ASW
pdf('allClust_women_A.pdf', width = 20, height = 30) # Save as PDF (start)
plot(allClust_women, stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3) # lwd is the line width 
dev.off() # Save as PDF (end)

# Plot PBC, RHC and ASW grouped by cluster method
pdf('allClust_women_B.pdf', width = 20, height = 30) # Save as PDF (start)
plot(allClust_women, group="method", stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3) # lwd is the line width 
dev.off() # Save as PDF (end)
Sys.time()


# *-----------------------------------------------------------------------------------------------* 
# Second step: Cluster analysis, choose the best number of clusters 
# *-----------------------------------------------------------------------------------------------* 

# Ward cluster
wardCluster_women <- hclust(as.dist(mcdist_women), method = "ward.D")

# Estimate the clustering quality for groupings in 2, 3, ..., ncluster = 20
wardRange_women <- as.clustrange(wardCluster_women, diss = mcdist_women, ncluster = 20)
summary(wardRange_women, max.rank = 2)
Sys.time()

# Plot ASWw HG PBC HC 
pdf('wardRange_women.pdf') # Save as PDF (start), width = 20, height = 30
plot(wardRange_women, stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3)
dev.off() # Save as PDF (end)
Sys.time()

# Perform the cluster analysis using the Ward
clusterward_women <- agnes(mcdist_women, diss = T, method = "ward")


# *-----------------------------------------------------------------------------------------------* 
# *>> Variables for regression analysis 
# *-----------------------------------------------------------------------------------------------* 

mergeid <- Fertility_women[1]

# Other cluster solutions  
family_work_women_2 <- cutree(clusterward_women, k = 2)
cluster_women_2 <- data.frame(pid=mergeid,cluster_2=family_work_women_2)
save.dta13(cluster_women_2, "$r_output/cluster_women_2.dta")

family_work_women_3 <- cutree(clusterward_women, k = 3)
cluster_women_3 <- data.frame(pid=mergeid,cluster_3=family_work_women_3)
save.dta13(cluster_women_3, "$r_output/cluster_women_3.dta")

family_work_women_4 <- cutree(clusterward_women, k = 4)
cluster_women_4 <- data.frame(pid=mergeid,cluster_4=family_work_women_4)
save.dta13(cluster_women_4, "$r_output/cluster_women_4.dta")

family_work_women_5 <- cutree(clusterward_women, k = 5)
cluster_women_5 <- data.frame(pid=mergeid,cluster_5=family_work_women_5)
save.dta13(cluster_women_5, "$r_output/cluster_women_5.dta")

family_work_women_6 <- cutree(clusterward_women, k = 6)
cluster_women_6 <- data.frame(pid=mergeid,cluster_6=family_work_women_6)
save.dta13(cluster_women_6, "$r_output/cluster_women_6.dta")

family_work_women_7 <- cutree(clusterward_women, k = 7)
cluster_women_7 <- data.frame(pid=mergeid,cluster_7=family_work_women_7)
save.dta13(cluster_women_7, "$r_output/cluster_women_7.dta")

family_work_women_8 <- cutree(clusterward_women, k = 8)
cluster_women_8 <- data.frame(pid=mergeid,cluster_8=family_work_women_8)
save.dta13(cluster_women_8, "$r_output/cluster_women_8.dta")

family_work_women_9 <- cutree(clusterward_women, k = 9)
cluster_women_9 <- data.frame(pid=mergeid,cluster_9=family_work_women_9)
save.dta13(cluster_women_9, "$r_output/cluster_women_9.dta")

family_work_women_10 <- cutree(clusterward_women, k = 10)
cluster_women_10 <- data.frame(pid=mergeid,cluster_10=family_work_women_10)
save.dta13(cluster_women_10, "$r_output/cluster_women_10.dta")

family_work_women_11 <- cutree(clusterward_women, k = 11)
cluster_women_11 <- data.frame(pid=mergeid,cluster_11=family_work_women_11)
save.dta13(cluster_women_11, "$r_output/cluster_women_11.dta")

family_work_women_12 <- cutree(clusterward_women, k = 12)
cluster_women_12 <- data.frame(pid=mergeid,cluster_12=family_work_women_12)
save.dta13(cluster_women_12, "$r_output/cluster_women_12.dta")

family_work_women_13 <- cutree(clusterward_women, k = 13)
cluster_women_13 <- data.frame(pid=mergeid,cluster_13=family_work_women_13)
save.dta13(cluster_women_13, "$r_output/cluster_women_13.dta")

family_work_women_14 <- cutree(clusterward_women, k = 14)
cluster_women_14 <- data.frame(pid=mergeid,cluster_14=family_work_women_14)
save.dta13(cluster_women_14, "$r_output/cluster_women_14.dta")

family_work_women_15 <- cutree(clusterward_women, k = 15)
cluster_women_15 <- data.frame(pid=mergeid,cluster_15=family_work_women_15)
save.dta13(cluster_women_15, "$r_output/cluster_women_15.dta")

family_work_women_16 <- cutree(clusterward_women, k = 16)
cluster_women_16 <- data.frame(pid=mergeid,cluster_16=family_work_women_16)
save.dta13(cluster_women_16, "$r_output/cluster_women_16.dta")

family_work_women_17 <- cutree(clusterward_women, k = 17)
cluster_women_17 <- data.frame(pid=mergeid,cluster_17=family_work_women_17)
save.dta13(cluster_women_17, "$r_output/cluster_women_17.dta")

family_work_women_18 <- cutree(clusterward_women, k = 18)
cluster_women_18 <- data.frame(pid=mergeid,cluster_18=family_work_women_18)
save.dta13(cluster_women_18, "$r_output/cluster_women_18.dta")

family_work_women_19 <- cutree(clusterward_women, k = 19)
cluster_women_19 <- data.frame(pid=mergeid,cluster_19=family_work_women_19)
save.dta13(cluster_women_19, "$r_output/cluster_women_19.dta")

family_work_women_20 <- cutree(clusterward_women, k = 20)
cluster_women_20 <- data.frame(pid=mergeid,cluster_20=family_work_women_20)
save.dta13(cluster_women_20, "$r_output/cluster_women_20.dta")



# *-----------------------------------------------------------------------------------------------* 
# *>> Plot the clusters
# *-----------------------------------------------------------------------------------------------* 

labs <- factor(family_work_women_20, labels = paste("Cluster", 1:20))

pdf('Fertility_seq_women.pdf',  width = 20, height = 30)
seqdplot(Fertility_seq_women,   group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()

pdf('Employment_seq_women.pdf', width = 20, height = 30)
seqdplot(Employment_seq_women,  group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()

pdf('Marital_seq_women.pdf',    width = 20, height = 30)
seqdplot(Marital_seq_women,     group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()

Sys.time()


# *-----------------------------------------------------------------------------------------------* 
# Sequence analysis for men
# *-----------------------------------------------------------------------------------------------* 

# Data 
Fertility_men 	<- read.dta13("$r_output/SHARE_for_SA_Men_Fertility.dta")
Employment_men 	<- read.dta13("$r_output/SHARE_for_SA_Men_Employment.dta")
Marital_men 	<- read.dta13("$r_output/SHARE_for_SA_Men_Marital.dta")

# Define the sequences (Build sequence objects)
Fertility_seq_men 	<- seqdef(Fertility_men, 	2:36, informat = "STS") # "STS" is the wide format
Employment_seq_men 	<- seqdef(Employment_men, 	2:36, informat = "STS")
Marital_seq_men 	<- seqdef(Marital_men, 		2:36, informat = "STS")

# Use transition rates to compute substitution costs on each channel. Dynamic Hamming distance (DHD) 
mcdist_men <- seqdistmc(channels=list(Fertility_seq_men, Employment_seq_men, Marital_seq_men), method="DHD")


# *-----------------------------------------------------------------------------------------------* 
# First step: Choose the best clustering method 
# *-----------------------------------------------------------------------------------------------* 

# Automatic comparison of clustering methods 
allClust_men <- wcCmpCluster(mcdist_men, maxcluster=20, method=c("average", "pam", "beta.flexible", "ward.D2", "diana", "agnes"), pam.combine=FALSE)

summary(allClust_men, max.rank=20)

# Plot PBC, RHC and ASW
pdf('allClust_men_A.pdf', width = 20, height = 30) # Save as PDF (start)
plot(allClust_men, stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3) # lwd is the line width 
dev.off() # Save as PDF (end)

# Plot PBC, RHC and ASW grouped by cluster method
pdf('allClust_men_B.pdf', width = 20, height = 30) # Save as PDF (start)
plot(allClust_men, group="method", stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3) # lwd is the line width 
dev.off() # Save as PDF (end)
Sys.time()


# *-----------------------------------------------------------------------------------------------* 
# Second step: Cluster analysis, choose the best number of clusters 
# *-----------------------------------------------------------------------------------------------* 

# Ward cluster
wardCluster_men <- hclust(as.dist(mcdist_men), method = "ward.D")

# Estimate the clustering quality for groupings in 2, 3, ..., ncluster = 20
wardRange_men <- as.clustrange(wardCluster_men, diss = mcdist_men, ncluster = 20)
summary(wardRange_men, max.rank = 2)
Sys.time()

# Plot ASWw HG PBC HC 
pdf('wardRange_men.pdf') # Save as PDF (start), width = 20, height = 30
plot(wardRange_men, stat=c("ASW", "CH", "HC", "HGSD", "PBC"), norm="zscore", lwd=3)
dev.off() # Save as PDF (end)
Sys.time()

# Perform the cluster analysis using the Ward
clusterward_men <- agnes(mcdist_men, diss = T, method = "ward")


# *-----------------------------------------------------------------------------------------------* 
# *>> Variables for regression analysis 
# *-----------------------------------------------------------------------------------------------* 

mergeid <- Fertility_men[1]

# Other cluster solutions  
family_work_men_2 <- cutree(clusterward_men, k = 2)
cluster_men_2 <- data.frame(pid=mergeid,cluster_2=family_work_men_2)
save.dta13(cluster_men_2, "$r_output/cluster_men_2.dta")

family_work_men_3 <- cutree(clusterward_men, k = 3)
cluster_men_3 <- data.frame(pid=mergeid,cluster_3=family_work_men_3)
save.dta13(cluster_men_3, "$r_output/cluster_men_3.dta")

family_work_men_4 <- cutree(clusterward_men, k = 4)
cluster_men_4 <- data.frame(pid=mergeid,cluster_4=family_work_men_4)
save.dta13(cluster_men_4, "$r_output/cluster_men_4.dta")

family_work_men_5 <- cutree(clusterward_men, k = 5)
cluster_men_5 <- data.frame(pid=mergeid,cluster_5=family_work_men_5)
save.dta13(cluster_men_5, "$r_output/cluster_men_5.dta")

family_work_men_6 <- cutree(clusterward_men, k = 6)
cluster_men_6 <- data.frame(pid=mergeid,cluster_6=family_work_men_6)
save.dta13(cluster_men_6, "$r_output/cluster_men_6.dta")

family_work_men_7 <- cutree(clusterward_men, k = 7)
cluster_men_7 <- data.frame(pid=mergeid,cluster_7=family_work_men_7)
save.dta13(cluster_men_7, "$r_output/cluster_men_7.dta")

family_work_men_8 <- cutree(clusterward_men, k = 8)
cluster_men_8 <- data.frame(pid=mergeid,cluster_8=family_work_men_8)
save.dta13(cluster_men_8, "$r_output/cluster_men_8.dta")

family_work_men_9 <- cutree(clusterward_men, k = 9)
cluster_men_9 <- data.frame(pid=mergeid,cluster_9=family_work_men_9)
save.dta13(cluster_men_9, "$r_output/cluster_men_9.dta")

family_work_men_10 <- cutree(clusterward_men, k = 10)
cluster_men_10 <- data.frame(pid=mergeid,cluster_10=family_work_men_10)
save.dta13(cluster_men_10, "$r_output/cluster_men_10.dta")

family_work_men_11 <- cutree(clusterward_men, k = 11)
cluster_men_11 <- data.frame(pid=mergeid,cluster_11=family_work_men_11)
save.dta13(cluster_men_11, "$r_output/cluster_men_11.dta")

family_work_men_12 <- cutree(clusterward_men, k = 12)
cluster_men_12 <- data.frame(pid=mergeid,cluster_12=family_work_men_12)
save.dta13(cluster_men_12, "$r_output/cluster_men_12.dta")

family_work_men_13 <- cutree(clusterward_men, k = 13)
cluster_men_13 <- data.frame(pid=mergeid,cluster_13=family_work_men_13)
save.dta13(cluster_men_13, "$r_output/cluster_men_13.dta")

family_work_men_14 <- cutree(clusterward_men, k = 14)
cluster_men_14 <- data.frame(pid=mergeid,cluster_14=family_work_men_14)
save.dta13(cluster_men_14, "$r_output/cluster_men_14.dta")

family_work_men_15 <- cutree(clusterward_men, k = 15)
cluster_men_15 <- data.frame(pid=mergeid,cluster_15=family_work_men_15)
save.dta13(cluster_men_15, "$r_output/cluster_men_15.dta")

family_work_men_16 <- cutree(clusterward_men, k = 16)
cluster_men_16 <- data.frame(pid=mergeid,cluster_16=family_work_men_16)
save.dta13(cluster_men_16, "$r_output/cluster_men_16.dta")

family_work_men_17 <- cutree(clusterward_men, k = 17)
cluster_men_17 <- data.frame(pid=mergeid,cluster_17=family_work_men_17)
save.dta13(cluster_men_17, "$r_output/cluster_men_17.dta")

family_work_men_18 <- cutree(clusterward_men, k = 18)
cluster_men_18 <- data.frame(pid=mergeid,cluster_18=family_work_men_18)
save.dta13(cluster_men_18, "$r_output/cluster_men_18.dta")

family_work_men_19 <- cutree(clusterward_men, k = 19)
cluster_men_19 <- data.frame(pid=mergeid,cluster_19=family_work_men_19)
save.dta13(cluster_men_19, "$r_output/cluster_men_19.dta")

family_work_men_20 <- cutree(clusterward_men, k = 20)
cluster_men_20 <- data.frame(pid=mergeid,cluster_20=family_work_men_20)
save.dta13(cluster_men_20, "$r_output/cluster_men_20.dta")


# *-----------------------------------------------------------------------------------------------* 
# *>> Plot the clusters 
# *-----------------------------------------------------------------------------------------------* 

labs <- factor(family_work_men_20, labels = paste("Cluster", 1:20))

pdf('Fertility_seq_men.pdf', 	width = 20, height = 30)
seqdplot(Fertility_seq_men, 	group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()

pdf('Employment_seq_men.pdf', 	width = 20, height = 30)
seqdplot(Employment_seq_men, 	group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()

pdf('Marital_seq_men.pdf', 		width = 20, height = 30)
seqdplot(Marital_seq_men, 		group = labs, border = NA, with.legend = TRUE, xtlab=15:49)
dev.off()


# *-----------------------------------------------------------------------------------------------* 
# *>> Close 
# *-----------------------------------------------------------------------------------------------* 

Sys.time()
