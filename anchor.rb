#/project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/anchor/cig
# fixed.sam
sam_file = ARGV[0]

readnames_by_group = {}
# This yields full path and file name
Dir["/project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/anchor/cig/*cig"].each do |fn|
	File.open(fn).each do |l|
		readnames_by_group[l.split("\t")[0]]  = fn.split("/")[-1]
	end
end

files = []
filenames = []
readnames_by_group.values do |names|
	filenames << "#{sam_file}_#{names}"
	files[names] = File.open("#{sam_file}_#{names}", "w")
end

File.open(sam_file).each do |line|
	name = line.split("\t")[0]
	if readnames_by_group[name]
		files[readnames_by_group[name]].puts line
	end
end

files.each_value do |f|
	f.close()
end

Dir["/project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/anchor/cig/*cig"].each do |fn|
	ind = filenames.index {|x| x =~ /#{fn.split("/")[-1]}$/}
	`ruby #{File.expand_path(File.dirname(__FILE__))}/compare2truth.rb #{fn} #{filenames[ind]} > #{filenames[ind]}_comp_res.txt`
end
	