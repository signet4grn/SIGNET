#!/usr/bin/env python3

import pandas as pd
import numpy as np
import argparse
import subprocess
import statsmodels.api as sm


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='adjust the gene expression by the covariates file,'
        'output Gexp.data:  sample * gene, pure matrix without any col or row names')
    # genepos:  Column 1 is chr#; Column 2 is start pos; Column 3 is end pos;
    parser.add_argument(
        '--expr', help='the expression matrix for the first cohort, in *.bed.gz file format')
    parser.add_argument('--covf',help='the covariates file, format: cov ID * sample, with header ID, sample1, sample2...')
    parser.add_argument(
        '--prefix', help='the prefix for the output file 1,output *.gexp.data')
    args = parser.parse_args()

    print('start to loading data')
    print('the expression file is '+ args.expr)
    print('the covariates file is '+ args.covf)
    print('the output file is '+ args.prefix+'.gexp.data')
    print('processing .........')
    expr = pd.read_csv(args.expr, sep='\t', index_col=None)
    # set the index to the gene_id
    expr.index = expr.gene_id
    n_markers, n_col = expr.shape
    n_samples = n_col - 4
    # load the covariates data
    covf = pd.read_csv(args.covf,sep='\t',index_col=None)
    covf = covf.drop('ID',axis=1)
    # construct the output data
    exp_adjusted = np.zeros((n_samples,n_markers))
    # regression 
    for i in range(n_markers):
        tmpy = expr.iloc[i][4:(n_col)].astype(float)
        tmpx = np.transpose(np.asarray(covf))
        tmpx = sm.add_constant(tmpx)
        model = sm.OLS(tmpy,tmpx)
        result = model.fit()
        exp_adjusted[:,i] = result.resid
        if(i % 5000 == 0):
            print('processed %d markers' % i)
    print('done!')
    exp_adjusted = pd.DataFrame(exp_adjusted)
    exp_adjusted.to_csv(args.prefix + '.gexp.data',sep='\t', index=False,header=False)