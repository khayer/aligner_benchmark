# aligner_benchmark

## Master script

The master script runs both fix_sam.rb and compar2truth.rb for a given aligner.

### Usage
        Usage: ruby master.rb [options] run_name dataset source_of_tree

        e.g. run_name = t3r1-test4
        e.g. dataset = t3r1
        e.g. source_of_tree = /project/itmatlab/aligner_benchmark
        
            -a, --algorithm ENUM             Choose from below:
                                             all: DEFAULT
                                             clc
                                             contextmap2
                                             crac
                                             gsnap
                                             hisat
                                             hisat2
                                             mapsplice2
                                             novoalign
                                             olego
                                             rum
                                             star
                                             soapsplice
                                             subread
                                             tophat2
            -d, --debug                      Run in debug mode
            -t, --short                      Only first 1 Million reads
            -s, --species [String]           Spiecies, Default: human
            -v, --verbose                    Run verbosely


#### On a cluster environment
        bsub ruby master.rb -s malaria t3r3-test t3r3 /project/itmatlab/aligner_benchmark -v

#### On a specific algorithm
        bsub ruby master.rb -s malaria t3r3-test t3r3  /project/itmatlab/aligner_benchmark -v -a tophat2

## Read stats

After master.rb is complete, this code combines the stats of all the given comp_res.txt files.

### Usage

        find . -name comp_res.txt |sort | xargs ruby /path/to/read_stats.rb

## Anchors

### Anchor junction

        ruby anchor_junction.rb /project/itmatlab/aligner_benchmark/statistics/human_t1r1/tophat2/nocoveragesearch-bowtie2sensitive/fixed.sam t1r1 human
