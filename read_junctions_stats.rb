###
#
# IN:
# [hayer@consign aligner_benchmark]$ ls */junctions_stats.txt
#     gsnap/junctions_stats.txt  hisat/junctions_stats.txt  mapsplice2/junctions_stats.txt
# OUT: Summary
#
###
all = []
ARGV[0..-1].each do |arg|
  info = []
  info << arg.gsub(/([\.\/]|junctions_stats.txt$)/,"")
  first = true
  File.open(arg).each do |line|
    if first
      first = false
      next
    end
    line.chomp!
    fields = line.split(" ")
    info << fields[-1]
  end
  all << info
end

#puts "aligner\ttotal_number_of_bases_of_reads\taccuracy over all bases\taccuracy over uniquely aligned bases"

File.open(ARGV[0]).each_with_index do |line,j|
  line.chomp!
  fields = line.split(" = ")
  case j
  when 0
    print "Aligner\t"
  else
    print "#{fields[0]}\t"
  end
  res = []
  for i in 0...ARGV.length
    res << all[i][j]
  end
  print res.join("\t")
  print "\n"
end
