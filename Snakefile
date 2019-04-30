"""
Author: C. Laczny
Affiliation: ESB group LCSB UniLU
Aim: 
Date: [2019-04-30]
Run: snakemake -s Snakefile
Latest modification:
"""
#from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider
#HTTP = HTTPRemoteProvider()

configfile: "config.yaml"

#DATA_DIR = config["data_dir"]
#RESULTS_DIR = config["results_dir"]

SAMPLES = range(0,10)

rule all:
    input: expand("{sample}.txt", sample=SAMPLES)

rule rule1:
    output: "{sample}.txt"
    message: "##### Sleeping for {wildcards.sample} #####"
    threads: config["threads"]
    shell:
        """
        date
        echo "Threads: {threads}"
        sleep 20
        touch {output}
        date
        """
