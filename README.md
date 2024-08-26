![header](header.jpeg)

# AlphaFold2 Protein Structure Prediction Pipeline for ROAR via Open OnDemand

This repository contains a set of scripts and configuration files for running AlphaFold2 protein structure predictions using Penn State's ROAR high-performance computing environment via Open OnDemand.

## Overview

The pipeline automates the process of running AlphaFold2 predictions for multiple protein sequences on ROAR, including:

1. Sequence preparation
2. CPU-based MSA generation
3. GPU-based structure prediction
4. Result analysis and visualization

## Accessing ROAR via Open OnDemand

1. Visit the ROAR Open OnDemand portal: https://portal.roar.psu.edu
2. Log in with your Penn State credentials
3. Use the dashboard to access ROAR resources and manage your jobs

## Directory Structure

- `example/`: Contains a test.fa file for testing the pipeline.
- `example/OUTPUT_example_07242023`: Contains example output files. Delete this directory before running the pipeline on the test.fa file.

## Key Scripts

### AutomaticallyTrigger.sh

This is the main script that orchestrates the entire pipeline on ROAR. It:

1. Sets up the ROAR environment
2. Submits CPU jobs for MSA generation
3. Submits GPU jobs for structure prediction
4. Creates a dependency tree for each cpu job and triggers the gpu jobs only on successful completion of the cpu jobs
4. Manages job dependencies and logging

### run_alphafold-msa_2.3.1.py and run_alphafold-gpu_2.3.1.py

These scripts run the MSA generation and structure prediction steps of AlphaFold2 on ROAR's CPU and GPU nodes, respectively.

## Generate Summary Script

The `generate_summary.py` script is used to create a summary of CPU and GPU utilization during the AlphaFold2 run. It processes the log files generated during the job execution and produces a summary report.

### Output

The script generates a summary file named `<job_name>_utilization_summary.txt` in the log directory for each job. This file contains:

- Average and maximum CPU usage
- Average and maximum GPU usage
- Average and maximum GPU memory usage

## Environment Setup

### Conda Environment

1. Create a new conda environment using the provided `environment.yml` file:
   ```
   conda env create -f environment.yml
   ```

2. Activate the environment:
   ```
   conda activate myenv
   ```

3. If you need to install additional packages not included in the environment.yml, you can use:
   ```
   pip install -r requirements.txt
   ```

The `environment.yml` file contains all the necessary conda packages for running the AlphaFold2 pipeline. The `requirements.txt` file contains additional Python packages that sometimes are needed.

### Updating the Conda Environment in AutomaticallyTrigger.sh

Replace the conda environment path in the AutomaticallyTrigger.sh script:

```bash
CONDA_ENV="/path/to/your/myenv"
```

## Usage on ROAR via Open OnDemand

1. Upload your input FASTA files to a directory on ROAR and update the `INPUT` variable in `AutomaticallyTrigger.sh` to the path of your input FASTA files.
2. Use the ROAR OnDemand file browser to navigate to your project directory.
3. Open a terminal session via OnDemand's "Clusters" > "ROAR Shell Access" menu.
4. Adjust the paths and parameters in `AutomaticallyTrigger.sh` as necessary for ROAR.
5. Submit the main job using SLURM on ROAR:

```bash
chmod +x AutomaticallyTrigger.sh
./AutomaticallyTrigger.sh
```

8. Monitor your job status through the OnDemand dashboard. Alternatively, you can use the `squeue` command to monitor your jobs.

```bash
squeue -u $USER
```

## Dependencies on ROAR

- Singularity/Apptainer (available on ROAR)
- AlphaFold2 (version 2.3.1 or 2.3.2, installed on ROAR) can be installed through the sif file provided by the AlphaFold team. Visit https://cloud.sylabs.io/library/prehensilecode/alphafold_singularity/alphafold

## Output

The pipeline generates several output directories on ROAR:

- `CPU-SLURM/`: Contains SLURM scripts for CPU jobs
- `GPU-SLURM/`: Contains SLURM scripts for GPU jobs
- `DESIGN-ESM/`: Contains AlphaFold2 output for each prediction
- `logs/`: Contains log files for each job

## Notes for ROAR Usage

- This pipeline is specifically designed for use on Penn State's ROAR cluster via Open OnDemand.
- Adjust the SLURM parameters in `AutomaticallyTrigger.sh` according to ROAR's specifications and your allocation.
- Have a look at the key variables in `AutomaticallyTrigger.sh` and adjust them according to your project specifically, such as the `INPUT`, `CPU_OUTPUT`, `GPU_OUTPUT`, `LOGFILE`, `CPU_JOBIDFILE`, `STRUCT`, `HEADER_CPU`, `HEADER_GPU` variables.
- Ensure that you have the necessary permissions and allocations on ROAR to run AlphaFold2 jobs.

## ROAR Resources

- ROAR User Guide: https://www.icds.psu.edu/computing-services/roar-user-guide/
- ROAR OnDemand Guide: https://www.icds.psu.edu/computing-services/roar-user-guide/open-ondemand/
- ROAR Support: https://www.icds.psu.edu/computing-services/support/


