%%% filterma5.m
%%% Filter out SNPs with minor alleles less than 5
%
ma=load('matched.Geno.ma');
idx5=find(ma>=5);
dlmwrite('snps5.idx',idx5','delimiter',' ','precision','%.0f');
