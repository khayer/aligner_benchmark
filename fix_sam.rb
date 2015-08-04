#####
#
# Expects sam sorted by read name!
# out: Fixed sam that is valid for compare2truth.pl
# 1) Readnames end in a for fwd and b for rev
# 2) Fwd read comes before rev
# 3) Add missing reads (TODO)
# 4) NH and IH tag signalising multi-mappers
#
####

def get_name(field_0)
  field_0 =~ /(\d+)/
  name = "seq.#{$1}"
end

def add_empty_lines(current_name)
  puts "seq.#{current_name}a\t77\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t."
  puts "seq.#{current_name}b\t141\t*\t0\t255\t*\t*\t0\t0\tNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\t."
end

def fix_ab(fields,current_name)
  #STDERR.puts fields
  #STDERR.puts (fields[1].to_i & 2**7).to_s(2)
  if (fields[1].to_i & 2**7).to_s(2)[-8] == "1"
    fields[0] = "#{current_name}b"
  else
    fields[0] = "#{current_name}a"
  end
  fields
end

def check_hi_tag(fields)
  ih = -1
  return fields << ih unless fields[11]
  fields[11..-1].each do |tag|
    if tag =~ /^HI:/
      tag =~ /(\d+)/
      ih = $1.to_i
    end
  end
  fields << ih
end

def rep_line(lines1, lines2)
  new_line1 = []
  #STDERR.puts lines1
  #STDERR.puts lines2
  lines2.each do |l2|
    if lines1.length >= 1
      k = lines1[0]
    else
      k = lines2[0]
      if (k[1].to_i & 2**7).to_s(2)[-8] == "1"
        k[1] = 69
      else
        k[1] = 133
      end
      k[2] = "*"
      k[3] = 0
      k[4] = 255
      k[5] = "*"
    end
    #STDERR.puts lines1[0]
    k[6] = l2[2]
    k[7] = l2[3]
    new_line1 << k.dup
  end
  new_line1
end

def fix_lines(lines,current_name)
  #number_of_hits = lines.length/2+1
  #STDERR.puts number_of_hits
  i = 0
  # e[-1] information from IH tag if it exists
  #STDERR.puts lines.join(":")
  #lines.sort_by! {|e| [e[-1], e[2], e[3].to_i]}
  #STDERR.puts lines.join(":")
  fwd_reads = []
  rev_reads = []
  fwd_count = 1
  rev_count = 1
  STDERR.puts lines.join("NINERRRR")
  lines.each do |line|
    l = fix_ab(line,current_name)
    #second = fix_ab(lines[i*2+1],current_name)
    if l[0] =~ /a$/
      if l[-1] == -1
        l[-1] = fwd_count
        l.insert(-2,"HI:i:#{fwd_count}")
        fwd_count += 1
      end
      fwd_reads << l
    else
      if l[-1] == -1
        l[-1] = rev_count
        l.insert(-2,"HI:i:#{rev_count}")
        rev_count += 1
      end
      rev_reads << l
    end
    i = i+1
  end
  fwd_reads.sort_by! {|e| [e[-1], e[2], e[3].to_i]}
  rev_reads.sort_by! {|e| [e[-1], e[2], e[3].to_i]}
  STDERR.puts rev_reads.length
  STDERR.puts fwd_reads.length
  STDIN.gets
  if rev_reads.length != fwd_reads.length
    #STDERR.puts rev_reads.join(":")
    #STDERR.puts fwd_reads.join(":")
    #raise "GSNAP case"
    STDERR.puts rev_reads.join("BUHJA")
    if rev_reads.length > fwd_reads.length
      fwd_reads = rep_line(fwd_reads, rev_reads)
    else
      rev_reads = rep_line(rev_reads, fwd_reads)
    end
  end
  rev_reads.each_with_index do |rev, i|
    fwd = fwd_reads[i]
    puts fwd[0...-1].join("\t")
    puts rev[0...-1].join("\t")
  end

end

sam_file = File.open(ARGV[0])
current_name = ""
lines = []
while !sam_file.eof?
  line = sam_file.readline()
  if line =~ /^@/
    puts line
    next
  end
  line.chomp!
  fields = line.split("\t")
  fields = check_hi_tag(fields)
  if lines.length != 0
    if get_name(lines[0][0]) != get_name(fields[0])
      fix_lines(lines,current_name)
      current_name = ""
    end
  end
  if current_name == ""
    #line.chomp!
    #fields = line.split("\t")
    current_name = get_name(fields[0])
    lines = [fields]
  else
    lines << fields
  end
  old_name = current_name
  while old_name == current_name && !sam_file.eof?
    line = sam_file.readline()
    line.chomp!
    fields = line.split("\t")
    fields = check_hi_tag(fields)
    lines << fields
    current_name = get_name(fields[0])
  end
  #STDERR.puts current_name
  current_name =~ /(\d+)/
  num = $1.to_i
  old_name =~ /(\d+)/
  old_num = $1.to_i
  #STDERR.puts old_num
  while !(num <= old_num+1)
    add_empty_lines(old_num)
    old_name = "seq.#{old_num+1}"
    old_num += 1
    STDERR.puts "HERE: #{num}"
    STDERR.puts "OLD_NAME: #{old_name}"
    STDIN.gets
  end

  #STDERR.puts current_name
  #STDERR.puts old_name
  lines = lines[0...-1] if !sam_file.eof?
  fix_lines(lines,old_name)
  #current_name = fields[0]
  #puts current_name
  #puts lines[-1]
  lines = [fields]
#  exit
end
