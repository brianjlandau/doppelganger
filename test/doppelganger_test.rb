require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerTest < DoppelgangerTestCase
  
  context 'normal analysis' do
    should "identify duplication" do
      assert @test_data_analysis.duplication?
      assert @classes_modules_analysis.duplication?
    end
    
    should "return no false positives when identifying duplication" do
      analysis = Doppelganger::Analyzer.new("test/sample_files/non_duplicating_data")
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
      test_data_duplicate_node_arrays = @test_data_analysis.duplicates.inject([]) do |flattend_dups, dups|
        flattend_dups << dups.first.node.to_a
        flattend_dups << dups.last.node.to_a
        flattend_dups
      end
      classes_modules_duplicate_node_arrays = @test_data_analysis.duplicates.inject([]) do |flattend_dups, dups|
        flattend_dups << dups.first.node.to_a
        flattend_dups << dups.last.node.to_a
        flattend_dups
      end
      assert_contains test_data_duplicate_node_arrays, @the_nodes[1]
      assert_contains classes_modules_duplicate_node_arrays, @the_nodes[1]
      assert_contains test_data_duplicate_node_arrays, @the_nodes[4]
      assert_contains classes_modules_duplicate_node_arrays, @the_nodes[4]
    end
    
    should "reports unique code" do
      test_data_unique_results = @test_data_analysis.unique.map{|m| m.node.to_a}
      classes_modules_unique_results = @classes_modules_analysis.unique.map{|m| m.node.to_a}
      @unique_block.each do |method_node|
        assert_contains test_data_unique_results, method_node
        assert_contains classes_modules_unique_results, method_node
      end
    end
    
    should "attaches filenames to individual nodes" do
      analysis = Doppelganger::Analyzer.new("test/sample_files/two_node_diff")
      assert_match /first_file\.rb$/, analysis.method_definitions[0].filename
      assert_match /second_file\.rb$/, analysis.method_definitions[1].filename
    end
    
    should "attaches line numbers to individual nodes" do
      analysis = Doppelganger::Analyzer.new("test/sample_files/two_node_diff")
      analysis.method_definitions.each do |mdef|
        assert_kind_of Integer, mdef.line
      end
    end
  end
  
  context 'doing diff anlaysis' do
    setup do
      @small_diff_analysis = Doppelganger::Analyzer.new("test/sample_files/one_node_diff")
      @two_node_analysis = Doppelganger::Analyzer.new("test/sample_files/two_node_diff")
      @larger_analysis = Doppelganger::Analyzer.new("test/sample_files/larger_diff")
    end
    
    should "report methods which differ only by one node" do
      one_node_diff_results = @small_diff_analysis.diff(1).first.map{|m| m.node.to_a}
      @one_node_diff_block.each do |method_node|
        assert_contains one_node_diff_results, method_node
      end
    end

    should "report methods which differ by arbitrary numbers of nodes" do
      assert !@two_node_analysis.method_definitions.empty?
      two_node_diff_results = @two_node_analysis.diff(2).first.map{|m| m.node.to_a}
      @two_node_diff_block.each do |method_node|
        assert_contains two_node_diff_results, method_node
      end
    end

    should "report larger methods with larger number of diffs" do
      diff = @larger_analysis.diff(5)
      larger_diff_results = diff.first.map{|m| m.node.to_a}
      @bigger_diff_blocks.each do |method_node|
        assert_contains larger_diff_results, method_node
      end
    end

    should "report similar methods by a percent different threshold" do
      diff = @larger_analysis.percent_diff(25)
      percent_diff_results = diff.first.map{|m| m.node.to_a}
      @bigger_diff_blocks.each do |method_node|
        assert_contains percent_diff_results, method_node
      end
    end
    
    teardown do
      @small_diff_analysis, @two_node_analysis, @larger_analysis = nil
    end
  end
  
end

