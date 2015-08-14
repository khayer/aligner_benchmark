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
$algorithms = [:contextmap2,
      :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
      :star, :subread, :tophat2]

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
    opts.banner = "\nUsage: ruby master.rb [options] dataset source_of_tree"
    opts.separator ""
    opts.separator "e.g. dataset = t3r1"
    opts.separator "e.g. source_of_tree = /project/itmatlab/aligner_benchmark"
    opts.separator ""
    # enumeration
    opts.on('-a', '--algorithm ENUM', [:all, :contextmap2,
      :crac, :gsnap, :hisat, :mapsplice2, :olego, :rum,
      :star, :subread, :tophat2],'Choose from below:','all: DEFAULT',
      'contextmap2','crac','gsnap','hisat', 'mapsplice2',
      'olego','rum','star','subread','tophat2') do |v|
      options[:algorithm] = v
    end

    opts.on("-d", "--debug", "Run in debug mode") do |v|
      options[:log_level] = "debug"
      options[:debug] = true
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

class Job
  def initialize(jobnumber, cmd, status, working_dir)
    @jobnumber = jobnumber
    @cmd = cmd
    @status = status
    @working_dir = working_dir
  end

  attr_accessor :jobnumber, :cmd, :status

  def to_s
    "Jobnumber #{@jobnumber}; Cmd: #{@cmd}; Status: #{@status}; WD: #{@working_dir}"
  end

  def update_status
    begin
      l = `bjobs -l #{@jobnumber}`
    rescue Exception => e
      $logger.error(e)
      $logger.error("bjobs not found!\n#{self}")
      @status = "EXIT"
      return
    end
    # if @status == "EXIT"
    l.chomp!
    if l == ""
      $logger.error("Jobnumber #{@jobnumber} not found! #{self}")
      @status = "EXIT"
    else
      l = l.delete(" \n")
      @status = l.split("Status")[1].split(",")[0].gsub(/\W/,"")
    end
  end

end

def check_if_results_exist(stats_path)
  File.exist?("#{stats_path}/comp_res.txt") && File.exist?("#{stats_path}/junctions_stats.txt")
end

def get_truth_files(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/jobs/settings/ -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  dir = nil
  File.open(l).each do |line|
    line.chomp!.delete!("\"")
    fields = line.split("=")
    case fields[0]
    when "READS_PATH"
      dir = fields[1]
    when "CIG_FILE"
      options[:cig_file] = "#{dir}/#{fields[1]}"
    when "TRANSCRIPTS"
      options[:transcripts] = "#{dir}/#{fields[1]}"
    when "JUNCTIONS_CROSSED"
      options[:junctions_crossed] = "#{dir}/#{fields[1]}"
    end
  end
  unless (options[:junctions_crossed] && options[:transcripts] && options[:cig_file])
    $logger.error "Trouble finding truth files in settings at #{l}"
    raise "Can't find all truth files!"
  end
  $logger.debug(options)
end

def monitor_jobs(jobs)
  while jobs.length > 0
    sleep(5)
    jobs.each_with_index do |job,i|
      job.update_status()
      case job.status
      when "DONE"
        $logger.info("SUCCESS #{job}")
        jobs.delete_at(i)
      when "EXIT"
        $logger.error("FAILED #{job}")
        jobs.delete_at(i)
      end
    end

  end
  #TODO
end

def submit(cmd, options)
  if options[:debug]
    $logger.debug("In submit: #{cmd}")
    return 1234
  else
    begin
      l = `#{cmd}`
    rescue Exception => e
      $logger.error(e)
      $logger.error("bsub not found!#{cmd}")
      return 1
    end
    num = l.split(/\W/)[2].to_i
  end
  num
end

def clean_files(path)

end

def run_contextmap2(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/contextmap2/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/contextmap2.sh"))
  return unless File.exist?("#{l}/mapping.sam")
  options[:stats_path] = "#{options[:out_directory]}/contextmap2/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/contextmap2_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_crac(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/crac/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/crac.sh"))
  Dir.glob("#{l}/*").each do |p|
    if File.directory? p
      next unless File.exist?("#{p}/output.sam")
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/crac/#{p.split("/")[-1]}".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p
      shell_file = "#{options[:jobs_path]}/crac_statistics_#{options[:species]}_#{dataset}_#{p.split("/")[-1]}.sh".gsub(/[()]/,"")
    else
      next unless p =~ /output\.sam$/
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/crac/".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p.gsub(/output\.sam$/,"")
      shell_file = "#{options[:jobs_path]}/crac_statistics_#{options[:species]}_#{dataset}_default.sh"
    end

    next if check_if_results_exist(options[:stats_path])
    clean_files(options[:stats_path])

    o = File.open(shell_file,"w")
    o.puts(erubis.evaluate(options))
    o.close()
    Dir.chdir "#{options[:jobs_path]}"
    $logger.debug(Dir.pwd)
    cmd = "bsub < #{shell_file}"
    jobnumber = submit(cmd,options)
    options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  end
  $logger.debug(options[:jobs])
end

def run_gsnap(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/gsnap/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/gsnap.sh"))
  return unless File.exist?("#{l}/output.sam")
  options[:stats_path] = "#{options[:out_directory]}/gsnap/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/gsnap_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_hisat(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/hisat/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/hisat.sh"))
  return unless File.exist?("#{l}/output.sam")
  options[:stats_path] = "#{options[:out_directory]}/hisat/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/hisat_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_mapsplice2(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/mapsplice2/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/mapsplice2.sh"))
  return unless File.exist?("#{l}/alignments.sam")
  options[:stats_path] = "#{options[:out_directory]}/mapsplice2/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/mapsplice2_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_olego(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/olego/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  # = l.delete_if {|e| e =~ /denovo$/}
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/olego.sh"))
  Dir.glob("#{l}/*").each do |p|
    if File.directory? p
      next unless File.exist?("#{p}/output.#{p.split("/")[-1]}.sam")
      k = `ln -s #{p}/output.#{p.split("/")[-1]}.sam #{p}/output.sam`
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/olego/#{p.split("/")[-1]}".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p
      shell_file = "#{options[:jobs_path]}/olego_statistics_#{options[:species]}_#{dataset}_#{p.split("/")[-1]}.sh".gsub(/[()]/,"")
    else
      next unless p =~ /output.sam$/
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/olego/".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p.gsub(/\/output\.sam$/,"")
      shell_file = "#{options[:jobs_path]}/olego_statistics_#{options[:species]}_#{dataset}_default.sh"
    end

    next if check_if_results_exist(options[:stats_path])
    clean_files(options[:stats_path])

    o = File.open(shell_file,"w")
    o.puts(erubis.evaluate(options))
    o.close()
    Dir.chdir "#{options[:jobs_path]}"
    $logger.debug(Dir.pwd)
    cmd = "bsub < #{shell_file}"
    jobnumber = submit(cmd,options)
    options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  end
  $logger.debug(options[:jobs])
end

def run_rum(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/rum/alignment -maxdepth 1 -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/rum.sh"))
  return unless File.exist?("#{l}/RUM.sam")
  options[:stats_path] = "#{options[:out_directory]}/rum/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/contextmap2_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_subread(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/subread/alignment -maxdepth 1 -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/subread.sh"))
  return unless File.exist?("#{l}/ucsc.hg19") || File.exist?("#{l}/pfal")
  if File.exist?("#{l}/ucsc.hg19")
    k = `ln -s #{l}/ucsc.hg19 #{l}/output.sam`
  else
    k = `ln -s #{l}/pfal #{l}/output.sam`
  end
  options[:stats_path] = "#{options[:out_directory]}/subread/"
  begin
    Dir.mkdir(options[:stats_path])
  rescue SystemCallError
    if Dir.exist?(options[:stats_path])
      logger.warn("Directory #{options[:stats_path]} exists!")
    else
      logger.error("Can't create directory #{options[:stats_path]}!")
      raise("Trouble creating directory, log for details.")
    end
  end

  return if check_if_results_exist(options[:stats_path])
  clean_files(options[:stats_path])
  options[:tool_result_path] = l
  shell_file = "#{options[:jobs_path]}/contextmap2_statistics_#{options[:species]}_#{dataset}.sh"
  o = File.open(shell_file,"w")
  o.puts(erubis.evaluate(options))
  o.close()
  Dir.chdir "#{options[:jobs_path]}"
  $logger.debug(Dir.pwd)
  cmd = "bsub < #{shell_file}"
  jobnumber = submit(cmd,options)
  options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  $logger.debug(options[:jobs])
end

def run_star(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/star/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  l = l.delete_if {|e| e =~ /denovo$/}
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/star.sh"))
  Dir.glob("#{l}/*").each do |p|
    if File.directory? p
      cmd = "find #{p} -name \"*Aligned.out.sam\""
      $logger.debug(cmd)
      l = `#{cmd}`
      l = l.split("\n")
      raise "Trouble finding #{dataset}: #{l}" if l.length > 1
      next if l.length < 1
      l = l[0]
      next unless File.exist?("#{l}")
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/star/#{p.split("/")[-1]}".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p
      shell_file = "#{options[:jobs_path]}/star_statistics_#{options[:species]}_#{dataset}_#{p.split("/")[-1]}.sh".gsub(/[()]/,"")
    else
      next unless p =~ /Aligned\.out\.sam$/
      $logger.debug(p)
      options[:stats_path] = "#{options[:out_directory]}/star/".gsub(/[()]/,"")
      begin
        Dir.mkdir(options[:stats_path])
      rescue SystemCallError
        if Dir.exist?(options[:stats_path])
          logger.warn("Directory #{options[:stats_path]} exists!")
        else
          logger.error("Can't create directory #{options[:stats_path]}!")
          raise("Trouble creating directory, log for details.")
        end
      end
      options[:tool_result_path] = p.gsub(/\/[\.\w]*Aligned\.out\.sam$/,"")
      shell_file = "#{options[:jobs_path]}/star_statistics_#{options[:species]}_#{dataset}_default.sh"
    end

    next if check_if_results_exist(options[:stats_path])
    clean_files(options[:stats_path])

    o = File.open(shell_file,"w")
    o.puts(erubis.evaluate(options))
    o.close()
    Dir.chdir "#{options[:jobs_path]}"
    $logger.debug(Dir.pwd)
    cmd = "bsub < #{shell_file}"
    jobnumber = submit(cmd,options)
    options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  end
  $logger.debug(options[:jobs])
end

def run_tophat2(options, source_of_tree, dataset)
  cmd = "find #{source_of_tree}/tool_results/tophat2/alignment -name \"*#{options[:species]}*#{dataset}*\""
  $logger.debug(cmd)
  l = `#{cmd}`
  l = l.split("\n")
  raise "Trouble finding #{dataset}: #{l}" if l.length != 1
  l = l[0]
  erubis = Erubis::Eruby.new(File.read("#{options[:aligner_benchmark]}/templates/tophat2.sh"))
  Dir.glob("#{l}/*").each do |p|
    next unless File.directory? p
    next unless File.exist?("#{p}/unmapped.bam")
    next unless File.exist?("#{p}/accepted_hits.bam")
    $logger.debug(p)
    options[:stats_path] = "#{options[:out_directory]}/tophat2/#{p.split("/")[-1]}".gsub(/[()]/,"")
    begin
      Dir.mkdir(options[:stats_path])
    rescue SystemCallError
      if Dir.exist?(options[:stats_path])
        logger.warn("Directory #{options[:stats_path]} exists!")
      else
        logger.error("Can't create directory #{options[:stats_path]}!")
        raise("Trouble creating directory, log for details.")
      end
    end

    next if check_if_results_exist(options[:stats_path])
    clean_files(options[:stats_path])

    options[:tool_result_path] = p
    shell_file = "#{options[:jobs_path]}/tophat2_statistics_#{options[:species]}_#{dataset}_#{p.split("/")[-1]}.sh".gsub(/[()]/,"")
    o = File.open(shell_file,"w")
    o.puts(erubis.evaluate(options))
    o.close()
    Dir.chdir "#{options[:jobs_path]}"
    $logger.debug(Dir.pwd)
    cmd = "bsub < #{shell_file}"
    jobnumber = submit(cmd,options)
    options[:jobs] << Job.new(jobnumber, cmd, "PEND",Dir.pwd)
  end
  $logger.debug(options[:jobs])
end

def run(argv)
  options = setup_options(argv)
  dataset = argv[0]
  source_of_tree = argv[1]
  options[:aligner_benchmark] = File.expand_path(File.dirname(__FILE__))
  # Results go to
  options[:out_directory] = "#{source_of_tree}/statistics/#{options[:species]}_#{dataset}"
  begin
    Dir.mkdir(options[:out_directory])
  rescue SystemCallError
    if Dir.exist?(options[:out_directory])
      logger.warn("Directory #{options[:out_directory]} exists!")
    else
      logger.error("Can't create directory #{options[:out_directory]}!")
      raise("Trouble creating directory, log for details.")
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

  get_truth_files(options, source_of_tree, dataset)

  $logger.debug("Algorithms = #{algorithms}")
  options[:jobs] = []


  algorithms.each do |alg|
    options[:jobs_path] = "#{source_of_tree}/jobs/#{alg}"
    begin
      Dir.mkdir("#{options[:out_directory]}/#{alg}")
    rescue SystemCallError
      if Dir.exist?("#{options[:out_directory]}/#{alg}")
        logger.warn("Directory #{options[:out_directory]}/#{alg} exists!")
      else
        logger.error("Can't create directory #{options[:out_directory]}/#{alg}!")
        raise("Trouble creating directory, log for details.")
      end
    end
    case alg
    when :contextmap2
      run_contextmap2(options, source_of_tree, dataset)
    when :crac
      run_crac(options, source_of_tree, dataset)
    when :gsnap
      run_gsnap(options, source_of_tree, dataset)
    when :hisat
      run_hisat(options, source_of_tree, dataset)
    when :mapsplice2
      run_mapsplice2(options, source_of_tree, dataset)
    when :olego
      run_olego(options, source_of_tree, dataset)
    when :rum
      run_rum(options, source_of_tree, dataset)
    when :subread
      run_subread(options, source_of_tree, dataset)
    when :star
      run_star(options, source_of_tree, dataset)
    when :tophat2
      run_tophat2(options, source_of_tree, dataset)
    end
  end

  monitor_jobs(options[:jobs])
  #puts options[:cut_off]
  $logger.info("All done!")
end

if __FILE__ == $0
  run(ARGV)
end





