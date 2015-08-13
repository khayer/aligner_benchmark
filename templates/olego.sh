#!/bin/bash -e
#BSUB -J olego_stats              # LSF job name
#BSUB -o olego_stats.%J.out       # Name of the job output file
#BSUB -e olego_stats.%J.error     # Name of the job error file
#BSUB -M 18432

cd <%= @stats_path %>

ln -s <%= @tool_result_path %>/output.sam output.sam
ln -s output.sam fixed.sam
perl <%= @aligner_benchmark %>/perl_scripts/compare2truth.pl <%= @cig_file %> fixed.sam -noHtag > comp_res.txt
perl <%= @aligner_benchmark %>/perl_scripts/sam2junctions.pl fixed.sam > inferred_junctions.txt
perl <%= @aligner_benchmark %>/perl_scripts/compare_junctions_in_simulated_to_INFERRED_junctions.pl <%= @transcripts %> <%= @junctions_crossed %> inferred_junctions.txt junctions > junctions_stats.txt
