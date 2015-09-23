###
#
# IN:
# [hayer@consign aligner_benchmark]$ ls */comp_res.txt
#     gsnap/comp_res.txt  hisat/comp_res.txt  mapsplice2/comp_res.txt
# OUT: Summary
#
###
all = []
names = ["Aligner"]
count = 0
borders = []
first = true
ARGV[0..-1].each do |arg|
  info = []
  info << arg.gsub(/([\.\/]|comp_res.txt$)/,"")
  File.open(arg).each do |line|
    line.chomp!
    if line =~ /^------/
      borders << count
      next
    end
    count += 1
    fields = line.split("\t")
    if line =~ /exist in true data/
      info << "NA"
      info << "NA"
      names << fields[0] if first
      names << fields[0].gsub(/FD/, "FN") if first
      count += 1
      next
    end
    if line =~ /^Junctions\ Sides/
      names << fields[0].split(/[\(\)]/)[1].split("|").map { |e| e = "Junction Sides #{e}" } if first
      info << fields[-1].split("|")
      count += 4
      next
    end
    info << fields[-1]
    names << fields[0] if first
  end
  first = false
  all << info.flatten
end

names.flatten!
#info.flatten!

#puts "aligner\ttotal_number_of_bases_of_reads\taccuracy over all bases\taccuracy over uniquely aligned bases"

names.each_with_index do |name, j|
  print "#{name}\t"

  res = []
  for i in 0...ARGV.length
    res << all[i][j]
  end
  print res.join("\t")
  print "\n"
  case j
  when borders[0]
    puts "---------------- READ LEVEL ---------------------"
  when borders[1]
    puts "---------------- BASE LEVEL ---------------------"
  when borders[2]
    puts "---------------- EXPLORATORY ---------------------"
  end
end
