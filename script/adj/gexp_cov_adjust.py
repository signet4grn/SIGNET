#!/usr/bin/env python3

import pandas as pd
import numpy as np
import argparse
import subprocess
import statsmodels.api as sm


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Adjust the gene expressions by covariates,'
        'output Gexp.data as a #sample * #gene matrix without column or row names')
    # genepos:  Column 1 is chr#; Column 2 is start pos; Column 3 is end pos;
    parser.add_argument(
        '--expr', help='expression matrix for the first cohort in *.bed.gz file format')
    parser.add_argument('--covf',help='covariates file in format: #covs * #samples with headers cov ID, sample1, sample2...')
    parser.add_argument(
        '--prefix', help='prefix for the output file *.gexp.data')
    args = parser.parse_args()

    print('Loading data...')
    print('  The expression file is '+ args.expr)
    print('  The covariates file is '+ args.covf)
    print('  The output file is '+ args.prefix+'.gexp.data')
    print('Processing...')
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
            print('  %d markers processed' % i)
    print('  Completed!')
    exp_adjusted = pd.DataFrame(exp_adjusted)
    exp_adjusted.to_csv(args.prefix + '.gexp.data',sep='\t', index=False,header=False)
