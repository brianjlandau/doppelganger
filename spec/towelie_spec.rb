require 'lib/towelie/array'
require 'lib/towelie'
include Towelie

describe Towelie do
  before(:all) do
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
  end
  
  it "identifies duplication" do
    duplication?("spec/test_data").should be_true
    duplication?("spec/classes_modules").should be_true
  end
  it "returns no false positives when identifying duplication" do
    duplication?("spec/non_duplicating_data").should be_false
  end
  it "extracts :defn nodes" do
    parse("spec/test_data")
    method_arrays = @method_definitions.map {|mdef| mdef.node.to_a}
    method_arrays.should include @the_nodes[0]
    method_arrays.should include @the_nodes[1]
    parse("spec/classes_modules")
    method_arrays = @method_definitions.map {|mdef| mdef.node.to_a}
    method_arrays.should include @the_nodes[0]
    method_arrays.should include @the_nodes[1]
  end
  it "isolates duplicated blocks" do
    to_ruby(duplicated("spec/test_data")).should == @duplicated_block
    to_ruby(duplicated("spec/classes_modules")).should == @duplicated_block
  end
  it "reports unique code" do
    test_data_unique_results = to_ruby(unique("spec/test_data"))
    classes_modules_unique_results = to_ruby(unique("spec/classes_modules"))
    @unique_block.each do |method|
      test_data_unique_results.should match %r[#{Regexp.escape(method)}]
      classes_modules_unique_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  it "reports distinct methods with the same name" do
    test_data_homonym_results = to_ruby(homonyms("spec/test_data"))
    classes_modules_homonym_results = to_ruby(homonyms("spec/classes_modules"))
    @homonym_block.each do |method|
      test_data_homonym_results.should match %r[#{Regexp.escape(method)}]
      classes_modules_homonym_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  it "reports methods which differ only by one node" do
    parse("spec/one_node_diff")
    one_node_diff_results = to_ruby(diff(1))
    @one_node_diff_block.each do |method|
      one_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
    parse("spec/larger_one_node_diff")
    larger_one_node_diff_results = to_ruby(diff(1))
    @bigger_one_node_diff_block.each do |method|
      larger_one_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  it "reports methods which differ by arbitrary numbers of nodes" do
    parse("spec/two_node_diff")
    @method_definitions.should_not be_empty
    two_node_diff_results = to_ruby(diff(2))
    @two_node_diff_block.each do |method|
      two_node_diff_results.should match %r[#{Regexp.escape(method)}]
    end
  end
  it "attaches filenames to individual nodes" do
    parse("spec/two_node_diff")
    @method_definitions[0].filename.should == File.expand_path("spec/two_node_diff/first_file.rb")
  end
end
