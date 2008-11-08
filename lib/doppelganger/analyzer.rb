require "#{Doppelganger::LIBPATH}doppelganger/node_analysis"

MethodDef = Struct.new(:name, :args, :body, :node, :filename, :line, :flat_body_array)
BlockNode = Struct.new(:body_nodes, :node, :filename, :line, :flat_body_array)
IterNode = Struct.new(:call_node, :asgn_node, :body, :node, :filename, :line, :flat_body_array)

module Doppelganger
  # This class goes through all the ruby files in a directory and parses it into Sexp's.
  # It then exracts the definitions and stores them all and then includes the NodeAnalysis module
  # with allows a number of comparisons.
  class Analyzer < SexpProcessor
    include UnifiedRuby
    include Doppelganger::NodeAnalysis
    
    attr_reader :method_definitions, :blocks, :iter_nodes, :dir
    
    def initialize(dir)
      super()
      @dir = File.expand_path(dir)
      self.auto_shift_type = true
      @pt = RubyParser.new
      @method_definitions = []
      @blocks = []
      @iter_nodes = []
      extract_definitions
    end
    
    # This does throw all the files in the directory and parses them extracting all the
    # method definitions.
    def extract_definitions
      Find.find(*Dir["#{self.dir}/**/*.rb"]) do |filename|
        if File.file? filename
          sexp = @pt.process(File.read(filename), filename)
          process(sexp)
        end
      end
      @method_definitions
    end
    
    # When ever a <tt>defn</tt> node is enountered this is method is called and used
    # to process it. It extracts the method definition into our collection of methods.
    def process_defn(exp)
      method = MethodDef.new
      method.name = exp.shift
      method.args = process(exp.shift)
      method.body = process(exp.shift)
      method.node = s(:defn, method.name, method.args, method.body.dup).freeze
      method.flat_body_array = method.body.dup.remove_literals.to_flat_ary
      method.filename = exp.file
      method.line = exp.line
      
      @method_definitions << method
      method.node
    end
    
    def process_block(exp)
      block_node = BlockNode.new
      block_node.body_nodes = s()
      until (exp.empty?) do
        block_node.body_nodes << process(exp.shift)
      end
      block_node.node = s(:block, *block_node.body_nodes.dup).freeze
      block_node.flat_body_array = block_node.body_nodes.dup.remove_literals.to_flat_ary
      block_node.filename = exp.file
      block_node.line = exp.line
      
      @blocks << block_node
      block_node.node
    end
    
    def process_iter(exp)
      unless exp[2][0] == :block
        iter_node = IterNode.new
        iter_node.call_node = process(exp.shift)
        iter_node.asgn_node = process(exp.shift)
        iter_node.body = process(exp.shift)
        iter_node.node = s(:iter, iter_node.call_node, iter_node.asgn_node, iter_node.body.dup).freeze
        iter_node.flat_body_array = iter_node.body.dup.remove_literals.to_flat_ary
        iter_node.filename = exp.file
        iter_node.line = exp.line
    
        @iter_nodes << iter_node
        iter_node.node
      else
        call_node = process(exp.shift)
        asgn_node = process(exp.shift)
        body = process(exp.shift)
        s(:iter, call_node, asgn_node, body)
      end
    end
    
  end
end
