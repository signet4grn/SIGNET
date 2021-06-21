%%% masummary.m
%%% Calculate minor allele frequency of each SNP
%
n = load("sz"); %n is the sample size
ma=load("matched.Geno.ma");
idx5=find(ma>=5);
maf5=ma(idx5)/(n*2);

sum(maf5<0.01) %maf<0.01
sum(maf5>=0.01&maf5<0.05) %0.01=<maf<0.05
sum(maf5>=0.05) %maf>=0.05

dlmwrite(strcat(getenv("SIGNET_TMP_ROOT"),"/tmpg/new.Geno.maf"),maf5',' ');

