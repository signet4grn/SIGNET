%%% genosum.m
%%% Calculate the minor allele counts for a chromosome
%
data=load('matched.Geno_chr21.data');
ma=sum(data,1);   %? ma=sum(data,2);
dlmwrite('matched.Geno.ma_chr21',ma,' ');
