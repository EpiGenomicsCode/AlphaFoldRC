#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --mem=60GB
#SBATCH --gpus=1
#SBATCH --time=8:00:00
#SBATCH --account=dml129-engagement_gpu
#SBATCH -p sla-prio,burst
#SBATCH -q burst4x
#SBATCH --exclude=p-gc-3024

time python /storage/icds/RISE/sw8/alphafold/scripts/run/run_alphafold-gpu_2.3.1.py --model_preset=multimer --fasta_paths=/storage/home/jmp579/scratch/example/test.fa --output_dir=/scratch/jmp579/example/OUTPUT
