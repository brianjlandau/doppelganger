require 'lib/towelie'

describe Towelie do
  before(:each) do
    @the_nodes = [
                  # second_file.rb
                  [:defn, :foo, [:args],
                    [:scope,
                      [:block, [:str, "still unique"]]]],
                  [:defn, :bar, [:args],
                    [:scope,
                      [:block, [:str, "something non-unique"]]]],
                  [:defn, :baz, [:args],
                    [:scope,
                      [:block, [:str, "also unique"]]]],

                  # first_file.rb
                  [:defn, :foo, [:args],
                    [:scope,
                      [:block, [:str, "something unique"]]]],
                  [:defn, :bar, [:args],
                    [:scope,
                      [:block, [:str, "something non-unique"]]]]
                 ]
    
    @duplicated_block =<<DUPLICATE_BLOCK
def bar
  "something non-unique"
end

DUPLICATE_BLOCK

    @unique_block = [
'def foo
  "still unique"
end',
'def baz
  "also unique"
end',
'def foo
  "something unique"
end'
    ]
    
    @homonym_block = [
'def foo
  "still unique"
end',
'def foo
  "something unique"
end'
    ]

    @one_node_diff_block = [
'def bar
  "bar"
end',
'def foo
  "foo"
end'
    ]

    @bigger_one_node_diff_block = [
'def bar
  puts("muppetfuckers")
  @variable = "bar"
end',
'def foo
  puts("muppetfuckers")
  @variable = "foo"
end'
    ]

    @two_node_diff_block = [
'def bar
  puts("muppetfuckers")
  @variable = "bar"
end',
'def foo
  puts("muppetphuckers")
  @variable = "foo"
end'
    ]
    
    @test_data_analysis = Towelie::Analyzer.new("spec/test_data")
    @classes_modules_analysis = Towelie::Analyzer.new("spec/classes_modules")
  end
  
  it "identifies duplication" do
    @test_data_analysis.duplication?.should be_true
    @classes_modules_analysis.duplication?.should be_true
  end
  
  it "returns no false positives when identifying duplication" do
    analysis = Towelie::Analyzer.new("spec/non_duplicating_data")
    analysis.duplication?.should be_false
  end
  
  it "extracts :defn nodes" do
    method_arrays = @test_data_analysis.method_definitions.map {|mdef| mdef.node.to_a}
    method_arrays.should include @the_nodes[0]
    method_arrays.should include @the_nodes[1]
    method_arrays = @classes_modules_analysis.method_definitions.map {|mdef| mdef.node.to_a}
    method_arrays.should include @the_nodes[0]
    method_arrays.should include @the_nodes[1]
  end
  
  it "isolates duplicated blocks" do
    Towelie::View.to_ruby(@test_data_analysis.duplicates.map(&:first)).should == @duplicated_block
    Towelie::View.to_ruby(@classes_modules_analysis.duplicates.map(&:first)).should == @duplicated_block
  end
  
  it "reports unique code" do
    test_data_unique_results = Towelie::View.to_ruby(@test_data_analysis.unique)
    classes_modules_unique_results = Towelie::View.to_ruby(@classes_modules_analysis.unique)
    @unique_block.each do |method|
      test_data_unique_results.should match %r[#{Regexp.escape(method)}]
      classes_modules_unique_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  
  it "reports distinct methods with the same name" do
    test_data_homonym_results = Towelie::View.to_ruby(@test_data_analysis.homonyms)
    classes_modules_homonym_results = Towelie::View.to_ruby(@classes_modules_analysis.homonyms)
    @homonym_block.each do |method|
      test_data_homonym_results.should match %r[#{Regexp.escape(method)}]
      classes_modules_homonym_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  
  it "reports methods which differ only by one node" do
    diff_analysis = Towelie::Analyzer.new("spec/one_node_diff")
    one_node_diff_results = Towelie::View.to_ruby(diff_analysis.diff(1).first)
    @one_node_diff_block.each do |method|
      one_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
    larger_analysis = Towelie::Analyzer.new("spec/larger_one_node_diff")
    larger_one_node_diff_results = Towelie::View.to_ruby(larger_analysis.diff(1).first)
    @bigger_one_node_diff_block.each do |method|
      larger_one_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  
  it "reports methods which differ by arbitrary numbers of nodes" do
    analysis = Towelie::Analyzer.new("spec/two_node_diff")
    analysis.method_definitions.should_not be_empty
    two_node_diff_results = Towelie::View.to_ruby(analysis.diff(2).first)
    @two_node_diff_block.each do |method|
      two_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  
  it "attaches filenames to individual nodes" do
    analysis = Towelie::Analyzer.new("spec/two_node_diff")
    analysis.method_definitions[0].filename.should == File.expand_path("spec/two_node_diff/first_file.rb")
  end
  
  after(:each) do
    @the_nodes, @duplicated_block, @unique_block, @homonym_block, @one_node_diff_block, @bigger_one_node_diff_block, 
      @two_node_diff_block, @test_data_analysis, @classes_modules_analysis = nil
  end
end
