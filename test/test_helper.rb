require 'test/unit'
require 'rubygems'
require 'shoulda'
require File.expand_path( File.join(File.dirname(__FILE__), %w[.. lib doppelganger]) )


class DoppelgangerTestCase < Test::Unit::TestCase
  def setup
    @the_nodes = [
      # second_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:return, [:str, "also not unique"]]]]],
      [:defn, :baz, [:args], [:scope, [:block, [:or, [:true], [:str, "is unique"]]]]],

      # first_file.rb
      [:defn, :foo, [:args], [:scope, [:block, [:call, nil, :puts, [:arglist, [:lit, :something_unique]]]]]],
      [:defn, :bar, [:args], [:scope, [:block, [:return, [:str, "something not unique"]]]]]
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
    
    @repeated_pairs = [
      [s(:block, s(:iter, s(:call, s(:self), :each_sexp, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:call, s(:lvar, :block), :[], s(:arglist, s(:lvar, :sexp))), s(:call, s(:lvar, :sexp), :deep_each, s(:arglist, s(:block_pass, s(:lvar, :block))))))),
       s(:defn, :deep_each, s(:args, :"&block"), s(:scope, s(:block, s(:iter, s(:call, s(:self), :each_sexp, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:call, s(:lvar, :block), :[], s(:arglist, s(:lvar, :sexp))), s(:call, s(:lvar, :sexp), :deep_each, s(:arglist, s(:block_pass, s(:lvar, :block)))))))))],
      
      [s(:block, s(:lasgn, :line_number, s(:nil)), s(:iter, s(:call, s(:self), :deep_each, s(:arglist)), s(:lasgn, :sub_node), s(:if, s(:call, s(:lvar, :sub_node), :respond_to?, s(:arglist, s(:lit, :line))), s(:lasgn, :line_number, s(:call, s(:lvar, :sub_node), :line, s(:arglist))), nil)), s(:lvar, :line_number)),
       s(:defn, :last_line_number, s(:args), s(:scope, s(:block, s(:lasgn, :line_number, s(:nil)), s(:iter, s(:call, s(:self), :deep_each, s(:arglist)), s(:lasgn, :sub_node), s(:if, s(:call, s(:lvar, :sub_node), :respond_to?, s(:arglist, s(:lit, :line))), s(:lasgn, :line_number, s(:call, s(:lvar, :sub_node), :line, s(:arglist))), nil)), s(:lvar, :line_number))))],
      
      [s(:block, s(:iter, s(:call, s(:self), :inject, s(:arglist, s(:call, nil, :s, s(:arglist)))), s(:masgn, s(:array, s(:lasgn, :sexps), s(:lasgn, :sexp))), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), s(:call, s(:lvar, :sexps), :<<, s(:arglist, s(:yield, s(:lvar, :sexp)))), s(:call, s(:lvar, :sexps), :<<, s(:arglist, s(:lvar, :sexp)))), s(:lvar, :sexps)))),
       s(:defn, :map_sexps, s(:args), s(:scope, s(:block, s(:iter, s(:call, s(:self), :inject, s(:arglist, s(:call, nil, :s, s(:arglist)))), s(:masgn, s(:array, s(:lasgn, :sexps), s(:lasgn, :sexp))), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), s(:call, s(:lvar, :sexps), :<<, s(:arglist, s(:yield, s(:lvar, :sexp)))), s(:call, s(:lvar, :sexps), :<<, s(:arglist, s(:lvar, :sexp)))), s(:lvar, :sexps))))))],
      
      [s(:block, s(:lasgn, :output_sexp, s(:iter, s(:call, s(:self), :reject, s(:arglist)), s(:lasgn, :node), s(:call, s(:lvar, :block), :[], s(:arglist, s(:lvar, :node))))), s(:iter, s(:call, s(:lvar, :output_sexp), :map_sexps, s(:arglist)), s(:lasgn, :sexp), s(:call, s(:lvar, :sexp), :deep_reject, s(:arglist, s(:block_pass, s(:lvar, :block)))))),
       s(:defn, :deep_reject, s(:args, :"&block"), s(:scope, s(:block, s(:lasgn, :output_sexp, s(:iter, s(:call, s(:self), :reject, s(:arglist)), s(:lasgn, :node), s(:call, s(:lvar, :block), :[], s(:arglist, s(:lvar, :node))))), s(:iter, s(:call, s(:lvar, :output_sexp), :map_sexps, s(:arglist)), s(:lasgn, :sexp), s(:call, s(:lvar, :sexp), :deep_reject, s(:arglist, s(:block_pass, s(:lvar, :block))))))))],
      
      [s(:block, s(:lasgn, :output, s(:call, s(:self), :dup, s(:arglist))), s(:iter, s(:call, s(:lvar, :output), :deep_reject, s(:arglist)), s(:lasgn, :node), s(:not, s(:or, s(:call, s(:lvar, :node), :is_a?, s(:arglist, s(:const, :Symbol))), s(:call, s(:lvar, :node), :is_a?, s(:arglist, s(:const, :Sexp))))))),
       s(:defn, :remove_literals, s(:args), s(:scope, s(:block, s(:lasgn, :output, s(:call, s(:self), :dup, s(:arglist))), s(:iter, s(:call, s(:lvar, :output), :deep_reject, s(:arglist)), s(:lasgn, :node), s(:not, s(:or, s(:call, s(:lvar, :node), :is_a?, s(:arglist, s(:const, :Symbol))), s(:call, s(:lvar, :node), :is_a?, s(:arglist, s(:const, :Sexp)))))))))],
      
      [s(:block, s(:iter, s(:call, s(:self), :each, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp))))),
       s(:defn, :each_sexp, s(:args), s(:scope, s(:block, s(:iter, s(:call, s(:self), :each, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp)))))))],
      
      [s(:block, s(:iter, s(:call, s(:self), :each, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp))))),
       s(:block, s(:iter, s(:call, s(:self), :any?, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp)))))],
      
      [s(:block, s(:iter, s(:call, s(:self), :each, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp))))),
       s(:defn, :any_sexp?, s(:args), s(:scope, s(:block, s(:iter, s(:call, s(:self), :any?, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp)))))))],
      
      [s(:defn, :each_sexp, s(:args), s(:scope, s(:block, s(:iter, s(:call, s(:self), :each, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp))))))),
       s(:block, s(:iter, s(:call, s(:self), :any?, s(:arglist)), s(:lasgn, :sexp), s(:block, s(:if, s(:call, s(:const, :Sexp), :===, s(:arglist, s(:lvar, :sexp))), nil, s(:next)), s(:yield, s(:lvar, :sexp)))))]
    ]
    
    duplicate_sample_file_path = File.expand_path(File.join(File.dirname(__FILE__), 'sample_files/duplicate_test_data'))
    @duplicate_analysis = Doppelganger::Analyzer.new(duplicate_sample_file_path)
  end
  
  def default_test; end
  
  def teardown
    @the_nodes,  @unique_block, @bigger_diff_blocks, @duplicate_analysis, @repeats_removal_analysis = nil
  end
end

