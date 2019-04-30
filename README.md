Just a repo to test how [snakemake's](https://snakemake.readthedocs.io/en/stable/) parallelisation works when using it locally or on a cluster.

# Set-up
A few dependencies need to be installed, most notably `conda` and `snakemake`.
This needs to be done when on the **access** node (or at least `snakemake` must be available on the access node) so that `snakemake` eventually is available *before* submitting jobs to the cluster, i.e., so that `snakemake`, itself, can be used to perform the submissions (s. Running the workflow on a cluster, below).
N.B. You should **NOT** install any other tools when on the access node. But since `snakemake` is frequently updating, the version which is provided system-wide (if at all) might be outdated and, hence, one has to help her-/himself :woman_shrugging: :man_shrugging:).

```
mkdir -p $HOME/apps
cd $HOME/apps/distfiles # 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod u+x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh # You will need to specify your installation destination; I chose /home/claczny/apps/miniconda3. N.B. You must use the *full* path and can*not* user $HOME/apps/miniconda3.
conda update -n base -c defaults conda # Recommended to make sure you have the most recent conda version available
conda create -n conda_env snakemake
```

# Running
If you want to run the test, you can do so either locally or on a cluster.
When run locally, the information about the threads is printed to stdout.
When run on a cluster, the information is saved in the respective stdout files (s. `cluster.json` for how they are dynamically named based on the node, jobid, and rule that is executed)

1. **locally**
```
srun -N 1 -n 1 -c 10 -p interactive --qos qos-interactive --pty bash -i # First, reserve your compute resources: ONE node, ONE task, TEN cores per task, i.e., 10 cores on a single, physical node.
conda activate conda_env
snakemake --cores 1 # This will show you/print that the {threads} will evaluate to "1" and ONE rule AFTER the other will be run
rm [0-9].txt # Clean up
snakemake --cores 2 # This will show you/print that the {threads} will evaluate to "2" and ONE rule AFTER the other will be run
rm [0-9].txt # Clean up
snakemake --cores 6 # This will show you/print that the {threads} will evaluate to "5" and ONE rule AFTER the other will be run
rm [0-9].txt # Clean up
snakemake --cores 10 # This will show you/print that the {threads} will evaluate to "5" and TWO rules will be run parallel, each with {threads} of 5
rm [0-9].txt # Clean up
snakemake --cores 11 # This will show you/print that the {threads} will evaluate to "5" and TWO rules will be run parallel, each with {threads} of 5
```

or 

2. on a **cluster**
```
./src/snakemake_run.sh # With the default cluster.json, {ncpus} is "1".
# This means that "-N 1 -n 1 -c 1" will be used for EVERY SINGLE job and TWO jobs will be submitted at the same time.
rm [0-9].txt # Clean up
# Now modify  "ncpus" in cluster.json to a value of 2
./src/snakemake_run.sh # {ncpus} in cluster.json is now "2".
# This means that "-N 1 -n 1 -c 2" will be used for EVERY SINGLE job and, still, TWO jobs will be submitted at the same time.
# Yet the {threads} will now be "2", i.e., based on the changed specification in cluster.json.
```
For this, we use the "wrapper" script `./src/snakemake_run.sh` which defines how to submit individual jobs to the cluster using `slurm`.
By default, this wrapper script submits TWO jobs (`-j 2`) to the cluster in parallel.
Here, the behavior of the `-j` option (which is synonymous with `--cores` and `--jobs`) DIFFERS from running `snakemake` *locally*, i.e., two **JOBS** are launched that execute two individual *rules* (instead of defining how many cores-per-rule should be available).
The number of *threads (cores)* for these rules is determined based on the **specifications in `cluster.json`**, i.e., determined after the job has been submitted to the cluster and the job is actually starting (maybe this info is inferred even while the job is pending, but this is a technical detail which, hopefully, does not matter here).

Put differently, when run on a cluster, the `--cores, --jobs, -j` option specifies how many jobs are sent to the submission queue simultaneously.
Accordingly, it is suggested to not specify a high value here unless you have the capacity (oftentimes the number of simultaneous jobs is limited to some fixed value, e.g., 10 or 100).
Importantly, unless you do not have an extremely large number of jobs that you need to submit, it is not a problem to specify a conservative `-j` value because, as soon as one job is finished, the next job is automatically submitted to the queue by `snakemake`.
This is why the wrapper script has `-j 10` here.

