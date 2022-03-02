#!/bin/bash

#SBATCH --dependency=afterok:418823
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=2G
#SBATCH -J metaSnvGlobalCdiff1pSPGCII
#SBATCH -o metaSnvGlobalCdiff1pSPGCII."%j".out
#SBATCH -e metaSnvGlobalCdiff1pSPGCII."%j".err 
#SBATCH -t 14-0 # "minutes", "minutes:seconds", "hours:minutes:seconds", "days-hours", "days-hours:minutes" 
threads=12

#source /etc/profile.d/modules.sh # required to use module in qsub job
#module avail

source /g/bork3/home/rossum/.bash_profile
module load samtools
module load python

metasnvExeDir="/g/scb2/bork/rossum/metaSNV2/metaSNV/"

#set -x

permLocation=$(pwd)
metaSnvWorkDir=$permLocation
mkdir -p $metaSnvWorkDir

allBAMs=${permLocation}/oneSamplePerSubject_bamPaths_paperReps_v2_plusGenomes.txt

set -x

outdir=${metaSnvWorkDir}/outputs_oneSamplePerSubject_paperSamples_v2_plusGenomes
cd $metaSnvWorkDir

genomesAnno="/g/scb2/bork/rossum/metaSNV2/metaSNV/db/freeze11.annotations.txt"
genomesFasta="/g/scb2/bork/rossum/cDiff/subspecies/humanOnly2020/mapping/fr11_genusClostridioides.fna"


pwd; hostname; 
date
${metasnvExeDir}/metaSNV.py --threads $threads --db_ann $genomesAnno $outdir $allBAMs $genomesFasta

date
${metasnvExeDir}/metaSNV_Filtering.py -m 20 --n_threads $threads $outdir

date
${metasnvExeDir}/metaSNV_DistDiv.py --filt $outdir/filtered/pop --dist --n_threads $threads

date
${metasnvExeDir}/metaSNV_DistDiv.py --filt $outdir/filtered/pop --div --divNS --n_threads $threads

date
echo "Results are in " $outdir

