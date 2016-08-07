require 'optparse'
require "erubis"
require 'logger'
path = File.expand_path(File.dirname(__FILE__))
require "#{path}/logging"
include Logging

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

def setup_option(args)
  options = {
    :loglevel => "error",
    :debug => false,
    :nummer => 10000000,
    :fill => true,
    :read_length => 100,
    :start => 1
  }

  opt_parser = OptionParser.new do |opts|
    opts.separator ""
    opts.banner = "\nUsage: ruby rename_reads.rb [options] file.sam > fixed.sam"
    opts.separator ""
    # enumeration
    #opts.on('-a', '--algorithm ENUM', [:all, :contextmap2,
    #  :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
    #  :star,:soap,:soapsplice, :subread, :tophat2],'Choose from below:','all: DEFAULT',
    #  'contextmap2','crac','gsnap','hisat', 'mapsplice2',
    #  'olego','rum','star','soap','soapsplice','subread','tophat2') do |v|
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

    opts.on("-s", "--start [INT]",
      :REQUIRED,Integer,
      "start number of framgment that should be in the fixed.sam, DEFAULT: 1") do |s|
      options[:start] = s
    end



    opts.on("-v", "--verbose", "Run verbosely") do |v|
      options[:log_level] = "info"
    end

    opts.separator ""
  end

  args = ["-h"] if args.length == 0
  opt_parser.parse!(args)
  setup_logger(options[:log_level])
  if args.length != 1
    $logger.error("You provided #{args.length} input file(s), but 1 required!")
    raise "Please specify the input (file.sam)"
  end
  options
end

def run_all(arguments)
  $logger.info(arguments)
  options = setup_option(arguments)
  sam_file = File.open(arguments[0])
  startnum = options[:start]-1
  while !sam_file.eof?
    
    line = sam_file.readline()
    line.chomp!
    if line =~ /^@/
      puts line
      next
    end
    fields = line.split("\t")
    fields[0] =~ /(\d+)/
    num = $1.to_i
    fields[0] = "seq.#{num+startnum}"
    puts fields.join("\t")
  end
  $logger.info("All done!")
end

if __FILE__ == $0
  run_all(ARGV)
end

