require 'test/unit'
require 'rubygems'
require 'shoulda'
require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib doppelganger]) )

require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true


class DoppelgangerTestCase < Test::Unit::TestCase
  def setup
    @the_nodes = [
      # second_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:str, "still unique"]]]],
      [:defn, :bar, [:args], [:scope, [:block, [:str, "something non-unique"]]]],
      [:defn, :baz, [:args], [:scope, [:block, [:str, "also unique"]]]],

      # first_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:str, "something unique"]]]],
      [:defn, :bar, [:args], [:scope, [:block, [:str, "something non-unique"]]]]
    ]

    @unique_block = [
      [:defn, :foo, [:args], [:scope, [:block, [:str, "still unique"]]]],
      [:defn, :baz, [:args], [:scope, [:block, [:str, "also unique"]]]],
      [:defn, :foo, [:args], [:scope, [:block, [:str, "something unique"]]]]
    ]

    @one_node_diff_block = [
[:defn, :foo, [:args], [:scope, [:block, [:str, "foo"]]]],
[:defn, :bar, [:args], [:scope, [:block, [:str, "bar"]]]]
    ]

    @bigger_diff_blocks = [
[:defn, :foo, [:args], 
  [:scope, 
    [:block, 
      [:call, nil, :puts, 
        [:arglist, [:str, "muppetfuckers"]]], 
        [:iasgn, :@variable, [:str, "foo"]], 
        [:iter, [:call, 
          [:array, [:str, "this"], [:str, "is"], [:str, "some"], [:str, "words"]], :each, [:arglist]], 
          [:lasgn, :word], 
          [:call, [:lvar, :word], :size, [:arglist]]]]]],
[:defn, :bar, [:args], 
  [:scope, [:block, 
    [:call, nil, :puts, 
      [:arglist, [:str, "muppetfuckers"]]], 
      [:iter, [:call, 
        [:array, [:str, "this"], [:str, "is"], [:str, "bad"], [:str, "words"]], :each, [:arglist]], 
        [:lasgn, :word], 
        [:call, nil, :puts, [:arglist, [:lvar, :word]]]], 
      [:iasgn, :@variable, [:str, "bar"]]]]]
    ]

    @two_node_diff_block = [
[:defn, :foo, [:args], 
  [:scope, [:block, 
    [:call, nil, :puts, 
      [:arglist, [:str, "muppetphuckers"]]], 
    [:iasgn, :@variable, [:str, "foo"]]]]],
[:defn, :bar, [:args], 
  [:scope, [:block, 
    [:call, nil, :puts, 
      [:arglist, [:str, "muppetfuckers"]]], 
    [:iasgn, :@variable, [:str, "bar"]]]]]
    ]
    
    @test_data_analysis = Doppelganger::Analyzer.new("test/sample_files/test_data")
    @classes_modules_analysis = Doppelganger::Analyzer.new("test/sample_files/classes_modules")
  end
  
  def default_test
  end
  
  def teardown
    @the_nodes, @duplicated_block, @unique_block, @homonym_block, @one_node_diff_block, @bigger_one_node_diff_block, 
      @two_node_diff_block, @test_data_analysis, @classes_modules_analysis = nil
  end
end

