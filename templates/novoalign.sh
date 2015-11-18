#!/bin/bash -e
#BSUB -J novoalign_stats<%= @run_name %>              # LSF job name
#BSUB -o novoalign_stats<%= @run_name %>.%J.out       # Name of the job output file
#BSUB -e novoalign_stats<%= @run_name %>.%J.error     # Name of the job error file

cd <%= @stats_path %>

zcat <%= @tool_result_path %>/output.sam.gz > output.sam
ruby <%= @aligner_benchmark %>/fix_sam.rb <%= @nummer %> output.sam > fixed.sam
ruby <%= @aligner_benchmark %>/compare2truth.rb <%= @cig_file %> fixed.sam > comp_res.txt
#perl <%= @aligner_benchmark %>/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
#perl <%= @aligner_benchmark %>/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl <%= @transcripts %> <%= @junctions_crossed %> inferred_junctions.txt junctions > junctions_stats.txt
