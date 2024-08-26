#!/bin/bash

CONDA_ENV="<insert conda env path"
ALPHAMSA="<insert run_alphafold-msa_2.3.1.py path>"
ALPHAGPU="<insert run_alphafold-gpu_2.3.2.py path>"

WORKINGDIR="<working directory path>"
INPUT="<fasta file's path>"
CPU_OUTPUT="$WORKINGDIR/CPU-SLURM"
GPU_OUTPUT="$WORKINGDIR/GPU-SLURM"
LOGFILE="$WORKINGDIR/job_status.log"
CPU_JOBIDFILE="$WORKINGDIR/cpu_job_ids.txt"
CONTAINER = "<alphafold extracted sif file, example folder is alphafold-msa_2.3.1>"

STRUCT="$WORKINGDIR/DESIGN-ESM"
HEADER_CPU="#!/bin/bash\n#SBATCH --nodes=1\n#SBATCH --ntasks=4\n#SBATCH --mem=60GB\n#SBATCH --time=6:00:00\n#SBATCH --partition=open\n"
HEADER_GPU="#!/bin/bash\n#SBATCH --nodes=1\n#SBATCH --ntasks=8\n#SBATCH --mem=60GB\n#SBATCH --gpus=1\n#SBATCH --time=8:00:00\n#SBATCH --account=gja2_a_gpu\n#SBATCH -p sla-prio,burst\n#SBATCH -q burst4x\n#SBATCH --exclude=p-gc-3024\n"

source /storage/icds/RISE/sw8/anaconda/anaconda3/etc/profile.d/conda.sh
conda activate $CONDA_ENV

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

mkdir -p "$CPU_OUTPUT"
mkdir -p "$GPU_OUTPUT"
mkdir -p "$STRUCT"

> "$CPU_JOBIDFILE"

echo "Job Status Log" | tee "$LOGFILE"
echo "=================" | tee -a "$LOGFILE"

cd "$INPUT"
for file in *.fa; do
    JOB_NAME=$(basename "$file" .fa)
    JOB_OUTPUT="$STRUCT/$JOB_NAME"
    LOGDIR="$WORKINGDIR/logs/$JOB_NAME"
    mkdir -p "$LOGDIR"

    if [ -d "$JOB_OUTPUT" ] && [ -f "$JOB_OUTPUT/features.pkl" ]; then
        echo "Job for $file already completed or features.pkl already exists." | tee -a "$LOGFILE"
    else
        CPU_SLURM_SCRIPT="$CPU_OUTPUT/$file.slurm"
        echo "#!/bin/bash" > "$CPU_SLURM_SCRIPT"
        echo "#SBATCH --output=$LOGDIR/${JOB_NAME}_cpu_%j.log" >> "$CPU_SLURM_SCRIPT"
        echo -e "$HEADER_CPU" >> "$CPU_SLURM_SCRIPT"
        
        echo "start_time=\$(date +%s)" >> "$CPU_SLURM_SCRIPT"
        echo "vmstat 1 | awk '{now=strftime(\"%Y-%m-%d %H:%M:%S \"); print now \$0}' > $LOGDIR/${JOB_NAME}_cpu_usage.log &" >> "$CPU_SLURM_SCRIPT"
        echo "vmstat_pid=\$!" >> "$CPU_SLURM_SCRIPT"
        
        echo "time singularity run -B \"/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db\" -B \"$INPUT\" -B \"/tmp\" --env CUDA_VISIBLE_DEVICES=0,NVIDIA_VISIBLE_DEVICES=0,TF_FORCE_UNIFIED_MEMORY=1,XLA_PYTHON_CLIENT_MEM_FRACTION=4.0 $CONTAINER --fasta_paths=$INPUT/$file --uniref90_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/uniref90/uniref90.fasta --mgnify_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/mgnify/mgy_clusters_2022_05.fa --template_mmcif_dir=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/pdb_mmcif/mmcif_files --obsolete_pdbs_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/pdb_mmcif/obsolete.dat --uniprot_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/uniprot/uniprot.fasta --pdb_seqres_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/pdb_seqres/pdb_seqres.txt --uniref30_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/uniref30/UniRef30_2021_03 --bfd_database_path=/storage/icds/RISE/sw8/alphafold/alphafold_2.3_db/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt --output_dir=$STRUCT --max_template_date=2040-01-01 --db_preset=full_dbs --model_preset=multimer --use_precomputed_msas=True --logtostderr" >> "$CPU_SLURM_SCRIPT"
        
        echo "kill \$vmstat_pid" >> "$CPU_SLURM_SCRIPT"
        echo "end_time=\$(date +%s)" >> "$CPU_SLURM_SCRIPT"
        echo "echo \"Total execution time: \$((end_time - start_time)) seconds\" >> $LOGDIR/${JOB_NAME}_cpu_time.log" >> "$CPU_SLURM_SCRIPT"

        JOB_ID=$(sbatch "$CPU_SLURM_SCRIPT" | awk '{print $4}')
        echo "$file $JOB_ID" >> "$CPU_JOBIDFILE"
        echo "Submitted batch job $JOB_ID for $file" | tee -a "$LOGFILE"
    fi
done

cd "$INPUT"
for file in *.fa; do
    JOB_NAME=$(basename "$file" .fa)
    JOB_OUTPUT="$STRUCT/$JOB_NAME"
    LOGDIR="$WORKINGDIR/logs/$JOB_NAME"

    CPU_JOB_ID=$(grep "$file" "$CPU_JOBIDFILE" | awk '{print $2}')
    
    if [ -d "$JOB_OUTPUT" ] && [ -f "$JOB_OUTPUT/features.pkl" ]; then
        echo "features.pkl already exists for $file, submitting GPU job without dependency." | tee -a "$LOGFILE"
        GPU_DEPENDENCY=""
    else
        GPU_DEPENDENCY="--dependency=afterok:$CPU_JOB_ID"
    fi

    GPU_SLURM_SCRIPT="$GPU_OUTPUT/$file.slurm"
    echo "#!/bin/bash" > "$GPU_SLURM_SCRIPT"
    echo "#SBATCH --output=$LOGDIR/${JOB_NAME}_gpu_%j.log" >> "$GPU_SLURM_SCRIPT"
    echo -e "$HEADER_GPU\n#SBATCH $GPU_DEPENDENCY\n" >> "$GPU_SLURM_SCRIPT"
    
    echo "start_time=\$(date +%s)" >> "$GPU_SLURM_SCRIPT"
    echo "vmstat 1 | awk '{now=strftime(\"%Y-%m-%d %H:%M:%S \"); print now \$0}' > $LOGDIR/${JOB_NAME}_gpu_cpu_usage.log &" >> "$GPU_SLURM_SCRIPT"
    echo "vmstat_pid=\$!" >> "$GPU_SLURM_SCRIPT"
    
    echo "while true; do" >> "$GPU_SLURM_SCRIPT"
    echo "    if squeue -h -j \$SLURM_JOB_ID -t RUNNING > /dev/null 2>&1; then" >> "$GPU_SLURM_SCRIPT"
    echo "        nvidia-smi --query-gpu=timestamp,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv -l 1 > $LOGDIR/${JOB_NAME}_gpu_usage.log &" >> "$GPU_SLURM_SCRIPT"
    echo "        nvidia_smi_pid=\$!" >> "$GPU_SLURM_SCRIPT"
    echo "        break" >> "$GPU_SLURM_SCRIPT"
    echo "    fi" >> "$GPU_SLURM_SCRIPT"
    echo "    sleep 5" >> "$GPU_SLURM_SCRIPT"
    echo "done" >> "$GPU_SLURM_SCRIPT"
    
    echo "time python $ALPHAGPU --num_multimer_predictions_per_model=1 --model_preset=multimer --output_dir=$STRUCT --fasta_paths=$INPUT/$file" >> "$GPU_SLURM_SCRIPT"
    
    echo "kill \$vmstat_pid" >> "$GPU_SLURM_SCRIPT"
    echo "kill \$nvidia_smi_pid" >> "$GPU_SLURM_SCRIPT"
    echo "end_time=\$(date +%s)" >> "$GPU_SLURM_SCRIPT"
    echo "echo \"Total execution time: \$((end_time - start_time)) seconds\" >> $LOGDIR/${JOB_NAME}_gpu_time.log" >> "$GPU_SLURM_SCRIPT"
    
    echo "python $WORKINGDIR/generate_summary.py $LOGDIR $JOB_NAME" >> "$GPU_SLURM_SCRIPT"

    sbatch "$GPU_SLURM_SCRIPT"
    echo "Submitted GPU batch job for $file with dependency on CPU job $CPU_JOB_ID" | tee -a "$LOGFILE"
done
