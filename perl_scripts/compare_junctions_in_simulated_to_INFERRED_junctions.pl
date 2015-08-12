$| = 1;

if(@ARGV < 1) {
    die "
Usage: compare_junctions_in_simulated_to_INFERRED_alignment.pl <transcripts> <junctions found> <INFERRED> <junctions/introns>

If <INFERRED> are introns set the last argument to be \"introns\", else set it to be \"junctions\".

Junctions have the terminal coords of the exons, while introns have the terminal coords of the intron.

";
}

$junctions = "true";
if($ARGV[3] eq "introns") {
    $junctions = "false";
}

open(INFILE, $ARGV[0]);
while($line = <INFILE>) {
    chomp($line);
    if($line =~ /starts/) {
	$starts = $line;
	$starts =~ s/starts =\s*//;
	$line = <INFILE>;
	chomp($line);
	$ends = $line;
	$ends =~ s/ends =\s*//;
	$line = <INFILE>;
	$line = <INFILE>;
	chomp($line);
	$line =~ s/chr =\s*//;
	$chr = $line;
	@S = split(/,/,$starts);
	@E = split(/,/,$ends);
	for($i=0; $i<@S-1; $i++) {
	    $intron_start = $E[$i] + 1;
	    $intron_end = $S[$i+1];
	    $intron = $chr . ":" . $intron_start . "-" . $intron_end;
	    $TRUEINTRON{$intron}=1;
#	    print "$intron\n";
	}
    }
}
close(INFILE);

print STDERR "finished parsing $ARGV[0]\n";

open(INFILE, $ARGV[1]);
$line_prev = <INFILE>;
chomp($line_prev);
while($line = <INFILE>) {
    chomp($line);
    $line =~ /(.*):(\d+)-(\d+)/;
    $chr = $1;
    $start = $2;
    $end = $3;
    $chr =~ s/.*\t//;
    $start++;
    $end--;
    $intron = "$chr:$start-$end";
    $TRUEINTRONS_SPANNED{$intron}++;
}
close(INFILE);

print STDERR "finished parsing $ARGV[1]\n";

open(INFILE, $ARGV[2]);
while($line = <INFILE>) {
    chomp($line);
    $line =~ /^(.*):(\d+)-(\d+)/;
    $chr = $1;
    $start = $2;
    $end = $3;
    if($junctions eq "true") {
	$start++;
	$end--;
    }
    $intron = "$chr:$start-$end";
    @a = split(/\t/,$line);
    if($a[1] =~ /\S/) {
	$INFERREDINTRONS{$intron} = $INFERREDINTRONS{$intron} + $a[1];
    } else {
	$INFERREDINTRONS{$intron}++;
    }
#    print "$intron\n";
}
close(INFILE);

print STDERR "finished parsing $ARGV[2]\n";

# False Positive Rate Calculation Starts Here

open(OUTFILEX, ">falsepositives.txt");
foreach $intron (keys %INFERREDINTRONS) {
    $depth = $INFERREDINTRONS{$intron};
    $total[$depth]++;
    if(exists $TRUEINTRON{$intron}) {
	$num_true_positive[$depth]++;
    } else {
	$num_false_positive[$depth]++;
	print OUTFILEX "FP: $intron\t$depth\n";
    }
}
for($depth=99; $depth >= 1; $depth--) {
    $total[$depth] = $total[$depth] + $total[$depth+1];
    $num_true_positive[$depth] = $num_true_positive[$depth] + $num_true_positive[$depth+1];    
    $num_false_positive[$depth] = $num_false_positive[$depth] + $num_false_positive[$depth+1];    
}

for($depth=1; $depth <= 10; $depth++) {
    print "-------\ndepth = $depth\n";
    if($total[$depth] > 0) {
	$percent_true_positive = int($num_true_positive[$depth] / $total[$depth] * 10000) / 100;
	$percent_false_positive = int($num_false_positive[$depth] / $total[$depth] * 10000) / 100;

	print "total inferred = $total[$depth]\n";
	print "num_true_positive = $num_true_positive[$depth]\n";
	print "num_false_positive = $num_false_positive[$depth]\n";
	print "percent_false_positive = $percent_false_positive\n";
    }
}

# False Negative Rate Calculation Starts Here

undef @total;

foreach $intron (keys %TRUEINTRONS_SPANNED) {
    $depth = $TRUEINTRONS_SPANNED{$intron};
    $total[$depth]++;
    if(!(exists $INFERREDINTRONS{$intron})) {
	$false_negative[$depth]++;
    }
}
for($depth=99; $depth >= 1; $depth--) {
    $total[$depth] = $total[$depth] + $total[$depth+1];
    $false_negative[$depth] = $false_negative[$depth] + $false_negative[$depth+1];    
}

for($depth=1; $depth <= 10; $depth++) {
    print "-------\ndepth = $depth\n";
    if($total[$depth] > 0) {
	$percent_false_negative = int($false_negative[$depth] / $total[$depth] * 10000) / 100;

	print "total spanned = $total[$depth]\n";
	print "false_negative = $false_negative[$depth]\n";
	print "percent_false_negative = $percent_false_negative\n";
    }
}
