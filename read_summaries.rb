require 'logger'
path = File.expand_path(File.dirname(__FILE__))
require "#{path}/logging"
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
    :species => "human", :debug => false, :tuned => false, :default => true,
    :annotation => false
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

    #opts.on("-s", "--species [String]",
    #  :REQUIRED,String,
    #  "Spiecies, Default: human") do |s|
    #  options[:species] = s
    #end

    opts.on("-t", "--tuned", "Run in tuned vs default mode") do |t|
      options[:tuned] = true
      options[:annotation] = false
      options[:default] = false
    end

    opts.on("-a", "--annotation", "Run in annotation vs no-annotation mode") do |t|
      options[:tuned] = false
      options[:annotation] = true
      options[:default] = false
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
    #@levels = {"READ" => {}, "JUNC" => {}, "BASE" => {} }
    @levels = {"READLEVEL" => {}, "READLEVEL(multimappers)" => {},
      "BASELEVEL" => {},  "BASELEVEL(multimappers)" => {},
      "JUNCLEVEL" => {} }
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
    arg =~ /\/([a-z]*)_(t\d)(r\d).t\w{2}$/
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
        fields[1..-1].each_with_index do |f, i|
          #STDERR.puts f
          f.sub!(/#{species}_#{dataset}#{replicate}/," ")

          current_run.algorithms << f
          current_mapping[f] = i+1
        end
        next
      end
      if line =~ /^------/
        k = line.split("\t")
        level = k[0].delete("- ")
        $logger.debug(level)
        next
      end
      fields = line.split("\t")
      case fields[0]
      when "% reads aligned correctly (over aligned reads) [PRECISION]:"#"accuracy over uniquely aligned reads:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned correctly (over uniquely aligned reads) [PRECISION]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned correctly [RECALL]:" #"accuracy over all reads:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["recall"]  ||= []
          current_run.levels[level]["recall"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% reads aligned incorrectly:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["aligned_incorrectly"]  ||= []
          current_run.levels[level]["aligned_incorrectly"]  << fields[current_mapping[n]].to_f / 100.0
          current_run.levels[level]["aligned_ambiguously"]  ||= [] if level == "READLEVEL(multimappers)"
          current_run.levels[level]["aligned_ambiguously"]  << 0.0 if level == "READLEVEL(multimappers)"
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
      when "% bases aligned correctly (over aligned bases) [PRECISION]:"
      #when "accuracy over uniquely aligned bases:"
        #$logger.debug("mee #{current_run.levels[level]["precision"]}")
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases aligned correctly (over uniquely aligned bases) [PRECISION]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["precision"]  ||= []
          current_run.levels[level]["precision"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "% bases aligned correctly [RECALL]:"
        current_run.algorithms.each_with_index do |n,i|
          #$logger.debug("here #{current_run.levels[level]["recall"]}")
          current_run.levels[level]["recall"]  ||= []
          current_run.levels[level]["recall"]  << fields[current_mapping[n]].to_f / 100.0
        end
      when "insertions FD rate [1 - PRECISION]:"#"insertions FD rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["insertions_precision"]  ||= []
          current_run.levels[level]["insertions_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "insertions FN rate [1 - RECALL]:"#"insertions FN rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["insertions_recall"]  ||= []
          current_run.levels[level]["insertions_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "deletions FD rate [1 - PRECISION]:"#"deletions FD rate:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["deletions_precision"]  ||= []
          current_run.levels[level]["deletions_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "deletions FN rate [1 - RECALL]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["deletions_recall"]  ||= []
          current_run.levels[level]["deletions_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "skipping FD rate [1 - PRECISION]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["skipping_precision"]  ||= []
          current_run.levels[level]["skipping_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "skipping FN rate [1 - RECALL]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["skipping_recall"]  ||= []
          current_run.levels[level]["skipping_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "junctions FD rate [1 - PRECISION]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["skipping_precision"]  ||= []
          current_run.levels[level]["skipping_precision"]  <<  1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      when "junctions FN rate [1 - RECALL]:"
        current_run.algorithms.each_with_index do |n,i|
          current_run.levels[level]["skipping_recall"]  ||= []
          current_run.levels[level]["skipping_recall"]  << 1.0 - fields[current_mapping[n]].to_f / 100.0
        end
      end
    end

    all << current_run
    STDERR.puts current_mapping
  end
  all
end

def print_all_default(all)
  #precision
  result = "species\tdataset\treplicate\tlevel\talgorithm\tmeasurement\tvalue\tcolor\n"
  all.each do |e|
    e.levels.each_pair do |level, measurement|
      measurement.each_pair do |m, values|
        values.each_with_index do |v,i|
          #$logger.debug("#{m} and #{values}")
          #$logger.debug("#{v} and #{i}")
          name = e.algorithms.to_a[i]
          if e.algorithms.to_a[i] =~ /^tophat2/
            if e.algorithms.to_a[i] == "tophat2coveragesearch-bowtie2sensitive" ||
              e.algorithms.to_a[i] == "tophat2"
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
            if e.algorithms.to_a[i] == "olegotwopass" || 
              e.algorithms.to_a[i] == "olego"
              name = "olego"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /^crac/
            if e.algorithms.to_a[i] == "cracnoambiguity" ||
              e.algorithms.to_a[i] == "crac"
              name = "crac"
            else
              next
            end
          end
          if e.algorithms.to_a[i] =~ /clc/
            if e.algorithms.to_a[i] =~ /^clcsimulated_reads_.*t.*r.*-10multihits$/ ||
              e.algorithms.to_a[i] == "clc"
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

def print_all_annotation(all)
  #precision
  result = "species\tdataset\treplicate\tlevel\talgorithm\tmeasurement\tvalue\tcolor\tannotation\n"
  all.each do |e|
    e.levels.each_pair do |level, measurement|
      measurement.each_pair do |m, values|
        values.each_with_index do |v,i|
          name = e.algorithms.to_a[i]
          anno = false
          if name =~ /anno$/
            anno = true
            #name = name.sub(/anno$/,"")
          end

          result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{level}\t#{name}\t#{m}\t#{v}\t#{$colors[name.to_sym]}\t#{anno}\n"
        end
      end
    end
  end
 puts result
end

# FOR DEFAUlT VS TUNED
def print_all_tuned(all)
  #precision
  result = "species\tdataset\treplicate\tlevel\talgorithm\tmeasurement\tvalue\tcolor\ttuned\n"
  all.each do |e|
    e.levels.each_pair do |level, measurement|
      measurement.each_pair do |m, values|
        values.each_with_index do |v,i|
          name = e.algorithms.to_a[i]
          tuned = "default"
          if name =~ /tuned$/
            tuned = "tuned"
            #name =~ /_?(FNR|FDR)?_(tuned$)/
            #tuned = "#{$1} #{$2}"
            #name = name.sub(/_?(FNR|FDR)?_(tuned$)/, "").strip
          end
          #if e.algorithms.to_a[i] =~ /^tophat2/
          #  if name == "tophat2nocoveragesearch-bowtie2sensitive"
          #    name = "tophat2"
          #  else
          #    next
          #  end
          #end
          #if e.algorithms.to_a[i] =~ /^star/
          #  if name == "star"
          #    name = "star"
          #  else
          #    next
          #  end
          #end
          #if e.algorithms.to_a[i] =~ /^olego/
          #  if e.algorithms.to_a[i] == "olego-twopass"
          #    name = "olego"
          #  else
          #    next
          #  end
          #end
          #if e.algorithms.to_a[i] =~ /^crac/
          #  if name == "crac-noambiguity"
          #    name = "crac"
          #  else
          #    next
          #  end
          #end
          #if e.algorithms.to_a[i] =~ /clc/
          #  if name == "clc"
          #    name = "clc"
          #  else
          #    next
          #  end
          #end
          result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{level}\t#{name}\t#{m}\t#{v}\t#{$colors[name.to_sym]}\t#{tuned}\n"
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
  case
  when options[:default]
    print_all_default(all)
  when options[:annotation]
    print_all_annotation(all)
  when options[:tuned]
    print_all_tuned(all)
  end

  #print_all2(all)
  #puts options[:cut_off]
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end
