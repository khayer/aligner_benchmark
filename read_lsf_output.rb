require 'logger'
path = File.expand_path(File.dirname(__FILE__))
require "#{path}/logging"
include Logging
require 'optparse'
require 'csv'
require 'set'
require 'time'

# Read LSF Output
###
#
# IN:
# [hayer@consign aligner_benchmark]$ find */LOG-*-align -name "*align_job.*.out"
#     contextmap2/LOG-contextmap2-align/contextmap2-align_job.118736.out
#     contextmap2/LOG-contextmap2-align/contextmap2-align_job.118738.out
#     contextmap2/LOG-contextmap2-align/contextmap2-align_job.118768.out
#     crac/LOG-crac-align/crac-align_job.27104.out
#     crac/LOG-crac-align/crac-align_job.627655.out
#     crac/LOG-crac-align/crac-align_job.687653.out
#     crac/LOG-crac-align/crac-align_job.910332.out
# OUT: Summary
#
###

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
    opts.banner = "\nUsage: find . -name \"*/LOG-*-align/*-align_job.*.out\" | xargs ruby read_lsf_output.rb [options] sumary.txt [summary2.txt]"
    opts.separator ""
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

    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options[:log_level] = "info"
    end

    opts.separator ""
  end

  args = ["-h"] if args.length == 0
  opt_parser.parse!(args)
  setup_logger(options[:log_level])
  if args.length == 0
    $logger.error("You only did not provide any arguments!")
    raise "Please specify the input (run_name dataset source_of_tree)"
  end
  options
end


class RunningStats
  #def initialize(jobnumber, cmd, status, working_dir)
  #  @jobnumber = jobnumber
  #  @cmd = cmd
  #  @status = status
  #  @working_dir = working_dir
  #end
  def initialize(jobnumber, species, dataset, replicate,algorithm, time,
    cpu_time, max_memory, average_memory,max_processes,max_threads,run_time,
    turnaround_time)
    @jobnumber = jobnumber
    @species = species
    @dataset = dataset
    @replicate = replicate
    @algorithm = algorithm
    @time = time
    @cpu_time = cpu_time # in seconds
    @max_memory = max_memory # in MB
    @average_memory = average_memory #in MB
    @max_processes = max_processes
    @max_threads = max_threads
    @run_time = run_time # in sec
    @turnaround_time = turnaround_time # in sec
    #@levels = {"READ" => {}, "JUNC" => {}, "BASE" => {} }
  end

  attr_accessor :jobnumber, :species, :dataset, :replicate, :algorithms, :time, :algorithm,
    :cpu_time, :max_memory, :average_memory, :max_processes, :max_threads,
    :run_time, :turnaround_time

  def to_s
    "Jobnumber #{@jobnumber}; Species: #{@species}; Dataset: #{@dataset}, Replicate #{@replicate}"
  end

  def update_status
  end

end

def read_files(argv)
  all = []

  argv[0..-1].each do |arg|
    jobnumber, species, dataset, replicate, algorithm, time,
    cpu_time, max_memory, average_memory,max_processes,max_threads,run_time,
    turnaround_time = nil
    arg =~ /\/(\w*)-align_job.(\d+).out$/
    algorithm = $1
    jobnumber = $2
    $logger.debug(algorithm)
    $logger.debug(jobnumber)

    File.open(arg).each do |line|
      line.chomp!
      #puts line
      case
      when line =~ /^Results reported on/
        #DateTime.parse("Nov 13 18:32:05 2015")
        time = DateTime.parse(line)
        next
      when line =~ /^sh /
        line =~ /dataset_(\w*)_\w+_(t\d)(r\d).sh$/
        species = $1
        dataset = $2
        replicate = $3
      when line =~ /CPU time :/
        cpu_time = line.split(" ")[-2].to_f
        next
      when line =~ /Max Memory :/
        max_memory = line.split(" ")[-2].to_f
        next
      when line =~ /Average Memory :/
        average_memory = line.split(" ")[-2].to_f
        next
      when
        line =~ /Max Processes :/
        max_processes = line.split(" ")[-1].to_i
        next
      when
        line =~ /Max Threads :/
        max_threads = line.split(" ")[-1].to_i
        next
      when line =~ /Run time :/
        run_time = line.split(" ")[-2].to_f
        next
      when line =~ /Turnaround time :/
        turnaround_time = line.split(" ")[-2].to_f
        next
      end
    end
    $logger.debug(average_memory)
    add = true
    all.each do |e|
      next unless e.algorithm == algorithm
      next unless e.species == species
      next unless e.dataset == dataset
      next unless e.replicate == replicate
      if e.time > time
        add = false
      else
        all.delete(e)
      end
    end
    all << RunningStats.new(jobnumber, species, dataset, replicate, algorithm, time,
    cpu_time, max_memory, average_memory,max_processes,max_threads,run_time,
    turnaround_time) if add
  end
  all
end

def print_all(all)
  #precision
  result = "species\tdataset\treplicate\talgorithm\tmeasurement\tvalue\tcolor\n"
  all.each do |e|
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\tcpu_time\t#{e.cpu_time}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\tmax_memory\t#{e.max_memory}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\taverage_memory\t#{e.average_memory}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\tmax_processes\t#{e.max_processes}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\tmax_threads\t#{e.max_threads}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\trun_time\t#{e.run_time}\t#{$colors[e.algorithm.to_sym]}\n"
    result << "#{e.species}\t#{e.dataset}\t#{e.replicate}\t#{e.algorithm}\tturnaround_time\t#{e.turnaround_time}\t#{$colors[e.algorithm.to_sym]}\n"
  end
  puts result
end


def run(argv)
  options = setup_options(argv)
  $logger.debug(options)
  $logger.debug(argv)
  all = read_files(argv)
  $logger.debug(all)
  #exit
  print_all(all)
  #print_all2(all)
  #puts options[:cut_off]
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end
