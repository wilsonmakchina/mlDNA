###
install.packages("mlDNA")

library(mlDNA)
source("http://bioconductor.org/biocLite.R")
options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")
biocLite("GeneSelector")
biocLite("qvalue")


install.packages('mlDNA')
install.packages('bigmemory')
#load mlDNA and related packages
library(mlDNA)
library(bigmemory)
#CPU number
cpus <- 1
# file directory for storing PSOL iteration results
PSOLResDic <- "/Users/Apple/Downloads/mlDNA_test/PSOL"
dir.create(PSOLResDic, showWarnings = FALSE)
#file directory for storing network-related results
netResFileDic <- "/Users/Apple/Downloads/mlDNA_test/network/"
dir.create(netResFileDic, showWarnings = FALSE)

########################
#load sample data.
data(mlDNA)
#get gene expression data under control condition. Rownames and colnames are gene IDs and sample IDs, respectively.
ControlExpMat <- as.matrix(sampleData$ControlExpMat)
#get gene expression data under salt stress condition. Rownames and colnames are gene IDs and sample IDs, respectively
SaltExpMat <- as.matrix(sampleData$StressExpMat)
#get known salt stress-related genes (positive samples in the machine learning process)
positiveSamples <- as.character(sampleData$KnownSaltGenes)
# take a glance at the sample data
#Gene numbers, and sample size in ControlExpMat
dim(ControlExpMat)
#Expression values for the first five genes in ControlExpMat
ControlExpMat[1:5,]
#Gene numbers, and sample size in SaltExpMat
dim(SaltExpMat)
#Expression values for the first five genes in SaltExpMat
SaltExpMat[1:5,]
#Number of positive samples
length(positiveSamples)
#First 10 genes in positiveSamples
positiveSamples[1:10]



###############################
#Create two vectors for describing the sample information in the ControlExpMat and SaltExpMat.
#The numbers in these two vectors represent biological conditions.
#The replications under the same conditions were denoted with the same number.
#Two expression datasets should contain the same number of condtions.
sampleVec1 <- c(1, 2, 3, 4, 5, 6)
sampleVec2 <- c(1, 2, 3, 4, 5, 6)
#generate expression feature matrix with totally 32 characteristics for four measures including z-Score, fold change, cv and absoulte expression value)
featureMat <- expFeatureMatrix( expMat1 = ControlExpMat, sampleVec1 = sampleVec1, expMat2 = SaltExpMat, sampleVec2 = sampleVec2, logTransformed = TRUE, base = 2, features = c("zscore", "foldchange", "cv", "expression") )
#take a glance at the sample data
dim(featureMat)
featureMat [1:5,]


###############################
#"unlabeled" samples are genes not included in the positive sample set
unlabelSamples <- setdiff( rownames(featureMat), positiveSamples )
#start to implement PSOL algorithm. Note that the running time of PSOL algorithm is related to the iteration number, the size of positive sample set and the number of "unlabeled" samples. The parallel computing is highly recommended here.
#first, selecting an initial set of negative samples (i.e., "non-informative" genes) for building ML-based classification model. Three results ("featureMatrix_ED_adjmat_bfile", "featureMatrix_ED_adjmat_dfile" and "PSOL_InitialNegativeSelection_res.RData") will be generated in the file directory PSOLResDic. The first two are the bigmatrix backing and description files of adjacency matrix recording the Euclidean distances between any pairs of genes included in microarray dataset.
InitalRes <- PSOL_InitialNegativeSelection(featureMatrix = featureMat, positives = positiveSamples, unlabels = unlabelSamples, negNum = length(positiveSamples), cpus = cpus, PSOLResDic = PSOLResDic)
#get initial negative set and the updated unlabeled samples
negatives <- InitalRes$negatives
unlables <- InitalRes$unlabels
#Then, expanding negative samples at different iteration times of PSOL. The Random forest algorithm is selected to build ML-based prediction model, whose performance is eccessed with five-fold cross validation test.
PSOL_NegativeExpansion(featureMat = featureMat, 
                       positives = positiveSamples, negatives = negatives, unlabels = unlables, cpus = cpus, iterator = 50, cross = 5, TPR = 0.98, method = "randomForest", plot = TRUE, trace = TRUE, PSOLResDic = PSOLResDic, ntrees = 200 )
#extract PSOL results at the iteration times 1:10
res <- PSOL_ResultExtraction ( PSOLResDic, iterations = c(1:15) )
#obtain signal genes (genes in positive and unlabeled sample sets) at the 12th iteration of PSOL
signalGenes <- c( res[[12]]$positives, res[[12]]$unlabels )
#If plot is TRUE in the function "PSOL_NegativeExpansion", the distribution of filtered-out gene number and AUC at different iteration times (see Figure 1) will be automatically drawn in the file "PSOL_NegativeIncreasement.pdf". The detailed numbers can be found in the file "PSOL_NegativeIncreasement.txt"