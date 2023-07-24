![header](header.jpeg)

# AlphafoldRC

This repo provides usage instructions for running DeepMind's [AlphaFold](https://github.com/deepmind/alphafold) on [Penn State's Roar Collab](https://www.icds.psu.edu/) (RC) HPC system.

### Repo Contents
A summary of the contents is listed below:
* [run_alphafold-msa_2.3.1.py](run_alphafold-msa_2.3.1.py) - python runscript for the MSA phase of Alphafold
* [run_alphafold-gpu_2.3.1.py](run_alphafold-gpu_2.3.1.py) - python runscript for the GPU inference phase of Alphafold
* [01_submit_to_CPU-SLURM.sh](01_submit_to_CPU-SLURM.sh) - bash script to generate and submit a slurm job script for running run_alphafold-msa_2.3.1.py
* [02_submit_to_GPU-SLURM.sh](02_submit_to_GPU-SLURM.sh) - bash script to generate and submit a slurm job script for running run_alphafold-gpu_2.3.1.py
* [example](example) - directory containing an example case

### Usage
To use Alphafold on RC, no download or installation is required. Simply load the system module and run the provided scripts.

Step 1: Load the Alphafold module
```bash
$ module load alphafold
```

Step 2: Run the MSA phase
```bash
$ 01_submit_to_CPU-SLURM.sh <INPUTFILE_PATH> <OUTPUTDIR_PATH> <ALLOCATION> <MODEL>

INPUTFILE_PATH = path to input fasta file
OUTPUTDIR_PATH = path to desired output directory
ALLOCATION = the RC account/allocation you want to submit your MSA job to
MODEL = the alphafold model you would like to you (monomer or multimer)
```

Step 3: Run the GPU Inference phase. The input options should correspond to those in step 2, accept a GPU enabled allocation should be used. This step will generate output pdb files that can be analyzed.
```bash
$ 02_submit_to_GPU-SLURM.sh <INPUTFILE_PATH> <OUTPUTDIR_PATH> <ALLOCATION> <MODEL>
```

### Example
Follow the simple example here: [example](example)

### Customization
The options passed to Alphafold can be modified by editing the corresponding .sh file. Supported options include:
```bash
$ python run_alphafold-gpu_2.3.1.py -h
usage: run_alphafold-gpu_2.3.1.py [-h] --fasta_paths FASTA_PATHS
                                  [--use_gpu USE_GPU]
                                  [--gpu_devices GPU_DEVICES]
                                  [--run_relax RUN_RELAX]
                                  [--use_gpu_relax USE_GPU_RELAX]
                                  [--output_dir OUTPUT_DIR]
                                  [--data_dir DATA_DIR]
                                  [--mount_data_dir MOUNT_DATA_DIR]
                                  [--singularity_image_path SINGULARITY_IMAGE_PATH]
                                  [--max_template_date MAX_TEMPLATE_DATE]
                                  [--db_preset {full_dbs,reduced_dbs}]
                                  [--model_preset {monomer,monomer_casp14,monomer_ptm,multimer}]
                                  [--num_multimer_predictions_per_model NUM_MULTIMER_PREDICTIONS_PER_MODEL]
                                  [--benchmark BENCHMARK]
                                  [--use_precomputed_msas USE_PRECOMPUTED_MSAS]

Run AlphaFold structure prediction using SIF image.

optional arguments:
  -h, --help            show this help message and exit
  --fasta_paths FASTA_PATHS
                        Paths to FASTA files, each containing a prediction
                        target that will be folded one after another. If a
                        FASTA file contains multiple sequences, then it will
                        be folded as a multimer. Paths should be separated by
                        commas. All FASTA paths must have a unique basename as
                        the basename is used to name the output directories
                        for each prediction.
  --use_gpu USE_GPU     Enable NVIDIA runtime to run with GPUs.
  --gpu_devices GPU_DEVICES
                        Comma separated list GPU identifiers to set
                        environment variable CUDA_VISIBLE_DEVICES.
  --run_relax RUN_RELAX
                        Whether to do OpenMM energy minimization of each
                        predicted structure.
  --use_gpu_relax USE_GPU_RELAX
                        Whether to do OpenMM energy minimization using GPU.
  --output_dir OUTPUT_DIR
                        Path to a directory that will store the results.
  --data_dir DATA_DIR   Path to directory with supporting data: AlphaFold
                        parameters and genetic and template databases. Set to
                        the target of download_all_databases.sh.
  --mount_data_dir MOUNT_DATA_DIR
                        Path to directory where databases reside.
  --singularity_image_path SINGULARITY_IMAGE_PATH
                        Path to the AlphaFold singularity image.
  --max_template_date MAX_TEMPLATE_DATE
                        Maximum template release date to consider (ISO-8601
                        format: YYYY-MM-DD). Important if folding historical
                        test sets.
  --db_preset {full_dbs,reduced_dbs}
                        Choose preset MSA database configuration - smaller
                        genetic database config (reduced_dbs) or full genetic
                        database config (full_dbs)
  --model_preset {monomer,monomer_casp14,monomer_ptm,multimer}
                        Choose preset model configuration - the monomer model,
                        the monomer model with extra ensembling, monomer model
                        with pTM head, or multimer model
  --num_multimer_predictions_per_model NUM_MULTIMER_PREDICTIONS_PER_MODEL
                        How many predictions (each with a different random
                        seed) will be generated per model. E.g. if this is 2
                        and there are 5 models then there will be 10
                        predictions per input. Note: this FLAG only applies if
                        model_preset=multimer
  --benchmark BENCHMARK
                        Run multiple JAX model evaluations to obtain a timing
                        that excludes the compilation time, which should be
                        more indicative of the time required for inferencing
                        many proteins.
  --use_precomputed_msas USE_PRECOMPUTED_MSAS
                        Whether to read MSAs that have been written to disk.
                        WARNING: This will not check if the sequence, database
                        or configuration have changed.
```

### Acknowledgement
This repository utilizes code and/or draws inspiration from the following related projects:
* https://github.com/prehensilecode/alphafold_singularity
* https://hpc.nih.gov/apps/alphafold2.html
* https://github.com/deepmind/alphafold
