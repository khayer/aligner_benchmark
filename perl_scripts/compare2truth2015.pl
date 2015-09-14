#!/bin/perl
$|=1;
if(@ARGV < 2) {
    die "
Usage: perl compare2truth.pl <truth file> <sam file> [options]

The <truth file> is the .cig file output from reads_simulator.pl

The <sam file> is the alignments of the same reads output from
               an alignment algoirthm.

Options:
    -rum     : if comparing to a rum output file

    -uniqueRecords : There is only one record for each sequence.

    -noHtag  :  There aren't HI and IH tag indicating the number of alignments.
                In this case I will figure out the number the hard way...

This script computes the per-base false alignment rates.

If -rum is not true and (1) there is no HI or IH tags and
(2) there are multiple records per read and (3) there are ids
with no records, then this probably won't work...

";
}

$noHtag = "false";
$rum = "false";
$unique_records = "false";
for($i=2; $i<@ARGV; $i++) {
    $optionrecognized = 0;
    if($ARGV[$i] eq "-noHtag") {
	$noHtag = "true";
	$optionrecognized = 1;
    }
    if($ARGV[$i] eq "-uniqueRecords") {
	$unique_records = "true";
	$optionrecognized = 1;
    }
    if($ARGV[$i] eq "-rum") {
	$rum = "true";
	$optionrecognized = 1;
    }
    if($optionrecognized == 0) {
	die "\nERROR: option '$ARGV[$i]' not recognized\n";
    }
}

if($noHtag eq "true") {
    print STDERR "no H tag so computing the numbers of occurrences of each read...\n";
    open(INFILE, $ARGV[1]) or die "\nError: Cannot open '$ARGV[1]' for reading\n\n";
    while($line = <INFILE>) {
	$line =~ /^seq.(\d+.)/;
	$number_occurrences{$1}++;
    }
    print STDERR "done with that...\n";
}
close(INFILE);

open(INFILE1, $ARGV[0]);
$line = <INFILE1>;
$cnt = 0;
until($line =~ /^seq.\d+/) {
    $cnt++;
    $line = <INFILE1>;
}
close(INFILE1);

open(INFILE1, $ARGV[0]);
for($i=0; $i<$cnt; $i++) {
    $line = <INFILE1>;
}

open(INFILE2, $ARGV[1]);
$line = <INFILE2>;
$cnt = 0;
until($line =~ /^seq.\d+/) {
    $cnt++;
    $line = <INFILE2>;
}

close(INFILE2);
open(INFILE2, $ARGV[1]);
for($i=0; $i<$cnt; $i++) {
    $line = <INFILE2>;
}

$head = `grep ^seq $ARGV[0] | head -1`;
chomp($head);
$head =~ /seq.(\d+)/;
$first_seq_num = $1;

$head =~ /\t([^\t]+)$/;
$readlength = length($1);
#print "readlength = $readlength\n";

$tail = `tail -1 $ARGV[0]`;
$tail =~ /seq.(\d+)/;
$last_seq_num = $1;

$head = `grep ^seq $ARGV[1] | head -1`;
$head =~ /seq.(\d+)/;
if($first_seq_num ne $1) {
    die "
Error: both files must start and end with the same sequence number
and must have an entry for every sequence number in between.

";
}

$tail = `tail -1 $ARGV[1]`;
$tail =~ /seq.(\d+)/;

if($last_seq_num ne $1) {
    die "
Error: both files must start and end with the same sequence number
and must have an entry for every sequence number in between.

";
}

$linenum = 0;
$total_number_of_bases_of_reads = 0;
$total_number_of_bases_aligned_correctly = 0;
$total_number_of_bases_aligned_incorrectly = 0;
$total_number_of_bases_aligned_ambiguously = 0;
$total_number_of_bases_unaligned = 0;
$total_number_of_bases_in_true_insertions = 0;
$total_number_of_bases_called_insertions = 0;
$insertions_called_correctly = 0;

$flag = 0;
$cnt = 0;
for($seqnum=$first_seq_num; $seqnum<=$last_seq_num; $seqnum++) {
    $cnt++;
    if($cnt % 50000 == 0) {
	print STDERR "finished $cnt reads\n";
    }
    $truth = <INFILE1>;
#    print "--------------\ntruth=$truth";
    chomp($truth);

    @a = split(/\t/, $truth);
    $truth_cigar = $a[4];
    $cigar_string_temp = $truth_cigar;
    while($cigar_string_temp =~ /^(\d+)([^\d])/) {
	$num = $1;
	$type = $2;
	if($type eq 'I') {
	    for($i=0; $i<$num; $i++) {
		$truelocation[$pos_on_read] = "i";
		$pos_on_read++;
		$total_number_of_bases_in_true_insertions++;
	    }
	}
	$cigar_string_temp =~ s/^\d+[^\d]//;
    }

    $total_number_of_bases_of_reads = $total_number_of_bases_of_reads + $readlength;
    $linenum++;
    $sam = <INFILE2>;
#    print "sam=$sam";
    chomp($sam);
    if($rum eq 'true') {
	if($sam =~ /IH:i:(\d+)/ || $sam =~ /NH:i:(\d+)/) {
	    $num_alignments = $1;
	    if($num_alignments > 1) {
		$total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously + $readlength * 2;
		for($i=0; $i<$num_alignments*2-1; $i++) {
		    $sam = <INFILE2>;
		}
		$truth = <INFILE1>;
		@a = split(/\t/, $truth);
		$truth_cigar = $a[4];
		$cigar_string_temp = $truth_cigar;
		while($cigar_string_temp =~ /^(\d+)([^\d])/) {
		    $num = $1;
		    $type = $2;
		    if($type eq 'I') {
			for($i=0; $i<$num; $i++) {
			    $total_number_of_bases_in_true_insertions++;
			}
		    }
		    $cigar_string_temp =~ s/^\d+[^\d]//;
		}

		$total_number_of_bases_of_reads = $total_number_of_bases_of_reads + $readlength;
		$linenum++;
		next;
	    }
	} else { # this means the entire read did not align
	    $total_number_of_bases_unaligned = $total_number_of_bases_unaligned + $readlength;
	    if($flag == 0) {
		$seqnum--;
		$flag = 1;
	    } else {
		$flag = 0;
	    }
	    next;
	}
    } else {
	if($noHtag eq "true" && $unique_records eq "false") {
	    @a = split(/\t/, $sam);
	    $a[0] =~ /seq.(\d+.)/;
	    $idx = $1;
	    $XX = $number_occurrences{$idx};
	    if($number_occurrences{$idx} > 1) {
		$total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously + $readlength * 2;
		for($i=0; $i<$number_occurrences{$idx}*2-1; $i++) {
		    $sam = <INFILE2>;
		}
            }
	    if($number_occurrences{$idx} != 1) {
		$truth = <INFILE1>;
		@a = split(/\t/, $truth);
		$truth_cigar = $a[4];
		$cigar_string_temp = $truth_cigar;
		while($cigar_string_temp =~ /^(\d+)([^\d])/) {
		    $num = $1;
		    $type = $2;
		    if($type eq 'I') {
			for($i=0; $i<$num; $i++) {
			    $total_number_of_bases_in_true_insertions++;
			}
		    }
		    $cigar_string_temp =~ s/^\d+[^\d]//;
		}

		$total_number_of_bases_of_reads = $total_number_of_bases_of_reads + $readlength;
		$linenum++;
		next;
	    }
	}
	if($unique_records eq "true") {
            if($sam =~ /X0:i:(\d+)/) {
                $num_alignments = $1;
                if($num_alignments > 1) {
		    $total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously + $readlength * 2;
                }
	        if($num_alignments != 1) {
		    $truth = <INFILE1>;
		    @a = split(/\t/, $truth);
		    $truth_cigar = $a[4];
    		    $cigar_string_temp = $truth_cigar;
		    while($cigar_string_temp =~ /^(\d+)([^\d])/) {
		       $num = $1;
		        $type = $2;
		        if($type eq 'I') {
			    for($i=0; $i<$num; $i++) {
			        $total_number_of_bases_in_true_insertions++;
			    }
		        }
		        $cigar_string_temp =~ s/^\d+[^\d]//;
		    }

		    $total_number_of_bases_of_reads = $total_number_of_bases_of_reads + $readlength;
		    $linenum++;
		    $sam = <INFILE2>;
		    next;
                }
            } else {
    	        $num_alignments = 1;
            }
	}
    }
    $truth =~ /seq.(\d+.)/;
    $sn1 = $1;
    $sam =~ /seq.(\d+.)/;
    $sn2 = $1;
    $sn = $sn1;
    $sn =~ s/.$//;
    if($sn1 ne $sn2 || $sn != $seqnum) {
	die "\tError: Check line $linenum.  It doesn't refer to the same sequence in both files\n\ntruth: $truth\nSAM: $sam\n\n";
    }
    @a = split(/\t/, $truth);
    $truth_chr = $a[1];
    $truth_start = $a[2];
    $truth_cigar = $a[4];
    @a = split(/\t/, $sam);
    $sam_chr = $a[2];
    $sam_chr =~ s/:[^:]*$//;
    $sam_start = $a[3];
    $sam_cigar = $a[5];

#    print "truth_chr = $truth_chr\n";
#    print "sam_chr = $sam_chr\n";

    if($sam_cigar eq "*") {
	# this means the entire read did not align
	$total_number_of_bases_unaligned = $total_number_of_bases_unaligned + $readlength;
	if($flag == 0) {
	    $seqnum--;
	    $flag = 1;
	} else {
	    $flag = 0;
	}
	next;
    }

    $cigar_string_temp = $sam_cigar;
    $number_bases_of_this_read_aligned = 0;
    while($cigar_string_temp =~ /^(\d+)([^\d])/) {
	$num = $1;
	$type = $2;
	if($type eq 'S' || $type eq 'H') {
	    $total_number_of_bases_unaligned = $total_number_of_bases_unaligned + $num;
	}
	if($type eq 'M' || $type eq 'I') {
	    $number_bases_of_this_read_aligned = $number_bases_of_this_read_aligned + $num;
	}
	$cigar_string_temp =~ s/^\d+[^\d]//;
    }

    if($truth_chr ne $sam_chr) {
	$total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly + $number_bases_of_this_read_aligned;
    } else {
	$pos_on_genome = $sam_start;
	$pos_on_read = 0;
	$cigar_string_temp = $sam_cigar;
	undef @location;
	undef @truelocation;
        $total_called_insertion_this_read = 0;
	while($cigar_string_temp =~ /^(\d+)([^\d])/) {
	    $num = $1;
	    $type = $2;
	    if($type eq 'S' || $type eq 'H') {
		for($i=0; $i<$num; $i++) {
		    $location[$pos_on_read] = "x";
		    $pos_on_read++;
		}
	    }
	    if($type eq 'M') {
		for($i=0; $i<$num; $i++) {
		    $location[$pos_on_read] = $pos_on_genome;
		    $pos_on_read++;
		    $pos_on_genome++;
		}
	    }
	    if($type eq 'I') {
		for($i=0; $i<$num; $i++) {
		    $location[$pos_on_read] = "i";
		    $pos_on_read++;
		    $total_number_of_bases_called_insertions++;
                    $total_called_insertion_this_read++;
		}
	    }
	    $cigar_string_temp =~ s/^\d+[^\d]//;
	}
	$pos_on_genome = $truth_start;
	$pos_on_read = 0;
	$cigar_string_temp = $truth_cigar;
	while($cigar_string_temp =~ /^(\d+)([^\d])/) {
	    $num = $1;
	    $type = $2;
	    if($type eq 'M') {
		for($i=0; $i<$num; $i++) {
		    $truelocation[$pos_on_read] = $pos_on_genome;
		    $pos_on_read++;
		    $pos_on_genome++;
		}
	    }
	    if($type eq 'I') {
		for($i=0; $i<$num; $i++) {
		    $truelocation[$pos_on_read] = "i";
		    $pos_on_read++;
		}
	    }
	    $cigar_string_temp =~ s/^\d+[^\d]//;
	}
        $insertion_flag = 0;
        $cnt_equal = 0;
	for($pos_on_read=0; $pos_on_read<@truelocation; $pos_on_read++) {
	    if($truelocation[$pos_on_read] eq $location[$pos_on_read]) {
		if($truelocation[$pos_on_read] ne "i") {
                    $cnt_equal++;
                }
		$total_number_of_bases_aligned_correctly++;
		if($truelocation[$pos_on_read] eq "i") {
		    $insertions_called_correctly++;
		}
	    } else {
		if($truelocation[$pos_on_read] eq "i") {
                   $insertion_flag = 1;
                }
		if($location[$pos_on_read] ne "x") {
		    $total_number_of_bases_aligned_incorrectly++;
		}
	    }
	}
        if($insertion_flag == 1) {
             # fix insertion issue here
             undef @truelocation_temp;
             $j=0;
             for($i=0; $i<@truelocation; $i++) {
                 if($truelocation[$i] ne 'i') {
                     $truelocation_temp[$j] = $truelocation[$i];
                     $j++;
                 }
             }
             undef @location_temp;
             $j=0;
             for($i=0; $i<@location; $i++) {
                 if($location[$i] ne 'i') {
                     $location_temp[$j] = $location[$i];
                     $j++;
                 }
             }
             $cnt_equal2 = 0;
             for($i=0; $i<@truelocation_temp; $i++) {
                  if($truelocation_temp[$i] eq $location_temp[$i]) {
                      $cnt_equal2++;
                  }
             }
             $diff = $cnt_equal2 - $cnt_equal;
             if($diff > $total_called_insertion_this_read) {
                  $diff = $total_called_insertion_this_read;
             }
             if($diff > 0) {
                 $insertions_called_correctly = $insertions_called_correctly + $diff;
 		 $total_number_of_bases_aligned_correctly = $total_number_of_bases_aligned_correctly + $diff*2;
		 $total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly - $diff*2;
             }
        }
    }
    if($flag == 0) {
	$seqnum--;
	$flag = 1;
    } else {
	$flag = 0;
    }
}

print "total_number_of_bases_of_reads = $total_number_of_bases_of_reads\n";

$percent_bases_aligned_correctly = int($total_number_of_bases_aligned_correctly / $total_number_of_bases_of_reads * 10000) / 100;;
#print "total_number_of_bases_aligned_correctly = $total_number_of_bases_aligned_correctly\n";
#print "% bases aligned correctly: $percent_bases_aligned_correctly%\n";
print "accuracy over all bases: $percent_bases_aligned_correctly%\n";

$total_num_unique_aligners = $total_number_of_bases_aligned_correctly + $total_number_of_bases_aligned_incorrectly;
#print "total_num_unique_aligners=$total_num_unique_aligners\n";
$accuracy_on_unique_aligners = int($total_number_of_bases_aligned_correctly / $total_num_unique_aligners * 10000) / 100;
#print "% unique aligners correct: $accuracy_on_unique_aligners%\n";
print "accuracy over uniquely aligned bases: $accuracy_on_unique_aligners%\n";

$percent_bases_aligned_incorrectly = int($total_number_of_bases_aligned_incorrectly / $total_number_of_bases_of_reads * 10000) / 100;;
#print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
print "% bases aligned incorrectly: $percent_bases_aligned_incorrectly%\n";

$percent_bases_aligned_ambiguously = int($total_number_of_bases_aligned_ambiguously / $total_number_of_bases_of_reads * 10000) / 100;
#print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
print "% bases aligned ambiguously: $percent_bases_aligned_ambiguously%\n";

$percent_bases_unaligned = int($total_number_of_bases_unaligned / $total_number_of_bases_of_reads * 10000) / 100;
#print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
print "% bases unaligned: $percent_bases_unaligned%\n";

$percent_bases_aligned = 100 - $percent_bases_unaligned;
print "% bases aligned: $percent_bases_aligned%\n";

#print "number of bases in true insertions = $total_number_of_bases_in_true_insertions\n";
$insertion_rate = int($total_number_of_bases_in_true_insertions / $total_number_of_bases_of_reads * 1000000) / 10000;
print "% of bases in true insertions: $insertion_rate%\n";

if($total_number_of_bases_in_true_insertions==0) {
    print "insertions FP/FN rate: No insertions exist in true data.\n";
} else {
    if($total_number_of_bases_called_insertions>0) {
      # I think this the false_negative_rate
      print STDERR "insertions_called_correctly $insertions_called_correctly \n";
	    print STDERR "total_number_of_bases_called_insertions $total_number_of_bases_called_insertions \n";
  $insertions_false_positive_rate = int((100 - int($insertions_called_correctly / $total_number_of_bases_called_insertions * 10000) / 100)*100)/100 ;
	print "insertions FP rate: $insertions_false_positive_rate%\n";
    } else {
	print "insertions FP rate: 0% (no insertions called)\n";
    } # I think this is false_discovery_rate
    print STDERR "total_number_of_bases_in_true_insertions $total_number_of_bases_in_true_insertions \n";
    # https://en.wikipedia.org/wiki/Sensitivity_and_specificity
    $insertions_false_negative_rate = (100 - int($insertions_called_correctly / $total_number_of_bases_in_true_insertions * 10000) / 100) ;
    print "insertions FN rate: $insertions_false_negative_rate%\n";
}
