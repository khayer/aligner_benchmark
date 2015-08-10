#!/bin/bash
#BSUB -J tophat2_stats              # LSF job name
#BSUB -o tophat2_stats.%J.out       # Name of the job output file
#BSUB -e tophat2_stats.%J.error     # Name of the job error file

cd <%= @path %>
