#!/bin/bash
#BSUB -J tophat2_stats              # LSF job name
#BSUB -o tophat2_stats.%J.out       # Name of the job output file
#BSUB -e tophat2_stats.%J.error     # Name of the job error file
#BSUB -M 18432

cd /Users/hayer/github/aligner_benchmark/example_source_tree//statistics/human_t3r1/tophat2/coveragesearch

samtools merge merged.bam /Users/hayer/github/aligner_benchmark/example_source_tree//tool_results/tophat2/alignment/dataset_human_hg19_RefSeq_t3r1/coveragesearch/accepted_hits.bam //Users/hayer/github/aligner_benchmark/example_source_tree//tool_results/tophat2/alignment/dataset_human_hg19_RefSeq_t3r1/coveragesearch/unmapped.bam
samtools view merged.bam | sort -t'.' -k 2n > output.sam
ruby /Users/hayer/github/aligner_benchmark/fix_sam.rb output.sam > fixed.sam
perl /Users/hayer/github/aligner_benchmark/perl_scripts/compare2truth.pl /project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/simulated_reads_HG19t3r1.cig fixed.sam -noHtag > comp_res.txt
perl /Users/hayer/github/aligner_benchmark/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
perl /Users/hayer/github/aligner_benchmark/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl /project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/simulated_reads_transcripts_HG19t3r1.txt /project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/simulated_reads_junctions-crossed_HG19t3r1.txt inferred_junctions.txt junctions > junctions_stats.txt
