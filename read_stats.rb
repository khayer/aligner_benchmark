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
  info << arg.split("/")[0]
  File.open(arg).each do |line|
    line.chomp!
    fields = line.split("\t")
    info << fields[-1]
  end
  all << info
end

#puts "aligner\ttotal_number_of_bases_of_reads\taccuracy over all bases\taccuracy over uniquely aligned bases"

for j in 0..10
  case j
  when 0
    print "Aligner\t"
  when 1
    print "total_number_of_bases_of_reads\t"
  when 2
    print "accuracy over all bases\t"
  when 3
    print "accuracy over uniquely aligned bases\t"
  when 4
    print "% bases aligned incorrectly\t"
  when 5
    print "% bases aligned ambiguously\t"
  when 6
    print "% bases unaligned\t"
  when 7
    print "% bases aligned\t"
  when 8
    print "% of bases in true insertions\t"
  when 9
    print "insertions FP rate\t"
  when 10
    print "insertions FN rate\t"
  end
  res = []
  for i in 0...ARGV.length
    res << all[i][j]
  end 
  print res.join("\t")
  print "\n"
end
