
if(@ARGV<2) {
    die "
Usage: fix_sam.pl <sam file> <last seq num>

";
}

$samfile = $ARGV[0];
$samfile_idsfixed = $samfile . "_idsfixed";

open(INFILE, $samfile);
open(OUTFILE, ">$samfile_idsfixed");
while($line = <INFILE>) {
    chomp($line);
    if(!($line =~ /^@/)) {
	@a = split(/\t/,$line);
	
	$a[0] =~ s/\[.*\]//; # this fixes splicemap
	$a[0] =~ s/^\d+~//; # this and the next two fix mapsplice
	$a[0] =~ s!/1!a!;
	$a[0] =~ s!/2!b!;

	if($a[2] =~ /^\d+$/) {
	    $a[2] = "chr" . $a[2];
	}
	if($a[2] eq "X" || $a[2] eq "Y" || $a[2] eq "M") {
	    $a[2] = "chr" . $a[2];
	}

	if(!($a[0] =~ /a/) && !($a[0] =~ /b/)) {
	    if($a[1] & 2**6) {
		$a[0] = $a[0] . "a";
	    }
	    if($a[1] & 2**7) {
		$a[0] = $a[0] . "b";
	    }
	}
	print OUTFILE $a[0];
	for($i=1; $i<10; $i++) {
	    print OUTFILE "\t$a[$i]";
	}
	print OUTFILE "\t*";
	print OUTFILE "\n";
	if($line =~ /XA:Z/) {
	    print OUTFILE $a[0];
	    for($i=1; $i<10; $i++) {
		print OUTFILE "\t$a[$i]";
	    }
	    print OUTFILE "\t*";
	    print OUTFILE "\n";
	}
    }
}
close(INFILE);
close(OUTFILE);

$samfile_sorted = $samfile . "_sorted";
`perl sort_where_lines_start_seq.numa_or_seq.numb.pl $samfile_idsfixed $samfile_sorted`;
#`yes|rm $samfile_idsfixed`;

open(INFILE, $samfile_sorted);
$lastseqnum = $ARGV[1];

$flag = 0;
$line = <INFILE>;
chomp($line);
$acnt = 0;
$bcnt = 0;
$seqnum = 0;
while($flag == 0) {
    $line =~ /^seq.(\d+)(.)/;
    $seqnum_prev = $seqnum;
    $seqnum = $1;
    if($seqnum > $seqnum_prev + 1) {
	for($i=$seqnum_prev+1; $i<$seqnum; $i++) {
	    print "seq.$i";
	    print "a\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\n";
	    print "seq.$i";
	    print "b\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\n";
	}
    }

    $seqnuma = $seqnum . "a";
    $seqnumb = $seqnum . "b";
    $type = $2;
    if($type eq "a") {
	$a[$acnt] = $line;
	$acnt++;
    }
    if($type eq "b") {
	$b[$bcnt] = $line;
	$bcnt++;
    }
    $line = <INFILE>;
    chomp($line);
    while($line =~ /^seq.$seqnuma/ || $line =~ /^seq.$seqnumb/) {
	$line =~ /^seq.\d+(.)/;
	$type = $1;
	if($type eq "a") {
	    $a[$acnt] = $line;
	    $acnt++;
	}
	if($type eq "b") {
	    $b[$bcnt] = $line;
	    $bcnt++;
	}
	$line = <INFILE>;
	chomp($line);
    }
    if($acnt <= $bcnt) {
	for($i=0; $i<$acnt; $i++) {
	    $j=$i+1;
	    print "$a[$i]\tIH:i:$bcnt\tHI:i:$j\n$b[$i]\tIH:i:$bcnt\tHI:i:$j\n";
	}
	for($i=$acnt; $i<$bcnt; $i++) {
	    $j=$i+1;
	    print "seq.$seqnum";
	    print "a\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\tIH:i:$bcnt\tHI:i:$j\n";
	    print "$b[$i]\tIH:i:$bcnt\tHI:i:$j\n";
	}
    }
    if($acnt > $bcnt) {
	for($i=0; $i<$bcnt; $i++) {
	    $j=$i+1;
	    print "$a[$i]\tIH:i:$acnt\tHI:i:$j\n$b[$i]\tIH:i:$acnt\tHI:i:$j\n";
	}
	for($i=$bcnt; $i<$acnt; $i++) {
	    $j=$i+1;
	    print "$a[$i]\tIH:i:$acnt\tHI:i:$j\n";
	    print "seq.$seqnum";
	    print "b\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\tIH:i:$acnt\tHI:i:$j\n";
	}
    }
    undef @a;
    undef @b;
    $acnt = 0;
    $bcnt = 0;
    if($line eq '') {
	$flag = 1;
    }
}
#`yes|rm $samfile_sorted`;
if($seqnum < $lastseqnum) {
    for($i=$seqnum+1; $i<=$lastseqnum; $i++) {
	print "seq.$i";
	print "a\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\n";
	print "seq.$i";
	print "b\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t.\n";
    }
}
