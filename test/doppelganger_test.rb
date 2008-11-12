require File.dirname(__FILE__) + '/test_helper'

class DoppelgangerTest < DoppelgangerTestCase
  
  context 'normal analysis' do
    should "identify duplication" do
      assert @duplicate_analysis.duplication?
    end
    
    should "return no false positives when identifying duplication" do
      analysis = Doppelganger::Analyzer.new("test/sample_files/non_duplicating_data")
      assert !analysis.duplication?
    end
    
    should "extract :defn nodes" do
      method_arrays = @duplicate_analysis.sexp_blocks.map {|mdef| mdef.node.to_a}
      @the_nodes.each do |node|
        assert_contains method_arrays, node
      end
    end
    
    should "isolate duplicated blocks" do
      duplicate_node_arrays = @duplicate_analysis.duplicates.inject([]) do |flattend_dups, dups|
        flattend_dups << dups.first.node.to_a
        flattend_dups << dups.last.node.to_a
        flattend_dups
      end
      assert_contains duplicate_node_arrays, @the_nodes[0]
      assert_contains duplicate_node_arrays, @the_nodes[3]
    end
    
    should "attaches filenames to individual nodes" do
      @duplicate_analysis.sexp_blocks.each do |mdef|
        assert_match /\/\w+_file\.rb$/, mdef.filename
      end
    end
    
    should "attaches line numbers to individual nodes" do
      @duplicate_analysis.sexp_blocks.each do |mdef|
        assert_kind_of Integer, mdef.line
      end
    end
  end
  
  context 'doing diff anlaysis' do
    setup do
      @larger_diff_analysis = Doppelganger::Analyzer.new("test/sample_files/larger_diff")
    end
  
    should "report methods which differ by arbitrary numbers of diffs" do
      diff = @larger_diff_analysis.diff(5)
      larger_diff_results = diff.inject([]) do |flattend_diffs, diff_pairs|
        flattend_diffs << diff_pairs.first.node.to_a
        flattend_diffs << diff_pairs.last.node.to_a
        flattend_diffs
      end
      
      @bigger_diff_blocks.each do |method_node|
        assert_contains larger_diff_results, method_node
      end
    end
  
    should "report similar methods by a percent different threshold" do
      diff = @larger_diff_analysis.percent_diff(25)
      percent_diff_results = diff.inject([]) do |flattend_diffs, diff_pairs|
        flattend_diffs << diff_pairs.first.node.to_a
        flattend_diffs << diff_pairs.last.node.to_a
        flattend_diffs
      end
      
      @bigger_diff_blocks.each do |method_node|
        assert_contains percent_diff_results, method_node
      end
    end
    
    teardown do
      @larger_analysis = nil
    end
  end
  
  context "percent diff analysis" do
    setup do
      repeats_removal_file_path = File.expand_path(File.join(File.dirname(__FILE__), 'sample_files/repeats_removal_sample_file.rb'))
      @repeats_removal_analysis = Doppelganger::Analyzer.new(repeats_removal_file_path)
      @repeats_diff = @repeats_removal_analysis.percent_diff(10)
      @analysis_nodes = @repeats_diff.map {|pair|
        [pair.first.node, pair.last.node]
      }
    end
    
    should 'ensure that repeated smaller nested nodes are noth included' do
      @repeated_pairs.each do |pair|
        assert !(@analysis_nodes.any? { |node_pair|
          (node_pair.include?(pair.first.node) && node_pair.include?(pair.last.node))
        })
      end
    end
    
    teardown do
      @repeats_removal_analysis, @analysis_nodes = nil
    end
  end
  
end

