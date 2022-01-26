#!/bin/bash
#SBATCH -A debug
#SBATCH -n 128
#SBATCH -N 1
#SBATCH -t 0:30:00

cd $SLURM_SUBMIT_DIR
unset DISPLAY

module load r/4.0.0
module load utilities parafly

export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1

ParaFly -c params1.txt -CPU 128 -failed_cmds rerun1.txt
