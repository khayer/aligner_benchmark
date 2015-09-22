require_relative "../compare2truth"
require "test/unit"

class TestCompare2Truth < Test::Unit::TestCase

  def test_simple
    assert_equal(4, 4 )
    assert_equal(6, 6 )
  end

  def run_with(cig, sam, solution)
    argv = [cig,sam]
    options = setup_options(argv)
    truth_cig = argv[0]
    sam_file = argv[1]
    files_valid?(truth_cig,sam_file,options)
    stats = compare(truth_cig, sam_file, options)
    File.open("outfile", "w") { |io| io.puts stats.process_old}
    diff = `diff outfile #{solution}`
    assert_equal("",diff)
    assert_equal(0,$?.to_i)
    `rm outfile`
  end

  def test_1_sam
    run_with("test_files/compare2truth2015/1.cig",
      "test_files/compare2truth2015/1.sam",
      "test_files/compare2truth2015/1.solution")
  end

  def test_10_sam
    run_with("test_files/compare2truth2015/10.cig",
      "test_files/compare2truth2015/10.sam",
      "test_files/compare2truth2015/10.solution")
  end

  def test_1K_sam
    run_with("test_files/compare2truth2015/1K.cig",
      "test_files/compare2truth2015/1K.sam",
      "test_files/compare2truth2015/1K.solution")
  end

  def test_1S_sam
    run_with("test_files/compare2truth2015/1S.cig",
      "test_files/compare2truth2015/1S.sam",
      "test_files/compare2truth2015/1S.solution")
  end

  def test_20_sam
    run_with("test_files/compare2truth2015/20.cig",
      "test_files/compare2truth2015/20.sam",
      "test_files/compare2truth2015/20.solution")
  end

  def test_seq11_sam
    run_with("test_files/compare2truth2015/seq11.cig",
      "test_files/compare2truth2015/seq11.sam",
      "test_files/compare2truth2015/seq11.solution")
  end

  def test_seq21_sam
    run_with("test_files/compare2truth2015/seq21.cig",
      "test_files/compare2truth2015/seq21.sam",
      "test_files/compare2truth2015/seq21.solution")
  end

  def test_seq22_sam
    run_with("test_files/compare2truth2015/seq22.cig",
      "test_files/compare2truth2015/seq22.sam",
      "test_files/compare2truth2015/seq22.solution")
  end

end