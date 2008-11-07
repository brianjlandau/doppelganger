require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerTest < DoppelgangerTestCase
  
  context 'normal analysis' do
    should "identify duplication" do
      assert @test_data_analysis.duplication?
      assert @classes_modules_analysis.duplication?
    end
    
    should "return no false positives when identifying duplication" do
      analysis = Doppelganger::Analyzer.new("test/non_duplicating_data")
      assert !analysis.duplication?
    end
    
    should "extract :defn nodes" do
      method_arrays = @test_data_analysis.method_definitions.map {|mdef| mdef.node.to_a}
      assert_contains method_arrays, @the_nodes[0]
      assert_contains method_arrays, @the_nodes[1]
      method_arrays = @classes_modules_analysis.method_definitions.map {|mdef| mdef.node.to_a}
      assert_contains method_arrays, @the_nodes[0]
      assert_contains method_arrays, @the_nodes[1]
    end
    
    should "isolate duplicated blocks" do
      assert_equal Doppelganger::View.to_ruby(@test_data_analysis.duplicates.map(&:first)), @duplicated_block
      assert_equal Doppelganger::View.to_ruby(@classes_modules_analysis.duplicates.map(&:first)), @duplicated_block
    end
    
    should "reports unique code" do
      test_data_unique_results = Doppelganger::View.to_ruby(@test_data_analysis.unique)
      classes_modules_unique_results = Doppelganger::View.to_ruby(@classes_modules_analysis.unique)
      @unique_block.each do |method|
        assert_match %r[#{Regexp.escape(method)}], test_data_unique_results
        assert_match %r[#{Regexp.escape(method)}], classes_modules_unique_results
      end
    end
    
    should "attaches filenames to individual nodes" do
      analysis = Doppelganger::Analyzer.new("test/two_node_diff")
      assert_equal analysis.method_definitions[0].filename, File.expand_path("test/two_node_diff/first_file.rb")
    end
  end
  
  context 'doing diff anlaysis' do
    setup do
      @small_diff_analysis = Doppelganger::Analyzer.new("test/one_node_diff")
      @two_node_analysis = Doppelganger::Analyzer.new("test/two_node_diff")
      @larger_analysis = Doppelganger::Analyzer.new("test/larger_diff")
    end
    
    should "report methods which differ only by one node" do
      one_node_diff_results = Doppelganger::View.to_ruby(@small_diff_analysis.diff(1).first)
      @one_node_diff_block.each do |method|
        assert_match %r[#{Regexp.escape(method)}], one_node_diff_results
      end
    end

    should "report methods which differ by arbitrary numbers of nodes" do
      assert !@two_node_analysis.method_definitions.empty?
      two_node_diff_results = Doppelganger::View.to_ruby(@two_node_analysis.diff(2).first)
      @two_node_diff_block.each do |method|
        assert_match %r[#{Regexp.escape(method)}], two_node_diff_results
      end
    end

    should "report larger methods with larger number of diffs" do
      diff = @larger_analysis.diff(5)
      larger_diff_results = Doppelganger::View.to_ruby(diff.first)
      @bigger_diff_blocks.each do |method|
        assert_match %r[#{Regexp.escape(method)}], larger_diff_results
      end
    end

    should "report similar methods by a percent different threshold" do
      diff = @larger_analysis.percent_diff(25)
      percent_diff_results = Doppelganger::View.to_ruby(diff.first)
      @bigger_diff_blocks.each do |method|
        assert_match %r[#{Regexp.escape(method)}], percent_diff_results
      end
    end
    
    teardown do
      @small_diff_analysis, @two_node_analysis, @larger_analysis = nil
    end
  end
  
end

