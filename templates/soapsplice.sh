#!/bin/bash -e
#BSUB -J soapsplice_stats              # LSF job name
#BSUB -o soapsplice_stats.%J.out       # Name of the job output file
#BSUB -e soapsplice_stats.%J.error     # Name of the job error file

cd <%= @stats_path %>

grep -v "^@" <%= @tool_result_path %>/output.sam | sort -t'.' -k 2n > output.sam
ruby <%= @aligner_benchmark %>/fix_sam.rb <%= @nummer %> output.sam > fixed.sam
ruby <%= @aligner_benchmark %>/compare2truth.rb <%= @cig_file %> fixed.sam > comp_res.txt
#perl <%= @aligner_benchmark %>/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
#perl <%= @aligner_benchmark %>/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl <%= @transcripts %> <%= @junctions_crossed %> inferred_junctions.txt junctions > junctions_stats.txt
