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
    @total_number_of_reads = 0
    @total_number_of_bases_aligned_correctly = 0
    @total_number_of_reads_aligned_correctly = 0
    @total_number_of_bases_aligned_incorrectly = 0
    @total_number_of_reads_aligned_incorrectly = 0
    @total_number_of_bases_aligned_ambiguously = 0
    @total_number_of_bases_unaligned = 0
    @total_number_of_reads_unaligned = 0
    @total_number_of_bases_in_true_insertions = 0
    @total_number_of_bases_in_true_deletions = 0
    @total_number_of_bases_in_true_skipping = 0
    @total_number_of_bases_called_insertions = 0
    @total_number_of_bases_called_deletions = 0
    @total_number_of_bases_called_skipped = 0
    @insertions_called_correctly = 0
    @deletions_called_correctly = 0
    @skipping_called_correctly = 0
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
    :total_number_of_bases_in_true_insertions,
    :total_number_of_bases_in_true_deletions,
    :total_number_of_bases_in_true_skipping,
    :total_number_of_bases_called_insertions,
    :total_number_of_bases_called_deletions,
    :total_number_of_bases_called_skipped,
    :insertions_called_correctly,
    :deletions_called_correctly,
    :skipping_called_correctly

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
total_number_of_bases_called_insertions: #{@total_number_of_bases_called_insertions}
total_number_of_bases_called_deletions: #{@total_number_of_bases_called_deletions}
total_number_of_bases_called_skipped: #{@total_number_of_bases_called_skipped}
insertions_called_correctly: #{@insertions_called_correctly}
deletions_called_correctly: #{@deletions_called_correctly}
skipping_called_correctly: #{@skipping_called_correctly}}
  end

  def process
    # READ LEVEL
    puts "--------------------------------------"
    puts "total_number_of_reads = #{@total_number_of_reads}"
    percent_reads_aligned_correctly = (@total_number_of_reads_aligned_correctly.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    puts "accuracy over all reads: #{percent_reads_aligned_correctly}%"
    total_num_unique_aligners = @total_number_of_reads_aligned_correctly + @total_number_of_reads_aligned_incorrectly
    #$logger.debug("total_num_unique_aligned_reads=#{total_num_unique_aligners}")
    accuracy_on_unique_aligners = (@total_number_of_reads_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    ##print "% unique aligners correct: $accuracy_on_unique_aligners%\n";
    puts "accuracy over uniquely aligned reads: #{accuracy_on_unique_aligners}%"
    percent_reads_aligned_incorrectly = (@total_number_of_reads_aligned_incorrectly.to_f / @total_number_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    puts "% reads aligned incorrectly: #{percent_reads_aligned_incorrectly}%"
    percent_reads_aligned_ambiguously = (@total_number_of_reads_aligned_ambiguously.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    puts "% reads aligned ambiguously: #{percent_reads_aligned_ambiguously}%"
    percent_reads_unaligned = (@total_number_of_reads_unaligned.to_f / @total_number_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    puts "% reads unaligned: #{percent_reads_unaligned}%"
    percent_reads_aligned = 100 - percent_reads_unaligned
    puts "% reads aligned: #{percent_reads_aligned}%"
    # BASE LEVEL
    puts "--------------------------------------"
    puts "total_number_of_bases_of_reads = #{@total_number_of_bases_of_reads}"
    percent_bases_aligned_correctly = (@total_number_of_bases_aligned_correctly.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    puts "accuracy over all bases: #{percent_bases_aligned_correctly}%";
    total_num_unique_aligners = @total_number_of_bases_aligned_correctly + @total_number_of_bases_aligned_incorrectly
    $logger.debug("total_num_unique_aligners=#{total_num_unique_aligners}")
    accuracy_on_unique_aligners = (@total_number_of_bases_aligned_correctly.to_f / total_num_unique_aligners.to_f * 10000).to_i / 100.0
    ##print "% unique aligners correct: $accuracy_on_unique_aligners%\n";
    puts "accuracy over uniquely aligned bases: #{accuracy_on_unique_aligners}%"
    percent_bases_aligned_incorrectly = (@total_number_of_bases_aligned_incorrectly.to_f / @total_number_of_bases_of_reads.to_f * 10000.0).to_i / 100.0
    ##print "total_number_of_bases_aligned_incorrectly = $total_number_of_bases_aligned_incorrectly\n";
    puts "% bases aligned incorrectly: #{percent_bases_aligned_incorrectly}%"
    percent_bases_aligned_ambiguously = (@total_number_of_bases_aligned_ambiguously.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_aligned_ambiguously = $total_number_of_bases_aligned_ambiguously\n";
    puts "% bases aligned ambiguously: #{percent_bases_aligned_ambiguously}%"
    percent_bases_unaligned = (@total_number_of_bases_unaligned.to_f / @total_number_of_bases_of_reads.to_f * 10000).to_i / 100.0
    ##print "total_number_of_bases_unaligned = $total_number_of_bases_unaligned\n";
    puts "% bases unaligned: #{percent_bases_unaligned}%"
    percent_bases_aligned = 100 - percent_bases_unaligned
    puts "% bases aligned: #{percent_bases_aligned}%"
    #puts "number of bases in true insertions = #{@total_number_of_bases_in_true_insertions}"
    insertion_rate = (@total_number_of_bases_in_true_insertions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    puts "% of bases in true insertions: #{insertion_rate}%"
    deletion_rate = (@total_number_of_bases_in_true_deletions.to_f / @total_number_of_bases_of_reads.to_f * 1000000).to_i / 10000.0
    puts "% of bases in true deletions: #{deletion_rate}%"

    # INSERTIONS DELETIONS SKIPPING
    puts "--------------------------------------"
    if(@total_number_of_bases_in_true_insertions==0)
      puts "insertions FN/FD rate: No insertions exist in true data."
    else
      if(@total_number_of_bases_called_insertions>0)
        #false_discovery_rate
        insertions_false_discovery_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_called_insertions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        puts "insertions FD rate: #{insertions_false_discovery_rate}%"
      else
        puts "insertions FD rate: 0% (no insertions called)"
      end
      #false_negative_rate
      insertions_false_negative_rate = ((1 - (@insertions_called_correctly.to_f / @total_number_of_bases_in_true_insertions.to_f * 10000).to_i / 10000.0) * 100* 10000).to_i/10000.0
      puts "insertions FN rate: #{insertions_false_negative_rate}%"
    end

    if(@total_number_of_bases_in_true_deletions==0)
      puts "deletions FN/FD rate: No deletions exist in true data."
    else
      if(@total_number_of_bases_called_deletions>0)
        #false_discovery_rate
        deletions_false_discovery_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_called_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        puts "deletions FD rate: #{deletions_false_discovery_rate}%"
      else
        puts "deletions FD rate: 0% (no deletions called)"
      end
      #false_negative_rate
      deletions_false_negative_rate = ((1 - (@deletions_called_correctly.to_f / @total_number_of_bases_in_true_deletions.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      puts "deletions FN rate: #{deletions_false_negative_rate}%"
    end

    if(@total_number_of_bases_in_true_skipping==0)
      puts "skipping FN/FD rate: No skipping exist in true data."
    else
      if(@total_number_of_bases_called_skipped>0)
        #false_discovery_rate
        skipping_false_discovery_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_called_skipped.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
        puts "skipping FD rate: #{skipping_false_discovery_rate}%"
      else
        puts "skipping FD rate: 0% (no skipping called)"
      end
      #false_negative_rate
      skipping_false_negative_rate = ((1 - (@skipping_called_correctly.to_f / @total_number_of_bases_in_true_skipping.to_f * 10000).to_i / 10000.0) * 100 * 10000).to_i/10000.0
      puts "skipping FN rate: #{skipping_false_negative_rate}%"
    end
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

def fill_mapping_object(mo, start, cigar_nums, cigar_letters)
  current_pos = start
  add = 0
  cigar_nums.each_with_index do |num,i|
    case cigar_letters[i]
    when "M"
      mo.matches << [current_pos, current_pos + num + add]
      current_pos += num
      add = 0
    when "I"
      mo.insertions << [current_pos, current_pos + num]
      add = num
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

# Returns [#matches,#misaligned]
def compare_ranges(true_ranges, inferred_ranges)
  matches = 0
  misaligned = 0
  true_ranges.each_with_index do |t1, i|
    next unless i.even?
    t2 = true_ranges[i+1]
    inferred_ranges.each_with_index do |i1, k|
      next unless k.even?
      old_matches = matches
      i2 = inferred_ranges[k+1]
      if t1 <= i1 && t2 >= i2
        matches += (i2 - i1)
      elsif t1 <= i1 && i1 < t2 && t2 <= i2
        matches += (t2 - i1)
        misaligned += i2 - t2
      elsif t1 >= i1  && t2 <= i2
        matches += (t2 - t1)
        misaligned += (i2 - t2) + (t1 - i1)
      elsif t1 >= i1  && t2 >= i2 && t1 < i2
        matches += (i2 - t1)
        misaligned += (t1 - i1)
      end
      #puts "Matches #{matches}"
      #puts "Misaligned #{misaligned}"
      if matches != old_matches
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
  end
  if matches < 0 || misaligned < 0
    puts matches
    puts misaligned
    exit
  end
  [matches, misaligned]
end

def fix_cigar(t_nums,t_letters,i_nums,i_letters)
  #puts t_nums.join("T")
  #puts t_letters.join("T")
  #puts i_nums.join("I")
  #puts i_letters.join("I")
  t_nums.each_with_index do |t_num, i|
    next if t_num == i_nums[i]
    case t_letters[i]
    when 'M'
      if ['N','I','D'].include?(t_letters[i+1])
        if t_nums[i+1] == i_nums[i+1] && (i_nums[i]-t_num).abs == (i_nums[i+2]-t_nums[i+2]).abs
          i_nums[i] = t_num
          i_nums[i+2] = t_nums[i+2]
        end
      end
    end
  end
  #puts "LALA"
  #puts t_nums.join("T")
  #puts t_letters.join("T")
  #puts i_nums.join("I")
  #puts i_letters.join("I")
end

# Returns [#matches,#misaligned]
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

def comp_base_by_base(s_sam,c_cig,stats)
  $logger.debug(s_sam.join("::"))
  $logger.debug(c_cig.join("::"))
  cig_cigar_nums = c_cig[4].split(/\D/).map { |e|  e.to_i }
  cig_cigar_letters = c_cig[4].split(/\d+/).reject { |c| c.empty? }
  sam_cigar_nums = s_sam[5].split(/\D/).map { |e|  e.to_i }
  sam_cigar_letters = s_sam[5].split(/\d+/).reject { |c| c.empty? }

  c_cig_mo = MappingObject.new()
  fill_mapping_object(c_cig_mo, c_cig[2].to_i, cig_cigar_nums, cig_cigar_letters)
  $logger.debug(c_cig_mo)

  s_sam_mo = MappingObject.new()
  if (cig_cigar_letters & ["I","D","N"]).length > 0 && (sam_cigar_letters & ["I","D","N"]).length > 0 &&
    cig_cigar_letters == sam_cigar_letters
    # In case I, D or N is ambigous
    fix_cigar(cig_cigar_nums,cig_cigar_letters,sam_cigar_nums,sam_cigar_letters)
  end
  fill_mapping_object(s_sam_mo, s_sam[3].to_i, sam_cigar_nums, sam_cigar_letters)
  $logger.debug(s_sam_mo)
  # How many matches?
  $logger.debug("MATCHES")
  matches_misaligned = compare_ranges(c_cig_mo.matches.flatten, s_sam_mo.matches.flatten)
  stats.total_number_of_bases_aligned_correctly += matches_misaligned[0]
  stats.total_number_of_bases_aligned_incorrectly += matches_misaligned[1]

  if matches_misaligned[0] > 0
    stats.total_number_of_reads_aligned_correctly += 1
  else
    stats.total_number_of_reads_aligned_incorrectly += 1
  end
  # Insertions
  $logger.debug("INSERTIONS")
  insertions_incorrect = compare_ranges(c_cig_mo.insertions.flatten, s_sam_mo.insertions.flatten)
  stats.insertions_called_correctly += insertions_incorrect[0]
  stats.total_number_of_bases_called_insertions += insertions_incorrect[1] + insertions_incorrect[0]
  # Deletions
  $logger.debug("DELETIONS")
  deletions_incorrect = compare_ranges(c_cig_mo.deletions.flatten, s_sam_mo.deletions.flatten)
  stats.deletions_called_correctly += deletions_incorrect[0]
  stats.total_number_of_bases_called_deletions += deletions_incorrect[1] + deletions_incorrect[0]
  # Skipping
  $logger.debug("SKIPPING")
  skipping_incorrect = compare_ranges(c_cig_mo.skipped.flatten, s_sam_mo.skipped.flatten)
  stats.skipping_called_correctly += skipping_incorrect[0]
  stats.total_number_of_bases_called_skipped += skipping_incorrect[1] + skipping_incorrect[0]
  # How many clippings?
  $logger.debug("CLIPPING")
  unaligned = compare_ranges(c_cig_mo.unaligned.flatten, s_sam_mo.unaligned.flatten)
  stats.total_number_of_bases_unaligned += unaligned[1]
  #stats.total_number_of_bases_aligned_incorrectly += matches_misaligned[1]
  #puts unaligned
end

def process(current_group, cig_group, stats,options)
  stats.total_number_of_reads += 2
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
    k = l[4].dup
    skipping = 0
    while k =~ /(\d+)N/
      skipping = skipping+$1.to_i
      k.sub!(/(\d+)N/,"")
    end
    stats.total_number_of_bases_in_true_skipping += skipping
    stats.total_number_of_bases_of_reads += options[:read_length]
    if current_group.length > 2
      stats.total_number_of_bases_aligned_ambiguously += options[:read_length]
    else
      current_group.each do |s|
        s = s.split("\t")
        next unless l[0] == s[0]
        if s[2] == "*"
          stats.total_number_of_bases_unaligned += options[:read_length]
          stats.total_number_of_reads_unaligned += 1
        else
          if s[2] != l[1]
            stats.total_number_of_bases_aligned_incorrectly += options[:read_length]
            stats.total_number_of_reads_aligned_incorrectly += 1
          else
            if s[3] == l[2] && s[5] == l[4]
              stats.total_number_of_bases_aligned_correctly += options[:read_length]
              stats.insertions_called_correctly += inserts
              stats.total_number_of_bases_called_insertions += inserts
              stats.deletions_called_correctly += deletions
              stats.total_number_of_bases_called_deletions += deletions
              stats.skipping_called_correctly += skipping
              stats.total_number_of_bases_called_skipped += skipping
              stats.total_number_of_reads_aligned_correctly += 1
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
  count = 0
  while !sam_file_handler.eof?
    count += 1
    if (count % 50000 == 0)
      STDERR.puts "finished #{count} reads"
    end
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
  puts stats
  stats.process()

  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end
