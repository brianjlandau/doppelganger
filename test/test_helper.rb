require 'test/unit'
require 'rubygems'
require 'shoulda'
require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib doppelganger]) )


class DoppelgangerTestCase < Test::Unit::TestCase
  def setup
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

    @bigger_diff_blocks = [
'def foo
  puts("muppetfuckers")
  @variable = "foo"
  ["this", "is", "some", "words"].each { |word| word.size }
end',
'def bar
  puts("muppetfuckers")
  ["this", "is", "bad", "words"].each { |word| puts(word) }
  @variable = "bar"
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
    
    @test_data_analysis = Doppelganger::Analyzer.new("test/test_data")
    @classes_modules_analysis = Doppelganger::Analyzer.new("test/classes_modules")
  end
  
  def default_test
  end
  
  def teardown
    @the_nodes, @duplicated_block, @unique_block, @homonym_block, @one_node_diff_block, @bigger_one_node_diff_block, 
      @two_node_diff_block, @test_data_analysis, @classes_modules_analysis = nil
  end
end

