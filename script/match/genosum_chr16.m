%%% genosum.m
%%% Calculate the minor allele counts for a chromosome
%
data=load('../../data/match/matched.Geno_chr16.data');
ma=sum(data,1);   %? ma=sum(data,2);
dlmwrite('../../data/match/matched.Geno.ma_chr16',ma,' ');
