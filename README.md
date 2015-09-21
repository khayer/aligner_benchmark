# aligner_benchmark

## Usage
        Usage: ruby master.rb [options] run_name dataset source_of_tree

        e.g. run_name = t3r1-test4
        e.g. dataset = t3r1
        e.g. source_of_tree = /project/itmatlab/aligner_benchmark

            -a, --algorithm ENUM             Choose from below:
                                             all: DEFAULT
                                             contextmap2
                                             crac
                                             gsnap
                                             hisat
                                             mapsplice2
                                             olego
                                             rum
                                             star
                                             soap
                                             soapsplice
                                             subread
                                             tophat2
            -d, --debug                      Run in debug mode
            -s, --species [String]           Spiecies, Default: human
            -v, --verbose                    Run verbosely

### On a cluster environment
        bsub ruby master.rb -s malaria t3r3-test t3r3 /project/itmatlab/aligner_benchmark -v

### On a specific algorithm
        bsub ruby master.rb -s malaria t3r3-test t3r3  /project/itmatlab/aligner_benchmark -v -a tophat2

### Read stats:
        find . -name comp_res.txt |sort | xargs ruby ~/aligner_benchmark/scripts/aligner_benchmark/read_stats.rb
        find . -name junctions_stats.txt | sort |  xargs ruby ~/aligner_benchmark/scripts/aligner_benchmark/read_junctions_stats.rb

###

## ToDo

* Write unit tests!!!
* Count introns in binary (TP,FN,TP)
    * Count partially correct introns (either left or right is correct)


