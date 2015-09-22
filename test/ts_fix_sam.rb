require_relative "../fix_sam"
require "test/unit"

class TestFixSam < Test::Unit::TestCase

  def test_simple
    assert_equal(4, 4 )
    assert_equal(6, 6 )
  end

  def run_with(sam,num,solution)
    arguments = [sam,"-n",num]
    orig_std_out = STDOUT.clone
    l = STDOUT.reopen(File.open('outfile', 'w+'))
    run_all(arguments)
    STDOUT.reopen(orig_std_out)
    #File.open("outfile", "w") { |io| io.puts stats.process_old}
    diff = `diff outfile #{solution}`
    assert_equal("",diff)
    assert_equal(0,$?.to_i)
    `rm outfile`
  end

  def test_context
    run_with("test_files/context.sam",
      "20",
      "test_files/context_out.sam")
  end

  def test_hisat
    run_with("test_files/hisat.sam",
      "72",
      "test_files/hisat_out.sam")
  end

  def test_get_name()
    l = get_name("seq.31a")
    assert_equal("seq.31",l)
  end


end