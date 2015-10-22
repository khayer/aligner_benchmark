require 'logger'
require './logging'
include Logging
require 'optparse'
require 'csv'
require 'set'
###
#
# IN:
# [hayer@consign aligner_benchmark]$ ls Google\ Drive/AlignerBenchmarkLocal/summary/*txt
#     human_t1r1.txt human_t1r3.txt human_t2r2.txt human_t3r1.txt human_t3r3.txt
#     human_t1r2.txt human_t2r1.txt human_t2r3.txt human_t3r2.txt
# OUT: Summary for R-Plotting
#
###

# 2015/9/30 Katharina Hayer

# TODO filter for best outcome!!!!

$colors = {
  :clc => "#CC79A7",
  :contextmap2 => "#F0E442",
  :crac => "#D55E00",
  :gsnap => "#999999",
  :hisat => "maroon",
  :hisat2 => "maroon3",
  :mapsplice2 => "#009E73",
  :novoalign => "#0072B2",
  :olego => "#56B4E9",
  :rum => "forestgreen",
  :soapsplice => "black",
  :star => "#E69F00",
  :subread => "grey",
  :tophat2 => "sienna"
}

$logger = Logger.new(STDERR)

# Initialize logger
def setup_logger(loglevel)
  case loglevel
  when "debug"
    $logger.level = Logger::DEBUG
  when "warn"
    $logger.level = Logger::WARN
  when "info"
    $logger.level = Logger::INFO
  else
    $logger.level = Logger::ERROR
  end
end

def setup_options(args)
  options = {:out_file =>  "overview_table.xls", :loglevel => "error",
    :algorithm => "all", :transcripts => nil, :junctions_crossed => nil,
    :cig_file => nil, :stats_path => nil, :tool_result_path => nil,
    :aligner_benchmark => nil, :samtools => "samtools", :jobs_path => nil,
    :species => "human", :debug => false
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "\nUsage: ruby read_summaries.rb [options] sumary.txt [summary2.txt]"
    opts.separator ""
    opts.separator "e.g. summary = human_t1r1.txt"
    opts.separator "e.g. summary2 = human_t1r2.txt"
    opts.separator ""
    # enumeration
    #opts.on('-a', '--algorithm ENUM', [:all, :contextmap2,
    #  :crac, :gsnap, :hisat, :mapsplice2, :novoalign, :olego, :rum,
    #  :star,:soapsplice, :subread, :tophat2],'Choose from below:','all: DEFAULT',
    #  'contextmap2','crac','gsnap','hisat', 'mapsplice2','novoalign',
    #  'olego','rum','star','soapsplice','subread','tophat2') do |v|
    #  options[:algorithm] = v
    #end

    opts.on("-d", "--debug", "Run in debug mode") do |v|
      options[:log_level] = "debug"
      options[:debug] = true
    end

    #opts.on("-o", "--out_file [OUT_FILE]",
    #  :REQUIRED,String,
    #  "File for the output, Default: overview_table.xls") do |anno_file|
    #  options[:out_file] = anno_file
    #end

    opts.on("-s", "--species [String]",
      :REQUIRED,String,
      "Spiecies, Default: human") do |s|
      options[:species] = s
    end

    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options[:log_level] = "info"
    end

    opts.separator ""
  end

  args = ["-h"] if args.length == 0
  opt_parser.parse!(args)
  setup_logger(options[:log_level])
  if args.length == 0
    $logger.error("You only provided #{args.length} fields, but 3 required!")
    raise "Please specify the input (run_name dataset source_of_tree)"
  end
  options
end

class Run
  def initialize(species, dataset, replicate)
    @species = species
    @dataset = dataset
    @replicate = replicate
    @algorithms = Set.new
    @levels = {"READ" => {}, "JUNC" => {}, "BASE" => {} }
  end

  attr_accessor :species, :dataset, :replicate, :algorithms, :levels

  def to_s
    "species #{@species}; dataset: #{@dataset}; replicate: #{@replicate}; Levels: #{@levels}; algorithms #{@algorithms.to_a.join("|")}"
  end


end

def read_files(argv)
  all = []
  #names = ["Aligner"]
  argv[0..-1].each do |arg|
    arg =~ /\/([a-z]*)_(t\d)(r\d).txt/
    species = $1
    dataset = $2
    replicate = $3
    $logger.debug(replicate)
    level = nil
    names = []
    first = true
    current_run = Run.new(species, dataset, replicate)
    #info << arg.gsub(/([\.\/]|comp_res.txt$)/,"")
    current_mapping = {}
    File.open(arg).each do |line|
      line.chomp!
      if line =~ /^Aligner/
        fields = line.split("\t")
        fields[1...-1].each_with_index do |f, i|
          f.sub!(/#{species}_#{dataset}#{replicate}/,"")
          current_run.algorithms << f
          current_mapping[f] = i+1
        end
        next
      end
      if line =~ /^------/
        level = line.split(" ")[1]
        next
      end
      fields = line.split("\t")
      case fields[0]
      when "accuracy over uniquely aligned reads:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["recall"]  ||= []
          current_run.levels[level]["recall"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned incorrectly:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["aligned_incorrectly"]  ||= []
          current_run.levels[level]["aligned_incorrectly"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned ambiguously:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["aligned_ambiguously"]  ||= []
          current_run.levels[level]["aligned_ambiguously"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads unaligned:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["unaligned"]  ||= []
          current_run.levels[level]["unaligned"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases aligned incorrectly:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["aligned_incorrectly"]  ||= []
          current_run.levels[level]["aligned_incorrectly"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases aligned ambiguously:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["aligned_ambiguously"]  ||= []
          current_run.levels[level]["aligned_ambiguously"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases unaligned:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["unaligned"]  ||= []
          current_run.levels[level]["unaligned"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "accuracy over uniquely aligned bases:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases aligned:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["recall"]  ||= []
          current_run.levels[level]["recall"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "insertions FD rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["insertions_precision"]  ||= []
          current_run.levels[level]["insertions_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "insertions FN rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["insertions_recall"]  ||= []
          current_run.levels[level]["insertions_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "deletions FD rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["deletions_precision"]  ||= []
          current_run.levels[level]["deletions_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "deletions FN rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["deletions_recall"]  ||= []
          current_run.levels[level]["deletions_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "junctions FD rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "junctions FN rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["recall"]  ||= []
          current_run.levels[level]["recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      end
    end
    STDERR.puts current_mapping
    all << current_run
  end
  all
end


def print_all(all)
  #precision
  result = "species\tdataset\treplicate\tlevel\talgorithm\tmeasurement\tvalue\tcolor\n"
  all.each do |e|
    e.levels.each_pair do |level, measurement|
      measurement.each_pair do |m, values|
        values.each_with_index do |v,i|
          name = e.algorithms.to_a[i]
          if e.algorithms.to_a[i] =~ /^tophat2/
            if e.algorithms.to_a[i] == "tophat2coveragesearch-bowtie2sensitive"
              name = "tophat2"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /^star/
            if e.algorithms.to_a[i] == "star"
              name = "star"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /^olego/
            if e.algorithms.to_a[i] == "olegotwopass"
              name = "olego"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /^crac/
            if e.algorithms.to_a[i] == "cracnoambiguity"
              name = "crac"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /clc/
            if e.algorithms.to_a[i] == "clcsimulated_reads_HG19t3r1-10multihits"
              name = "clc"
            else
              next
            end
          end
          result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{level}\t#{name}\t#{m}\t#{v}\t#{$colors[name.to_sym]}\n"
        end
      end
    end
  end
 puts result
end


def run(argv)
  options = setup_options(argv)
  $logger.debug(options)
  $logger.debug(argv)
  all = read_files(argv)
  print_all(all)
  #puts options[:cut_off]
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end


=begin
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
    puts "---------------- JUNC LEVEL ---------------------"
  end
end
=end