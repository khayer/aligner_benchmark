old = nil
File.open(ARGV[0]).each do |line|
	line.chomp!
	seqname = line.split("\t")[0]
	seqname =~ /(\d+)/
  current_num =  $1.to_i
  old ||= current_num
  if current_num == old || current_num == old+1
  	old = current_num
  else 
  	puts line
  	exit
  end
end