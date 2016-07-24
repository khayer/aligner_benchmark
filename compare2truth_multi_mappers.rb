require 'optparse'
require "erubis"
require 'logger'
path = File.expand_path(File.dirname(__FILE__))
require "#{path}/logging"
include Logging

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
    opts.banner = "\nUsage: ruby compare2truth_multi_mappers.rb [options] truth.cig sorted.sam"
    opts.separator ""
    opts.separator "truth.cig:"
    opts.separator "seq.1a  chr10 123502684 123502783 100M  123502684-123502783 - CTTAAGTATGGGGAAGGTAGAAAGTTCATTTCATTACTTATAAAATATGTCTTCTCAAGAACAAAACTGTGCTGTTACAACTCAGTGTTCAATGTGAAAT"
    opts.separator "seq.1b  chr10 123502530 123502629 100M  123502530-123502629 + AGGGAGTACTATATTCTAGGGGAAAAAACTATGCCAAGACAACAGACATGAACAGGACTGTCCTGAACAAATGGATTCCTGATGCTAACACAAGCTCCAT"
    opts.separator ""
    opts.separator "sorted.sam:"
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
      options[:read_length] = s
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
    @total_number_of_reads = 0
    @total_number_of_bases_aligned_correctly = 0
    @total_number_of_reads_aligned_correctly = 0
    @total_number_of_bases_aligned_incorrectly = 0
    @total_number_of_reads_aligned_incorrectly = 0
    @total_number_of_bases_aligned_ambiguously = 0
    @total_number_of_reads_aligned_ambiguously = 0
    @total_number_of_bases_unaligned = 0
    @total_number_of_reads_unaligned = 0
    @total_number_of_bases_aligned_correctly_pair = 0
    @total_number_of_reads_aligned_correctly_pair = 0
    @total_number_of_bases_aligned_incorrectly_pair = 0
    @total_number_of_reads_aligned_incorrectly_pair = 0
    @total_number_of_bases_aligned_ambiguously_pair = 0
    @total_number_of_reads_aligned_ambiguously_pair = 0
    @total_number_of_bases_unaligned_pair = 0
    @total_number_of_reads_unaligned_pair = 0
    @total_number_of_bases_in_true_insertions = 0
    @total_number_of_bases_in_true_deletions = 0
    @total_number_of_bases_in_true_skipping = 0
    @total_number_of_bases_in_true_skipping_binary = 0
    @total_number_of_reads_in_true_skipping_binary = 0
    @total_number_of_bases_called_insertions = 0
    @total_number_of_bases_called_deletions = 0
    @total_number_of_bases_called_skipped = 0
    @total_number_of_bases_called_skipped_binary = 0
    @insertions_called_correctly = 0
    @deletions_called_correctly = 0
    @skipping_called_correctly = 0
    @skipping_called_correctly_binary = 0
    # Sides can be one of "none", "left", "right", "ambiguous" or "both"
    @skipping_sides = [0,0,0,0]
  end

  attr_accessor :total_number_of_bases_of_reads,
    :total_number_of_reads,
    :total_number_of_bases_aligned_correctly,
    :total_number_of_reads_aligned_correctly,
    :total_number_of_bases_aligned_incorrectly,
    :total_number_of_reads_aligned_incorrectly,
    :total_number_of_bases_aligned_ambiguously,
    :total_number_of_reads_aligned_ambiguously,
    :total_number_of_bases_unaligned,
    :total_number_of_reads_unaligned,
    :total_number_of_bases_aligned_correctly_pair,
    :total_number_of_reads_aligned_correctly_pair,
    :total_number_of_bases_aligned_incorrectly_pair,
    :total_number_of_reads_aligned_incorrectly_pair,
    :total_number_of_bases_aligned_ambiguously_pair,
    :total_number_of_reads_aligned_ambiguously_pair,
    :total_number_of_bases_unaligned_pair,
    :total_number_of_reads_unaligned_pair,
    :total_number_of_bases_in_true_insertions,
    :total_number_of_bases_in_true_deletions,
    :total_number_of_bases_in_true_skipping,
    :total_number_of_bases_in_true_skipping_binary,
    :total_number_of_reads_in_true_skipping_binary,
    :total_number_of_bases_called_insertions,
    :total_number_of_bases_called_deletions,
    :total_number_of_bases_called_skipped,
    :total_number_of_bases_called_skipped_binary,
    :insertions_called_correctly,
    :deletions_called_correctly,
    :skipping_called_correctly,
    :skipping_called_correctly_binary,
    :skipping_sides

  def to_s
    %{total_number_of_bases_of_reads: #{@total_number_of_bases_of_reads}
total_number_of_reads: #{@total_number_of_reads}
total_number_of_bases_aligned_correctly: #{@total_number_of_bases_aligned_correctly}
total_number_of_reads_aligned_correctly: #{@total_number_of_reads_aligned_correctly}
total_number_of_bases_aligned_incorrectly: #{@total_number_of_bases_aligned_incorrectly}
total_number_of_reads_aligned_incorrectly: #{@total_number_of_reads_aligned_incorrectly}
total_number_of_bases_aligned_ambiguously: #{@total_number_of_bases_aligned_ambiguously}
total_number_of_reads_aligned_ambiguously: #{@total_number_of_reads_aligned_ambiguously}
total_number_of_bases_unaligned: #{@total_number_of_bases_unaligned}
total_number_of_reads_unaligned: #{@total_number_of_reads_unaligned}
total_number_of_bases_in_true_insertions: #{@total_number_of_bases_in_true_insertions}
total_number_of_bases_in_true_deletions: #{@total_number_of_bases_in_true_deletions}
total_number_of_bases_in_true_skipping: #{@total_number_of_bases_in_true_skipping}
total_number_of_bases_in_true_skipping_binary: #{@total_number_of_bases_in_true_skipping_binary}
total_number_of_bases_called_insertions: #{@total_number_of_bases_called_insertions}
total_number_of_bases_called_deletions: #{@total_number_of_bases_called_deletions}
total_number_of_bases_called_skipped: #{@total_number_of_bases_called_skipped}
total_number_of_bases_called_skipped_binary: #{@total_number_of_bases_called_skipped_binary}
insertions_called_correctly: #{@insertions_called_correctly}
deletions_called_correctly: #{@deletions_called_correctly}
skipping_called_correctly: #{@skipping_called_correctly}
skipping_called_correctly_binary: #{@skipping_called_correctly_binary}
skipping_sides: #{@skipping_sides.join(":")}}
  end

  def fill_skipping_sides(word, num=1)
    #Sides can be one of "none", "left", "right", "ambiguous" or "both"
    case word
    when "none"
      @skipping_sides[0] += num
    when "left"
      @skipping_sides[1] += num
    when "right"
      @skipping_sides[2] += num
    else
      @skipping_sides[3] += num
    end

  end

  def process
    # READ LEVEL
    out = "-------------------------------------- Multi-Mappers!\n"
    out += "total_number_of_reads:\t#{@total_number_of_reads}\n"
    percent_reads_aligned_correctly = (@total_number_of_reads_aligned_correctly.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all reads:\t#{percent_reads_aligned_correctly}%\n"
    total_num_unique_aligners = @total_number_of_reads_aligned_correctly + @total_number_of_reads_aligned_incorrectly
    #$logger.debug("total_num_unique_aligned_reads=#{total_num_unique_aligners}")
    if total_num_unique_aligners == 0
      accuracy_on_unique_aligners = 0
    else
      accuracy_on_unique_aligners = (@total_number_of_reads_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    end
    ##print "% unique aligners correct:\t$accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned reads:\t#{accuracy_on_unique_aligners}%\n"
    percent_reads_aligned_incorrectly = (@total_number_of_reads_aligned_incorrectly.to_f / @total_number_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% reads aligned incorrectly:\t#{percent_reads_aligned_incorrectly}%\n"
    percent_reads_aligned_ambiguously = (@total_number_of_reads_aligned_ambiguously.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% reads aligned ambiguously:\t#{percent_reads_aligned_ambiguously}%\n"
    percent_reads_unaligned = (@total_number_of_reads_unaligned.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% reads unaligned:\t#{percent_reads_unaligned}%\n"
    percent_reads_aligned = 100 - percent_reads_unaligned
    out += "% reads aligned:\t#{percent_reads_aligned}%\n"

    intron_rate = (@total_number_of_reads_in_true_skipping_binary.to_f / @total_number_of_reads.to_f * 1000000).to_i / 10000.0
    out += "% of reads with true introns:\t#{intron_rate}%\n"


    # BASE LEVEL
    out += "--------------------------------------\n"
    out += "total_number_of_bases_of_reads:\t#{@total_number_of_bases_of_reads}\n"
    percent_bases_aligned_correctly = (@total_number_of_bases_aligned_correctly.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all bases:\t#{percent_bases_aligned_correctly}%\n"
    total_num_unique_aligners = @total_number_of_bases_aligned_correctly + @total_number_of_bases_aligned_incorrectly
    $logger.debug("total_num_unique_aligners=#{total_num_unique_aligners}")
    if total_num_unique_aligners == 0
      accuracy_on_unique_aligners = 0
    else
      accuracy_on_unique_aligners = (@total_number_of_bases_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    end
    ##print "% unique aligners correct:\t$accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned bases:\t#{accuracy_on_unique_aligners}%\n"
    percent_bases_aligned_incorrectly = (@total_number_of_bases_aligned_incorrectly.to_f / @total_number_of_bases_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% bases aligned incorrectly:\t#{percent_bases_aligned_incorrectly}%\n"
    percent_bases_aligned_ambiguously = (@total_number_of_bases_aligned_ambiguously.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% bases aligned ambiguously:\t#{percent_bases_aligned_ambiguously}%\n"
    percent_bases_unaligned = (@total_number_of_bases_unaligned.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% bases unaligned:\t#{percent_bases_unaligned}%\n"
    percent_bases_aligned = 100 - percent_bases_unaligned
    out += "% bases aligned:\t#{percent_bases_aligned}%\n"
    #puts "number of bases in true insertions = #{@total_number_of_bases_in_true_insertions}"
    insertion_rate = (@total_number_of_bases_in_true_insertions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    out += "% of bases in true insertions:\t#{insertion_rate}%\n"
    deletion_rate = (@total_number_of_bases_in_true_deletions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    out += "% of bases in true deletions:\t#{deletion_rate}%\n"


    # INSERTIONS DELETIONS SKIPPING

    if(@total_number_of_bases_in_true_insertions==0)
      out += "insertions FN/FD rate:\tNo insertions exist in true data.\n"
    else
      if(@total_number_of_bases_called_insertions>0)
        #false_discovery_rate
        insertions_false_discovery_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_called_insertions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "insertions FD rate:\t#{insertions_false_discovery_rate}%\n"
      else
        out += "insertions FD rate:\t0% (no insertions called)\n"
      end
      #false_negative_rate
      insertions_false_negative_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_in_true_insertions.to_f * 10000).to_i / 10000.0) * 100* 10000).to_i/10000.0
      out += "insertions FN rate:\t#{insertions_false_negative_rate}%\n"
    end

    if(@total_number_of_bases_in_true_deletions==0)
      out += "deletions FN/FD rate:\tNo deletions exist in true data.\n"
    else
      if(@total_number_of_bases_called_deletions>0)
        #false_discovery_rate
        deletions_false_discovery_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_called_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "deletions FD rate:\t#{deletions_false_discovery_rate}%\n"
      else
        out += "deletions FD rate:\t0% (no deletions called)\n"
      end
      #false_negative_rate
      deletions_false_negative_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_in_true_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      out += "deletions FN rate:\t#{deletions_false_negative_rate}%\n"
    end

    if(@total_number_of_bases_in_true_skipping==0)
      out += "skipping FN/FD rate:\tNo skipping exist in true data.\n"
    else
      if(@total_number_of_bases_called_skipped>0)
        #false_discovery_rate
        skipping_false_discovery_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_called_skipped.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "skipping FD rate:\t#{skipping_false_discovery_rate}%\n"
      else
        out += "skipping FD rate:\t0% (no skipping called)\n"
      end
      #false_negative_rate
      skipping_false_negative_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_in_true_skipping.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      out += "skipping FN rate:\t#{skipping_false_negative_rate}%\n"
    end
    
    #puts "number of bases in true insertions = #{@total_number_of_bases_in_true_insertions}"

    #if(@total_number_of_bases_in_true_skipping_binary==0)
    #  out += "skipping FN/FD rate:\tNo skipping exist in true data.\n"
    #else
    #  if(@total_number_of_bases_called_skipped_binary>0)
    #    #false_discovery_rate
    #    skipping_false_discovery_rate = ((1 - (@skipping_called_correctly_binary.to_f / @total_number_of_bases_called_skipped_binary.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
    #    out += "skipping FD rate:\t#{skipping_false_discovery_rate}%\n"
    #  else
    #    out += "skipping FD rate:\t0% (no skipping called)\n"
    #  end
    #  #false_negative_rate
    #  skipping_false_negative_rate = ((1 - (@skipping_called_correctly_binary.to_f / @total_number_of_bases_in_true_skipping_binary.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
    #  out += "skipping FN rate:\t#{skipping_false_negative_rate}%\n"
    #end
    # JUNCTIONS LEVEL
    out += "--------------------------------------\n"


    if(@total_number_of_bases_in_true_skipping_binary==0)
      out += "junctions FN/FD rate:\tNo skipping exist in true data.\n"
    else
      if(@total_number_of_bases_called_skipped_binary>0)
        #false_discovery_rate
        skipping_false_discovery_rate = ((1 - (@skipping_called_correctly_binary.to_f / @total_number_of_bases_called_skipped_binary.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "junctions FD rate:\t#{skipping_false_discovery_rate}%\n"
      else
        out += "junctions FD rate:\t0% (no junctions called)\n"
      end
      #false_negative_rate
      skipping_false_negative_rate = ((1 - (@skipping_called_correctly_binary.to_f / @total_number_of_bases_in_true_skipping_binary.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      out += "junctions FN rate:\t#{skipping_false_negative_rate}%\n"
    end
    out += "Junctions Sides (none|left|right|both):\t#{@skipping_sides.join("|")}\n"
    if total_number_of_bases_called_skipped_binary > 0
      out += "Junctions Sides (none|left|right|both)% of all called:\t#{@skipping_sides.map { |e| "#{(((e.to_f/total_number_of_bases_called_skipped_binary.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0}%"}.join("|")}\n"
    else
      out += "Junctions Sides (none|left|right|both)% of all called:\tNaN|NaN|NaN|NaN"
    end

    out +=  "-------------------------------------- as pair\n"
    out += "total_number_of_reads:\t#{@total_number_of_reads}\n"
    percent_reads_aligned_correctly_pair = (@total_number_of_reads_aligned_correctly_pair.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all reads pair:\t#{percent_reads_aligned_correctly_pair}%\n"
    total_num_unique_aligners_pair = @total_number_of_reads_aligned_correctly_pair + @total_number_of_reads_aligned_incorrectly_pair
    #$logger.debug("total_num_unique_aligned_reads=#{total_num_unique_aligners}")
    if total_num_unique_aligners_pair == 0
      accuracy_on_unique_aligners_pair = 0
    else
      accuracy_on_unique_aligners_pair = (@total_number_of_reads_aligned_correctly_pair.to_f / total_num_unique_aligners_pair.to_f * 10000).to_i / 100.0
    end
    ##print "% unique aligners correct:\t$accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned reads:\t#{accuracy_on_unique_aligners_pair}%\n"
    percent_reads_aligned_incorrectly_pair = (@total_number_of_reads_aligned_incorrectly_pair.to_f / @total_number_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% reads aligned incorrectly:\t#{percent_reads_aligned_incorrectly_pair}%\n"
    percent_reads_aligned_ambiguously_pair = (@total_number_of_reads_aligned_ambiguously_pair.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% reads aligned ambiguously:\t#{percent_reads_aligned_ambiguously_pair}%\n"
    percent_reads_unaligned_pair = (@total_number_of_reads_unaligned_pair.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% reads unaligned:\t#{percent_reads_unaligned_pair}%\n"
    percent_reads_aligned_pair = 100 - percent_reads_unaligned_pair
    out += "% reads aligned:\t#{percent_reads_aligned_pair}%\n"

    # BASE LEVEL
    out += "-------------------------------------- as pair\n"
    out += "total_number_of_bases_of_reads:\t#{@total_number_of_bases_of_reads}\n"
    percent_bases_aligned_correctly_pair = (@total_number_of_bases_aligned_correctly_pair.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all bases:\t#{percent_bases_aligned_correctly_pair}%\n"
    total_num_unique_aligners_pair = @total_number_of_bases_aligned_correctly_pair + @total_number_of_bases_aligned_incorrectly_pair
    $logger.debug("total_num_unique_aligners=#{total_num_unique_aligners_pair}")
    if total_num_unique_aligners_pair == 0
      accuracy_on_unique_aligners = 0
    else
      accuracy_on_unique_aligners = (@total_number_of_bases_aligned_correctly_pair.to_f / total_num_unique_aligners_pair.to_f * 10000).to_i / 100.0
    end
    ##print "% unique aligners correct:\t$accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned bases:\t#{accuracy_on_unique_aligners}%\n"
    percent_bases_aligned_incorrectly = (@total_number_of_bases_aligned_incorrectly_pair.to_f / @total_number_of_bases_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% bases aligned incorrectly:\t#{percent_bases_aligned_incorrectly}%\n"
    percent_bases_aligned_ambiguously = (@total_number_of_bases_aligned_ambiguously_pair.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% bases aligned ambiguously:\t#{percent_bases_aligned_ambiguously}%\n"
    percent_bases_unaligned = (@total_number_of_bases_unaligned_pair.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% bases unaligned:\t#{percent_bases_unaligned}%\n"
    percent_bases_aligned = 100 - percent_bases_unaligned
    out += "% bases aligned:\t#{percent_bases_aligned}%\n"

    out
  end

  def process_old
    # READ LEVEL
    out = "--------------------------------------\n"
    out += "total_number_of_reads = #{@total_number_of_reads}\n"
    percent_reads_aligned_correctly = (@total_number_of_reads_aligned_correctly.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all reads: #{percent_reads_aligned_correctly}%\n"
    total_num_unique_aligners = @total_number_of_reads_aligned_correctly + @total_number_of_reads_aligned_incorrectly
    #$logger.debug("total_num_unique_aligned_reads=#{total_num_unique_aligners}")
    accuracy_on_unique_aligners = (@total_number_of_reads_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    ##print "% unique aligners correct: $accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned reads: #{accuracy_on_unique_aligners}%\n"
    percent_reads_aligned_incorrectly = (@total_number_of_reads_aligned_incorrectly.to_f / @total_number_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% reads aligned incorrectly: #{percent_reads_aligned_incorrectly}%\n"
    percent_reads_aligned_ambiguously = (@total_number_of_reads_aligned_ambiguously.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% reads aligned ambiguously: #{percent_reads_aligned_ambiguously}%\n"
    percent_reads_unaligned = (@total_number_of_reads_unaligned.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% reads unaligned: #{percent_reads_unaligned}%\n"
    percent_reads_aligned = 100 - percent_reads_unaligned
    out += "% reads aligned: #{percent_reads_aligned}%\n"
    # BASE LEVEL
    out += "--------------------------------------\n"
    out += "total_number_of_bases_of_reads = #{@total_number_of_bases_of_reads}\n"
    percent_bases_aligned_correctly = (@total_number_of_bases_aligned_correctly.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    out += "accuracy over all bases: #{percent_bases_aligned_correctly}%\n"
    total_num_unique_aligners = @total_number_of_bases_aligned_correctly + @total_number_of_bases_aligned_incorrectly
    $logger.debug("total_num_unique_aligners=#{total_num_unique_aligners}")
    accuracy_on_unique_aligners = (@total_number_of_bases_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    ##print "% unique aligners correct: $accuracy_on_unique_aligners%\n";
    out += "accuracy over uniquely aligned bases: #{accuracy_on_unique_aligners}%\n"
    percent_bases_aligned_incorrectly = (@total_number_of_bases_aligned_incorrectly.to_f / @total_number_of_bases_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    out += "% bases aligned incorrectly: #{percent_bases_aligned_incorrectly}%\n"
    percent_bases_aligned_ambiguously = (@total_number_of_bases_aligned_ambiguously.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    out += "% bases aligned ambiguously: #{percent_bases_aligned_ambiguously}%\n"
    percent_bases_unaligned = (@total_number_of_bases_unaligned.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    out += "% bases unaligned: #{percent_bases_unaligned}%\n"
    percent_bases_aligned = 100 - percent_bases_unaligned
    out += "% bases aligned: #{percent_bases_aligned}%\n"
    #puts "number of bases in true insertions = #{@total_number_of_bases_in_true_insertions}"
    insertion_rate = (@total_number_of_bases_in_true_insertions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    out += "% of bases in true insertions: #{insertion_rate}%\n"
    deletion_rate = (@total_number_of_bases_in_true_deletions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    out += "% of bases in true deletions: #{deletion_rate}%\n"

    # INSERTIONS DELETIONS SKIPPING
    out += "--------------------------------------\n"
    if(@total_number_of_bases_in_true_insertions==0)
      out += "insertions FN/FD rate: No insertions exist in true data.\n"
    else
      if(@total_number_of_bases_called_insertions>0)
        #false_discovery_rate
        insertions_false_discovery_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_called_insertions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "insertions FD rate: #{insertions_false_discovery_rate}%\n"
      else
        out += "insertions FD rate: 0% (no insertions called)\n"
      end
      #false_negative_rate
      insertions_false_negative_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_in_true_insertions.to_f * 10000).to_i / 10000.0) * 100* 10000).to_i/10000.0
      out += "insertions FN rate: #{insertions_false_negative_rate}%\n"
    end

    if(@total_number_of_bases_in_true_deletions==0)
      out += "deletions FN/FD rate: No deletions exist in true data.\n"
    else
      if(@total_number_of_bases_called_deletions>0)
        #false_discovery_rate
        deletions_false_discovery_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_called_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "deletions FD rate: #{deletions_false_discovery_rate}%\n"
      else
        out += "deletions FD rate: 0% (no deletions called)\n"
      end
      #false_negative_rate
      deletions_false_negative_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_in_true_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      out += "deletions FN rate: #{deletions_false_negative_rate}%\n"
    end

    if(@total_number_of_bases_in_true_skipping==0)
      out += "skipping FN/FD rate: No skipping exist in true data.\n"
    else
      if(@total_number_of_bases_called_skipped>0)
        #false_discovery_rate
        skipping_false_discovery_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_called_skipped.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        out += "skipping FD rate: #{skipping_false_discovery_rate}%\n"
      else
        out += "skipping FD rate: 0% (no skipping called)\n"
      end
      #false_negative_rate
      skipping_false_negative_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_in_true_skipping.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      out += "skipping FN rate: #{skipping_false_negative_rate}%\n"
    end

    out
  end
end

class MappingObject
  def initialize()
    # Current Pos 100
    # 95M [100,195]
    @matches = []
    # 3I [100,3]
    @insertions = []
    # 4D [100,104]
    @deletions = []
    # 123N [100,223]
    @skipped = []
    # 30S/H [100,30]
    @unaligned = []
  end

  attr_accessor :matches,
    :insertions,
    :deletions,
    :skipped,
    :unaligned

  def to_s
    %{Matches: #{matches.join(":")},
Insertions: #{insertions.join(":")},
Deletions: #{deletions.join(":")},
Skipped: #{skipped.join(":")},
Unaligned: #{unaligned.join(":")}
}
  end

  #def fix
  #  @matches = comp(@matches)
  #  @insertions = comp(@insertions)
  #  @deletions = comp(@deletions)
  #  @skipped = comp(@skipped)
  #  @unaligned = comp(@unaligned)
  #end
#
  #private
#
  #def comp(some)
  #  out = some.dup
  #  out.flatten!
  #  out.each_with_index do |t1, i|
  #    next unless i.odd?
  #    next unless out[i+1]
  #    puts "MOMA"
  #    if t1 == out[i+1]
  #      out.delete_at(i)
  #      out.delete_at(i)
  #    end
  #  end
  #  out
  #end

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
  unless last_sam == last_truth && first_sam == first_truth && last_sam &&  first_sam
    $logger.error("Sam file and cig file don't start and end in the same sequence!")
    $logger.debug("last_sam #{last_sam}, last_truth #{last_truth}")
    $logger.debug("first_sam #{first_sam}, first_truth #{first_truth}")
    raise "both files must start and end with the same sequence number and must have an entry for every sequence number in between."
  end
end

def fill_mapping_object(mo, start, cigar_nums, cigar_letters)
  current_pos = start
  add = 0
  cigar_nums.each_with_index do |num,i|
    case cigar_letters[i]
    when "M"
      mo.matches << [current_pos, current_pos + num + add]
      current_pos += num #+ add
      add = 0
    when "I"
      mo.insertions << [current_pos, current_pos + num]
      add = 1 #num
    when "D"
      mo.deletions << [current_pos, current_pos + num]
      current_pos += num
    when "N"
      mo.skipped << [current_pos, current_pos + num]
      current_pos += num
    when "H","S"
      mo.unaligned << [current_pos, current_pos + num]
      #current_pos += num
    end
  end
end

def compare_lines(cig_line,sam_line)
  score = 0
  cig_line_fields = cig_line.split("\t")
  sam_line_fields = sam_line.split("\t")
  # score is +1 if chr matches
  score += 1 if cig_line_fields[1] == sam_line_fields[2]
  # score is +1 if start position matches
  score += 1 if cig_line_fields[2] == sam_line_fields[3]
  # score is +1 if cigar string matches too
  score += 1 if cig_line_fields[4] == sam_line_fields[5]
  return score
end

def find_best_match(current_group,cig_group)
  cig_group_a = cig_group.detect {|i| i.split("\t")[0] =~ /a$/ }
  cig_group_b = cig_group.detect {|i| i.split("\t")[0] =~ /b$/ }
  scores = []
  scores_pairs = []
  current_group.each do |e|
    e_fields = e.split("\t")
    if e_fields[0] =~ /a$/
      score = compare_lines(cig_group_a,e)
    else
      score = compare_lines(cig_group_b,e)
    end
    scores << score
  end
  ind = scores.find_index(scores.max)
  #puts scores
  n = 2
  scores_pairs = (n-2).step(scores.size - n, n).map { |i| scores[i]+ scores[i+1]}
  #puts scores_pairs.join("PAIRS")
  ind2 = scores_pairs.find_index(scores_pairs.max)
  current_group = [current_group[ind2*2],current_group[ind2*2+1]]
  multi = true if scores.max == 3
  return current_group, multi
end

# Returns [ #matches, #misaligned]
def compare_ranges(true_ranges, inferred_ranges, insertion_mode = false)
  matches = 0
  misaligned = 0
  # Sides can be one of "none", "left", "right", "ambiguous" or "both"
  sides = []
  true_ranges.each_with_index do |t1, i|
    next unless i.even?
    t2 = true_ranges[i+1]
    inferred_ranges.each_with_index do |i1, k|
      next unless k.even?
      old_matches = matches
      old_misaligned = misaligned
      i2 = inferred_ranges[k+1]
      if t1 <= i1 && t2 >= i2
        matches += (i2 - i1)
        side = "none"
        side = "left" if t1 == i1
        side = "right" if t2 == i2
        side = "both" if t2 == i2 && t1 == i1
        sides << side
      elsif !insertion_mode && t1 <= i1 && i1 < t2 && t2 <= i2
        matches += (t2 - i1)
        misaligned += i2 - t2
        if t1 == i1
          sides << "left"
        else
          sides << "none"
        end
      elsif insertion_mode && t1 <= i1 && i1 <= t2 && t2 <= i2
        #puts "YOUNK"
        matches += (t2 - i1)
        misaligned += i2 - t2
      #elsif t1 >= i1  && t2 <= i2
      #  matches += (t2 - t1)
      #  misaligned += (i2 - t2) + (t1 - i1)
      #  $logger.debug "BUBBLES"
      elsif !insertion_mode && t1 >= i1  && t2 >= i2 && t1 < i2
        matches += (i2 - t1)
        misaligned += (t1 - i1)
        if t2 == i2
          sides << "right"
        else
          sides << "none"
        end
      elsif insertion_mode && t1 >= i1  && t2 >= i2 && t1 <= i2
        #puts "YOUNS"
        matches += (i2 - t1)
        misaligned += (t1 - i1)

      end
      $logger.debug "Matches #{matches}"
      $logger.debug "Misaligned #{misaligned}"
      if matches != old_matches || misaligned != old_misaligned
        inferred_ranges.delete_at(k)
        inferred_ranges.delete_at(k)
        break
      end
      #puts misaligned
    end
  end

  inferred_ranges.each_with_index do |i1, k|
    next unless k.even?
    i2 = inferred_ranges[k+1]
    misaligned += i2-i1
    sides << "none"
  end
  if matches < 0 || misaligned < 0
    puts matches
    puts misaligned
    exit
  end
  $logger.debug("SIDES #{sides}")
  [matches, misaligned, sides]
end

def fix_cigar(t_nums,t_letters,i_nums,i_letters)
  $logger.debug t_nums.join("T")
  $logger.debug t_letters.join("T")
  $logger.debug i_nums.join("I")
  $logger.debug i_letters.join("I")
  t_nums.each_with_index do |t_num, i|
    next if t_num == i_nums[i]
    case t_letters[i]
    when 'M'
      if ['N','I','D'].include?(t_letters[i+1])
        if t_nums[i+1] == i_nums[i+1] && i_nums[i+2] && (i_nums[i]-t_num).abs == (i_nums[i+2]-t_nums[i+2]).abs
          i_nums[i] = t_num
          i_nums[i+2] = t_nums[i+2]
        end
      end
    end
  end
  $logger.debug "LALA"
  $logger.debug t_nums.join("T")
  $logger.debug t_letters.join("T")
  $logger.debug i_nums.join("I")
  $logger.debug i_letters.join("I")
end

# Returns [#matches, #misaligned]
#def compare_pos_count(true_pos_count, inferred_pos_count)
#  correct = 0
#  incorrect = 0
#  true_pos_count.each_with_index do |t_pos, i|
#    next unless i.even?
#    t_count = true_pos_count[i+1]
#    inferred_pos_count.each_with_index do |i_pos, k|
#      next unless k.even?
#      old_correct = correct
#      i_count = inferred_pos_count[k+1]
#      if t_pos <= i_pos &&
#      if old_correct != correct
#        inferred_pos_count.delete_at(k)
#        inferred_pos_count.delete_at(k)
#      end
#      #puts misaligned
#    end
#  end
#  inferred_pos_count.each_with_index do |i1, k|
#    next unless k.even?
#    i2 = inferred_pos_count[k+1]
#    incorrect += i2-i1
#  end
#
#  [correct, incorrect]
#end

def exists?(file)
  out = File.exist?(file) &&
  !File.zero?(file)
  raise "File #{file} does not exist or is empty!" unless out
  out
end

def comp_base_by_base(s_sam,c_cig,stats,skipping_length,skipping_binary)
  $logger.debug(s_sam.join("::"))
  $logger.debug(c_cig.join("::"))
  cig_cigar_nums = c_cig[4].split(/\D/).map { |e|  e.to_i }
  cig_cigar_letters = c_cig[4].split(/\d+/).reject { |c| c.empty? }
  sam_cigar_nums = s_sam[5].split(/\D/).map { |e|  e.to_i }
  sam_cigar_letters = s_sam[5].split(/\d+/).reject { |c| c.empty? }

  c_cig_mo = MappingObject.new()
  fill_mapping_object(c_cig_mo, c_cig[2].to_i, cig_cigar_nums, cig_cigar_letters)
  $logger.debug(c_cig_mo)
  #c_cig_mo.fix
  s_sam_mo = MappingObject.new()
  if (cig_cigar_letters & ["I","D","N"]).length > 0 && (sam_cigar_letters & ["I","D","N"]).length > 0 &&
    cig_cigar_letters == sam_cigar_letters
    # In case I, D or N is ambigous
    fix_cigar(cig_cigar_nums,cig_cigar_letters,sam_cigar_nums,sam_cigar_letters)
  end
  fill_mapping_object(s_sam_mo, s_sam[3].to_i, sam_cigar_nums, sam_cigar_letters)
  #s_sam_mo.fix
  $logger.debug(s_sam_mo)
  # How many matches?
  $logger.debug("MATCHES")
  matches_misaligned = compare_ranges(c_cig_mo.matches.flatten, s_sam_mo.matches.flatten)
  stats.total_number_of_bases_aligned_correctly += matches_misaligned[0]
  stats.total_number_of_bases_aligned_correctly_pair += matches_misaligned[0]
  stats.total_number_of_bases_aligned_incorrectly += matches_misaligned[1]
  stats.total_number_of_bases_aligned_incorrectly_pair += matches_misaligned[1]

  if matches_misaligned[0] > 0
    stats.total_number_of_reads_aligned_correctly += 1
    stats.total_number_of_reads_aligned_correctly_pair += 1
    if matches_misaligned[0] != 100
      stats.total_number_of_bases_unaligned += 100 - matches_misaligned[0]
      stats.total_number_of_bases_unaligned_pair += 100 - matches_misaligned[0]
    end
  else
    stats.total_number_of_reads_aligned_incorrectly += 1
    stats.total_number_of_reads_aligned_incorrectly_pair += 1
  end
  # Insertions
  $logger.debug("INSERTIONS")
  insertions_incorrect = compare_ranges(c_cig_mo.insertions.flatten, s_sam_mo.insertions.flatten,true)
  stats.insertions_called_correctly += insertions_incorrect[0]
  stats.total_number_of_bases_called_insertions += insertions_incorrect[1] + insertions_incorrect[0]
  stats.total_number_of_bases_aligned_incorrectly += insertions_incorrect[1]
  # Deletions
  $logger.debug("DELETIONS")
  deletions_incorrect = compare_ranges(c_cig_mo.deletions.flatten, s_sam_mo.deletions.flatten,true)
  stats.deletions_called_correctly += deletions_incorrect[0]
  stats.total_number_of_bases_called_deletions += deletions_incorrect[1] + deletions_incorrect[0]
  stats.total_number_of_bases_aligned_incorrectly += deletions_incorrect[1]
  # Skipping
  $logger.debug("SKIPPING")
  skipping_incorrect = compare_ranges(c_cig_mo.skipped.flatten, s_sam_mo.skipped.flatten)
  stats.skipping_called_correctly += skipping_incorrect[0]
  stats.total_number_of_bases_called_skipped += skipping_incorrect[1] + skipping_incorrect[0]
  $logger.debug(skipping_incorrect)
  #if skipping_incorrect[0]-skipping_length == 0 &&  skipping_incorrect[1] == 0 && skipping_incorrect[0] > 0
  #  stats.skipping_called_correctly_binary += skipping_incorrect[2].length
  #  #skipping_incorrect[2] = "both"
  #end
  #stats.total_number_of_bases_called_skipped_binary += skipping_incorrect[2].length if skipping_incorrect[0] > 0 || skipping_incorrect[1] > 0 #|| (skipping_incorrect[0]-skipping_length).abs > 10
  if  skipping_incorrect[1] > 0 || skipping_incorrect[0]  > 0
    skipping_incorrect[2].each do |e|
      stats.fill_skipping_sides(e)
      stats.skipping_called_correctly_binary += 1 if e == "both"
      stats.total_number_of_bases_called_skipped_binary += 1
    end
  end
  # How many clippings?
  #$logger.debug("CLIPPING")
  #unaligned = compare_ranges(c_cig_mo.unaligned.flatten, s_sam_mo.unaligned.flatten)
  #$logger.debug(unaligned.join(",,,"))
  #stats.total_number_of_bases_unaligned += unaligned[1]
  #stats.total_number_of_bases_aligned_incorrectly += matches_misaligned[1]
  #puts unaligned
end

def process(current_group, cig_group, stats,options)
  stats.total_number_of_reads += 2
  cig_group.each do |l|
    multi = false
    multi1 = false
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
    k = l[4].dup
    skipping = 0
    skipping_binary = 0
    while k =~ /(\d+)N/
      skipping = skipping+$1.to_i
      skipping_binary += 1
      k.sub!(/(\d+)N/,"")
    end
    stats.total_number_of_bases_in_true_skipping += skipping
    if skipping > 0
      stats.total_number_of_bases_in_true_skipping_binary += skipping_binary
      stats.total_number_of_reads_in_true_skipping_binary += 1
    end
    stats.total_number_of_bases_of_reads += options[:read_length]
    if current_group.length > 2
      ##### HERE MULTIMAPPER ROUTINE!
      multi1 = true
      stats.total_number_of_bases_aligned_ambiguously += 2*options[:read_length]
      stats.total_number_of_reads_aligned_ambiguously += 2
      stats.total_number_of_bases_aligned_ambiguously_pair += 2*options[:read_length]
      stats.total_number_of_reads_aligned_ambiguously_pair += 2
      current_group, multi = find_best_match(current_group,cig_group)
    end
    current_group.each do |s|
      s = s.split("\t")
      next unless l[0] == s[0]
      if s[2] == "*" || s[5] == "*"
        stats.total_number_of_bases_unaligned += options[:read_length]
        stats.total_number_of_reads_unaligned += 1
        stats.total_number_of_bases_unaligned_pair += options[:read_length] unless multi1
        stats.total_number_of_reads_unaligned_pair += 1 unless multi1
      else
        if s[2] != l[1]
          stats.total_number_of_bases_aligned_incorrectly += options[:read_length]
          stats.total_number_of_reads_aligned_incorrectly += 1
          stats.total_number_of_bases_aligned_incorrectly_pair += options[:read_length] unless multi
          stats.total_number_of_reads_aligned_incorrectly_pair += 1 unless multi
        else
          if s[3] == l[2] && s[5] == l[4]
            stats.total_number_of_bases_aligned_correctly += options[:read_length]
            stats.total_number_of_bases_aligned_correctly_pair += options[:read_length]
            stats.insertions_called_correctly += inserts
            stats.total_number_of_bases_called_insertions += inserts
            stats.deletions_called_correctly += deletions
            stats.total_number_of_bases_called_deletions += deletions
            stats.skipping_called_correctly += skipping
            stats.total_number_of_bases_called_skipped += skipping
            #if skipping > 0
            stats.skipping_called_correctly_binary += skipping_binary
            stats.total_number_of_bases_called_skipped_binary += skipping_binary
            stats.fill_skipping_sides("both",skipping_binary)
            #end
            stats.total_number_of_reads_aligned_correctly += 1
            stats.total_number_of_reads_aligned_correctly_pair += 1
          else
            $logger.debug("SKIPPING_LENGTH #{skipping}")
            comp_base_by_base(s,l,stats,skipping,skipping_binary)
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
  count = 0
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
      count += 1
      if (count % 50000 == 0)
        STDERR.puts "finished #{count} reads"
      end
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
  truth_cig = argv[0] if exists?(argv[0])
  sam_file = argv[1] if exists?(argv[1])
  $logger.info("Options are #{options}")

  files_valid?(truth_cig,sam_file,options)
  stats = compare(truth_cig, sam_file, options)
  $logger.info(stats)
  puts stats.process()

  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end
