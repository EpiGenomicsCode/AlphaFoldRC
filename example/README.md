# Introduction
This example provides steps for generating .pdb files (structure prediction) for an input multimer fasta file on the PSU RC system

### Step 1:
Log onto an RC login/submit node
```bash
$ ssh submit.hpc.psu.edu
```

### Step 2:
Move to your scratch directory and copy the example directory
```bash
$ cd ~/scratch
$ cp -r /storage/icds/RISE/sw8/alphafold/example .
$ cd example
```

### Step 3:
Set up the software environment
```bash
$ module load alphafold
```

### Step 4:
Run the MSA phase. Here we will use the open allocation and the multimer model
```bash
$ 01_submit_to_CPU-SLURM.sh $PWD/test.fa ./OUTPUT open multimer
```

You can monitor your job by checking the contents of the OUTPUT directory. You can also use the squeue command to check the status of your job
```bash
$ squeue -u $USER
```

### Step 5:
Once the MSA job completes, submit the next job which uses a GPU allocation to run inference. Replace <GPU_ALLOCATION> with your GPU allocation name.
```bash
$ cd ~/scratch/example
$ 02_submit_to_GPU-SLURM.sh $PWD/test.fa ./OUTPUT <GPU_ALLOCATION> multimer
```
The predicted pdbs (along with other Alphafold output) can be found in the OUTPUT/test directory.
```bash
$ ll OUTPUT/test
total 148121
-rw-rw-r-- 1 jmp579 jmp579_collab  7049878 Jul 24 15:40 features.pkl
drwxrwsr-x 3 jmp579 jmp579_collab     1024 Jul 24 15:05 msas
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 ranked_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 ranked_1.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 ranked_2.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 ranked_3.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 ranked_4.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab      527 Jul 24 15:50 ranking_debug.json
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:42 relaxed_model_1_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:44 relaxed_model_2_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:46 relaxed_model_3_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:48 relaxed_model_4_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   249165 Jul 24 15:50 relaxed_model_5_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab    17137 Jul 24 15:50 relax_metrics.json
-rw-rw-r-- 1 jmp579 jmp579_collab 28278174 Jul 24 15:42 result_model_1_multimer_v3_pred_0.pkl
-rw-rw-r-- 1 jmp579 jmp579_collab 28278174 Jul 24 15:44 result_model_2_multimer_v3_pred_0.pkl
-rw-rw-r-- 1 jmp579 jmp579_collab 28278174 Jul 24 15:46 result_model_3_multimer_v3_pred_0.pkl
-rw-rw-r-- 1 jmp579 jmp579_collab 28278174 Jul 24 15:48 result_model_4_multimer_v3_pred_0.pkl
-rw-rw-r-- 1 jmp579 jmp579_collab 28278174 Jul 24 15:50 result_model_5_multimer_v3_pred_0.pkl
-rw-rw-r-- 1 jmp579 jmp579_collab     1075 Jul 24 15:50 timings.json
-rw-rw-r-- 1 jmp579 jmp579_collab   124335 Jul 24 15:42 unrelaxed_model_1_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   124335 Jul 24 15:44 unrelaxed_model_2_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   124335 Jul 24 15:46 unrelaxed_model_3_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   124335 Jul 24 15:48 unrelaxed_model_4_multimer_v3_pred_0.pdb
-rw-rw-r-- 1 jmp579 jmp579_collab   124335 Jul 24 15:50 unrelaxed_model_5_multimer_v3_pred_0.pdb
```
