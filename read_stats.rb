###
#
# IN:
# [hayer@consign aligner_benchmark]$ ls */comp_res.txt
#     gsnap/comp_res.txt  hisat/comp_res.txt  mapsplice2/comp_res.txt
# OUT: Summary
#
###
all = []
ARGV[0..-1].each do |arg|
  info = []
  info << arg.gsub(/([\.\/]|comp_res.txt$)/,"")
  File.open(arg).each do |line|
    line.chomp!
    next if line =~ /^------/
    if line =~ /exist in true data/
      info << "NA"
      info << "NA"
      next
    end
    fields = line.split(" ")
    info << fields[-1]
  end
  all << info
end

#puts "aligner\ttotal_number_of_bases_of_reads\taccuracy over all bases\taccuracy over uniquely aligned bases"

for j in 0..22
  case j
  when 0
    print "Aligner\t"
  when 1
    print "total_number_of_reads\t"
  when 2
    print "accuracy over all reads\t"
  when 3
    print "accuracy over uniquely aligned reads\t"
  when 4
    print "% reads aligned incorrectly\t"
  when 5
    print "% reads aligned ambiguously\t"
  when 6
    print "% reads unaligned\t"
  when 7
    print "% reads aligned\t"
  when 8
   print "total_number_of_bases_of_reads\t"
  when 9
    print "accuracy over all bases\t"
  when 10
    print "accuracy over uniquely aligned bases\t"
  when 11
    print "% bases aligned incorrectly\t"
  when 12
    print "% bases aligned ambiguously\t"
  when 13
    print "% bases unaligned\t"
  when 14
    print "% bases aligned\t"
  when 15
    print "% of bases in true insertions\t"
  when 16
    print "% of bases in true deletion\t"
  when 17
    print "insertions FD rate\t"
  when 18
    print "insertions FN rate\t"
  when 19
    print "deletions FD rate\t"
  when 20
    print "deletions FN rate\t"
  when 21
    print "junctions FD rate\t"
  when 22
    print "junctions FN rate\t"
  end
  res = []
  for i in 0...ARGV.length
    res << all[i][j]
  end
  print res.join("\t")
  print "\n"
  case j
  when 0
    puts "---------------- READ LEVEL ---------------------"
end
