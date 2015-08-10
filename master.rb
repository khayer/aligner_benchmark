require 'logger'
require './logging'
include Logging
require 'optparse'

#####
#
#   Runs the statistics for a given dataset
#   IN: dataset_name source_of_tree
#   out:
#   1) Sorted and appropriate sam files
#   2) runs compare2truth
#   3) runs compare junctions
#
####

# 2015/8/10 Katharina Hayer

$logger = Logger.new(STDERR)
$algorithms = [:contextmap2,
      :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
      :star, :subjunc, :tophat2]

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
    :algorithm => "all"}

  opt_parser = OptionParser.new do |opts|
    opts.banner = "\nUsage: ruby master.rb [options] dataset source_of_tree"
    opts.separator ""

    # enumeration
    opts.on('-a', '--algorithm ENUM', [:all,:contextmap2,
      :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
      :star, :subjunc, :tophat2],'Choose from below:','all: DEFAULT',
      'contextmap2','crac','gsnap','hisat', 'mapsplice2',
      'olego','rum','star','subjunc','tophat2') do |v|
      options[:algorithm] = v
    end

    opts.on("-d", "--debug", "Run in debug mode") do |v|
      options[:log_level] = "debug"
    end

    opts.on("-o", "--out_file [OUT_FILE]",
      :REQUIRED,String,
      "File for the output, Default: overview_table.xls") do |anno_file|
      options[:out_file] = anno_file
    end

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
  raise "Please specify the input files" if args.length == 0
  options
end



def run_tophat2(options, source_of_tree, dataset)
  l = `find #{source_of_tree}/tool_results/ -name #{dataset} | grep tophat2`
  l.split!("\n")
  raise "Trouble finding #{dateset}: #{l}" if l.length != 1
  l = l[0]
  Dir.glob("#{l}/*").each do |p|
    next unless File.directory? p
    Dir.chdir p

  end

end

def run(argv)
  options = setup_options(argv)
  dataset = argv[0]
  source_of_tree = argv[1]
  # Results go to
  out_directory = "#{source_of_tree}/statistics/#{dataset}"
  begin
    Dir.mkdir(out_directory)
  rescue SystemCallError
    if Dir.exists?(out_directory)
      logger.warn("Directory #{out_directory} exists!")
    else
      logger.error("Can't create directory #{out_directory}!")
      raise("Trouble creating directory, log for detials.")
    end
  end


  #setup_logger(options[:log_level])
  $logger.info("Hallo")
  $logger.debug("DEBUG")
  $logger.debug(options)
  $logger.debug(argv)

  if options[:algorithm] == "all"
    algorithms = $algorithms
  else
    algorithms = [options[:algorithm]]
  end

  $logger.debug("Algorithms = #{algorithms}")

  algorithms.each do |alg|
    case alg
    when :tophat2
      run_tophat2(options, source_of_tree, dataset)
    when :star
      puts "LALAA"
    end
  end
  #puts options[:cut_off]
end

if __FILE__ == $0
  run(ARGV)
end





