%%% genosum.m
%%% Calculate the minor allele counts for a chromosome
%
data=load('matched.Geno_chr20.data');
ma=sum(data,1);   %? ma=sum(data,2);
dlmwrite('matched.Geno.ma_chr20',ma,' ');
