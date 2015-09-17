#!/bin/bash -e
#BSUB -J tophat2_stats              # LSF job name
#BSUB -o tophat2_stats.%J.out       # Name of the job output file
#BSUB -e tophat2_stats.%J.error     # Name of the job error file
#BSUB -M 18432

cd <%= @stats_path %>

<%= @samtools %> merge merged.bam <%= @tool_result_path %>/accepted_hits.bam /<%= @tool_result_path %>/unmapped.bam
<%= @samtools %> view merged.bam | sort -t'.' -k 2n > output.sam
ruby <%= @aligner_benchmark %>/fix_sam.rb output.sam > fixed.sam
ruby <%= @aligner_benchmark %>/compare2truth.rb <%= @cig_file %> fixed.sam -noHtag > comp_res.txt
perl <%= @aligner_benchmark %>/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
perl <%= @aligner_benchmark %>/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl <%= @transcripts %> <%= @junctions_crossed %> inferred_junctions.txt junctions > junctions_stats.txt
