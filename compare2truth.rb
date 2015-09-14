require 'logger'
require './logging'
include Logging
require 'optparse'
require "erubis"

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
  options = {
    :loglevel => "error",
    :debug => false,
    :read_length => nil
  }

  opt_parser = OptionParser.new do |opts|
    opts.banner = "\nUsage: ruby compare2truth.rb [options] truth.cig sorted.sam"
    opts.separator ""
    opts.separator "truth.cig:"
    opts.separator "seq.1a  chr10 123502684 123502783 100M  123502684-123502783 - CTTAAGTATGGGGAAGGTAGAAAGTTCATTTCATTACTTATAAAATATGTCTTCTCAAGAACAAAACTGTGCTGTTACAACTCAGTGTTCAATGTGAAAT"
    opts.separator "seq.1b  chr10 123502530 123502629 100M  123502530-123502629 + AGGGAGTACTATATTCTAGGGGAAAAAACTATGCCAAGACAACAGACATGAACAGGACTGTCCTGAACAAATGGATTCCTGATGCTAACACAAGCTCCAT"
    opts.separator ""
    opts.separator "sprted.sam:"
    opts.separator "seq.1a  83  chr10 123502684 255 100M  = 123502530 -254  ATTTCACATTGAACACTGAGTTGTAACAGCACAGTTTTGTTCTTGAGAAGACATATTTTATAAGTAATGAAATGAACTTTCTACCTTCCCCATACTTAAG  * NH:i:1  HI:i:1  AS:i:192  nM:i:3"
    opts.separator "seq.1b  163 chr10 123502530 255 100M  = 123502684 254 AGGGAGTACTATATTCTAGGGGAAAAAACTATGCCAAGACAACAGACATGAACAGGACTGTCCTGAACAAATGGATTCCTGATGCTAACACAAGCTCCAT  * NH:i:1  HI:i:1  AS:i:192  nM:i:3"
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

    opts.on("-r", "--read_length [INT]",
      :REQUIRED,Integer,
      "read length, if not specified it will be taken from cig file") do |s|
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
  if args.length != 2
    $logger.error("You only provided #{args.length} fields, but 2 required!")
    raise "Please specify the input (truth.cig sorted.sam)"
  end
  options
end

class Stats
  def initialize()
    @total_number_of_bases_of_reads = 0
    @total_number_of_bases_aligned_correctly = 0
    @total_number_of_bases_aligned_incorrectly = 0
    @total_number_of_bases_aligned_ambiguously = 0
    @total_number_of_bases_unaligned = 0
    @total_number_of_bases_in_true_insertions = 0
    @total_number_of_bases_in_true_deletions = 0
    @total_number_of_bases_called_insertions = 0
    @total_number_of_bases_called_deletions = 0
    @insertions_called_correctly = 0
    @deletions_called_correctly = 0
  end

  attr_accessor :total_number_of_bases_of_reads,
    :total_number_of_bases_aligned_correctly,
    :total_number_of_bases_aligned_incorrectly,
    :total_number_of_bases_aligned_ambiguously,
    :total_number_of_bases_unaligned,
    :total_number_of_bases_in_true_insertions,
    :total_number_of_bases_in_true_deletions,
    :total_number_of_bases_called_insertions,
    :total_number_of_bases_called_deletions,
    :insertions_called_correctly,
    :deletions_called_correctly

  def to_s
    %{total_number_of_bases_of_reads: #{@total_number_of_bases_of_reads}
total_number_of_bases_aligned_correctly: #{@total_number_of_bases_aligned_correctly}
total_number_of_bases_aligned_incorrectly: #{@total_number_of_bases_aligned_incorrectly}
total_number_of_bases_aligned_ambiguously: #{@total_number_of_bases_aligned_ambiguously}
total_number_of_bases_unaligned: #{@total_number_of_bases_unaligned}
total_number_of_bases_in_true_insertions: #{@total_number_of_bases_in_true_insertions}
total_number_of_bases_in_true_deletions: #{@total_number_of_bases_in_true_deletions}
total_number_of_bases_called_insertions: #{@total_number_of_bases_called_insertions}
total_number_of_bases_called_deletions: #{@total_number_of_bases_called_deletions}
insertions_called_correctly: #{@insertions_called_correctly}
deletions_called_correctly: #{@deletions_called_correctly}
}
  end

  def process
    #Calc percentages TODO
  end
end


def files_valid?(truth_cig,sam_file,options)
  l = `grep ^seq #{truth_cig} | head -1`
  l.chomp!
  l =~ /seq.(\d+)/
  first_truth = $1
  l =~ /\t([^\t]+)$/;
  options[:read_length] ||= $1.length;
  l = `tail -1 #{truth_cig}`
  l.chomp!
  l =~ /seq.(\d+)/
  last_truth = $1
  l = `grep ^seq #{sam_file} | head -1`
  l.chomp!
  l =~ /seq.(\d+)/
  first_sam = $1
  l = `tail -1 #{sam_file}`
  l.chomp!
  l =~ /seq.(\d+)/
  last_sam = $1
  unless last_sam == last_truth && first_sam == first_truth
    logger.error("Sam file and cig file don't start and end in the same sequence!")
    raise "both files must start and end with the same sequence number and must have an entry for every sequence number in between."
  end
end

def comp_base_by_base(s_sam,c_cig,stats)

end

def process(current_group, cig_group, stats,options)
  cig_group.each do |l|
    l = l.split("\t")
    k = l[4].dup
    inserts = 0
    while k =~ /(\d+)I/
      inserts = inserts+$1.to_i
      k.sub!(/(\d+)I/,"")
    end
    stats.total_number_of_bases_in_true_insertions += inserts
    k = l[4].dup
    deletions = 0
    while k =~ /(\d+)D/
      deletions = deletions+$1.to_i
      k.sub!(/(\d+)D/,"")
    end
    stats.total_number_of_bases_in_true_deletions += deletions
    stats.total_number_of_bases_of_reads += options[:read_length]
    if current_group.length > 2
      stats.total_number_of_bases_aligned_ambiguously += options[:read_length]
    else
      current_group.each do |s|
        s = s.split("\t")
        next unless l[0] == s[0]
        if s[2] == "*"
          stats.total_number_of_bases_unaligned += options[:read_length]
        else
          if s[2] != l[1]
            stats.total_number_of_bases_aligned_incorrectly += options[:read_length]
          else
            if s[3] == l[2] && s[5] == l[4]
              stats.total_number_of_bases_aligned_correctly += options[:read_length]
              stats.insertions_called_correctly += inserts
              stats.total_number_of_bases_called_insertions += inserts
              stats.deletions_called_correctly += deletions
              stats.total_number_of_bases_called_deletions += deletions
            else
              comp_base_by_base(s,l,stats)
            end
          end
        end
      end
    end
  end
  $logger.debug(current_group.length)
  $logger.debug(cig_group[0])
end

def compare(truth_cig, sam_file, options)
  stats = Stats.new()
  $logger.debug(stats)
  truth_cig_handler = File.open(truth_cig)
  sam_file_handler = File.open(sam_file)
  current_group = []
  cig_group = []
  current_num = nil
  while !sam_file_handler.eof?
    # process one sequence name at a time
    line = sam_file_handler.readline.chomp
    next unless line =~ /^seq/
    line =~ /seq.(\d+)/
    current_num ||= $1
    if current_num == $1
      current_group << line
    else
      cig_group << truth_cig_handler.readline.chomp
      cig_group << truth_cig_handler.readline.chomp
      process(current_group, cig_group,stats,options)
      current_num = $1
      current_group = []
      cig_group = []
      current_group << line
    end
  end
  cig_group << truth_cig_handler.readline.chomp
  cig_group << truth_cig_handler.readline.chomp
  process(current_group, cig_group,stats,options)
  stats
end

def run(argv)
  options = setup_options(argv)
  truth_cig = argv[0]
  sam_file = argv[1]
  $logger.info("Options are #{options}")

  files_valid?(truth_cig,sam_file,options)
  stats = compare(truth_cig, sam_file, options)
  stats.process()
  puts stats
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end
