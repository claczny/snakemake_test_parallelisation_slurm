#!/bin/bash -l
SLURM_ARGS="-p {cluster.partition} -N 1 -n {cluster.n} -c {cluster.ncpus} -t {cluster.time} --job-name={cluster.job-name} -o {cluster.output} -e {cluster.error}"
(date; conda activate conda_env; snakemake -j 2 --cluster-config cluster.json --cluster "sbatch $SLURM_ARGS" -s Snakefile -p; date) &> smk.log

