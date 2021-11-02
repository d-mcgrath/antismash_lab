#!/bin/bash
#SBATCH --partition=compute # Queue selection
#SBATCH --job-name=anti # Job name
#SBATCH --ntasks=1 # Run on 1 CPUs
#SBATCH --cpus-per-task=1
#SBATCH --mem=5gb # Job memory request
#SBATCH --time=01:00:00 # Time limit hrs:min:sec
#SBATCH --output=logs/antismash_lab_%j.log# Standard output/error
#
# submit a job to Poseidon to run the antiSMASH 6.0.0 pipeline
#
bash run_antismash_pipeline.sh -i mags -c 1 -s .fa -o example_output -t scripts

