#!/bin/bash -e
#BSUB -J star_stats              # LSF job name
#BSUB -o star_stats.%J.out       # Name of the job output file
#BSUB -e star_stats.%J.error     # Name of the job error file
#BSUB -M 18432

cd <%= @stats_path %>

grep -v "^@" <%= @tool_result_path %>/*Aligned.out.sam | sort -t'.' -k 2n > output.sam
ruby <%= @aligner_benchmark %>/fix_sam.rb output.sam > fixed.sam
perl <%= @aligner_benchmark %>/perl_scripts/compare2truth.pl <%= @cig_file %> fixed.sam -noHtag > comp_res.txt
perl <%= @aligner_benchmark %>/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
perl <%= @aligner_benchmark %>/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl <%= @transcripts %> <%= @junctions_crossed %> inferred_junctions.txt junctions > junctions_stats.txt
