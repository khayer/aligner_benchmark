#/project/itmatlab/aligner_benchmark/dataset/human/dataset_t3r1/anchor/cig
# fixed.sam
sam_file = ARGV[0]
dataset = ARGV[1]
species = ARGV[2]

readnames_by_group = {}
d = "/project/itmatlab/aligner_benchmark/dataset/#{species}/dataset_#{dataset}/anchor/cig/*cig"
puts d
# This yields full path and file name
Dir[d].each do |fn|
	File.open(fn).each do |l|
		readnames_by_group[l.split("\t")[0]]  = fn.split("/")[-1]
	end
end
puts readnames_by_group

files = {}
filenames = []
unique = readnames_by_group.values.uniq
unique.each do |names|
	puts names
	filenames << "#{sam_file}_#{names}"
	files[names] = File.open("#{sam_file}_#{names}", "w")
end

#puts files

File.open(sam_file).each do |line|
	name = line.split("\t")[0]
	if readnames_by_group[name]

		files[readnames_by_group[name]].puts line
	end
end

files.each_value do |f|
	f.close()
end

Dir["/project/itmatlab/aligner_benchmark/dataset/#{species}/dataset_#{dataset}/anchor/cig/*cig"].each do |fn|
	ind = filenames.index {|x| x =~ /#{fn.split("/")[-1]}$/}
	`sort -t'.' -k 2n #{filenames[ind]} > #{filenames[ind]}_s`
	`ruby #{File.expand_path(File.dirname(__FILE__))}/compare2truth_multi_mappers.rb -s #{fn} #{filenames[ind]}_s > #{filenames[ind]}_comp_res_multi_mappers.txt`
	`ruby #{File.expand_path(File.dirname(__FILE__))}/compare2truth.rb -s #{fn} #{filenames[ind]}_s > #{filenames[ind]}_comp_res.txt`
end
	