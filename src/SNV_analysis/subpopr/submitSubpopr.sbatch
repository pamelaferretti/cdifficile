#!/usr/bin/bash

# SBATCH --dependency=afterok:360255

#SBATCH --job-name=sbpp_cdiffGlobal_newgSnvs2_pReps
#SBATCH -o sbpp_cdiffGlobal_newgSnvs2_pReps."%j".out
#SBATCH -e sbpp_cdiffGlobal_newgSnvs2_pReps."%j".err 
#
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6 # 3 & 20gb for corr
#SBATCH --time=72:00:00
#SBATCH --mem-per-cpu=12gb  #6gb  #6gb for 12 ; 3gb for 24 cores

NPROCS=6

source /etc/profile.d/modules.sh
source /g/bork3/home/rossum/.bash_profile

module unload R

source activate R360

set -x

Rpath=/g/bork3/home/rossum/software/miniconda/envs/R360/bin/R

PROJDIR=/g/scb2/bork/rossum/cDiff/subspecies/globalData2021/
METASNVDIR=${PROJDIR}/metaSNV/outputs_oneSamplePerSubject_paperSamples_v2
OUTDIR=results_${SLURM_JOBID}_oneSamplePerSubject_paperSamples_v2

MAX_PROP_READS_NON_HOMOG=0.1 # fixReadThreshold 
MIN_PROP_SNV_HOMOG=0.8 #fixSnvThreshold 
SNV_SUBSPEC_UNIQ_CUTOFF=0.8 # 0.8 genotypingThreshold 

SAMPLE_SUFFIX=".cdiffGenus.unique.sorted.bam"

SRCDIR=/g/bork3/home/rossum/software/metaSNV2/metaSNV
SRCDIR=/g/scb2/bork/rossum/metaSNV2/metaSNV/

${Rpath}script $SRCDIR/metaSNV_subpopr.R -i $METASNVDIR -o $OUTDIR -p $NPROCS -m TRUE -r TRUE -x $MAX_PROP_READS_NON_HOMOG -y $MIN_PROP_SNV_HOMOG -z $SNV_SUBSPEC_UNIQ_CUTOFF -s $SAMPLE_SUFFIX #-a $
