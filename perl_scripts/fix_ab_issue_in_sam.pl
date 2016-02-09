open(INFILE, $ARGV[0]);
while($line = <INFILE>) {
    if($line =~ /^@/) {
        next;
    }
    chomp($line);
    @a = split(/\t/,$line);
    $a[0] =~ /seq.(\d+)/;
    $n = $1;
    $na = "seq." . $n . "a";
    $nb = "seq." . $n . "b";
    if($a[1] & 2**7) {
	print "$nb";
	for($i=1; $i<@a; $i++) {
	    print "\t$a[$i]";
	}
	print "\n";
    } else {
	print "$na";
	for($i=1; $i<@a; $i++) {
	    print "\t$a[$i]";
	}
	print "\n";
    }
}
close(INFILE);
