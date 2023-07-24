#This script configures and submits a slurm job that executes
#the MSA phase of Alphafold for the given input


# Administrative items
readonly SCRIPT=$(basename $0)
readonly REVISION="1.0"
readonly DATE="2023-07-24"

# Check arguments before continuing
if [ $# -ne 4 ]; then
   echo "Usage: ${SCRIPT} <INPUTFILE_PATH> <OUTPUTDIR_PATH> <ALLOCATION> <MODEL>"
   echo ""
   echo "Date:   ${DATE}"
   echo ""
   exit 1
fi

#parse input
INPUT=$1
OUTPUT=$2
ALLOCATION=$3
MODEL=$4

#create  output directory if it doesn't exist
mkdir -p $OUTPUT
INPUTFILE=$(basename $INPUT .fa)
OUTPUTFULL=$(realpath $OUTPUT)

#Create slurm script and submit
HEADER="#!/bin/bash\n#SBATCH --nodes=1\n#SBATCH --ntasks=8\n#SBATCH --mem=80GB\n#SBATCH --time=6:00:00\n#SBATCH --account=${ALLOCATION}\n --partition=${ALLOCATION}\n"
echo -e $HEADER > $OUTPUT/$INPUTFILE\.slurm
echo "time python /storage/icds/RISE/sw8/alphafold/scripts/run/run_alphafold-msa_2.3.1.py --model_preset=$MODEL --fasta_paths=$INPUT --output_dir=$OUTPUTFULL" >> $OUTPUT/$INPUTFILE\.slurm

cd $OUTPUT
sbatch $INPUTFILE\.slurm
