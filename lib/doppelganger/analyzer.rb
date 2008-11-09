require "#{Doppelganger::LIBPATH}doppelganger/node_analysis"

MethodDef = Struct.new(:name, :args, :body, :node, :filename, :line, :flat_body_array, :block_body, :last_line)
BlockNode = Struct.new(:body, :node, :filename, :line, :flat_body_array)
IterNode = Struct.new(:call_node, :asgn_node, :body, :node, :filename, :line, :flat_body_array, :last_line)

module Doppelganger
  # This class goes through all the ruby files in a directory and parses it into Sexp's.
  # It then exracts the definitions and stores them all and then includes the NodeAnalysis module
  # with allows a number of comparisons.
  class Analyzer < SexpProcessor
    include UnifiedRuby
    include Doppelganger::NodeAnalysis
    
    attr_reader :sexp_blocks, :dir
    
    def initialize(dir)
      super()
      @dir = File.expand_path(dir)
      self.auto_shift_type = true
      @pt = RubyParser.new
      @sexp_blocks = []
      extract_definitions
    end
    
    # This goes through all the files in the directory and parses them extracting
    # all the block-like nodes.
    def extract_definitions
      if File.directory? @dir
        Find.find(*Dir["#{self.dir}/**/*.rb"]) do |filename|
          if File.file? filename
            sexp = @pt.process(File.read(filename), filename)
            process(sexp)
          end
        end
      elsif File.file? @dir
        sexp = @pt.process(File.read(@dir), @dir)
        process(sexp)
      end
      @sexp_blocks
    end
    
    def process_defn(exp)
      method = MethodDef.new
      method.name = exp.shift
      method.args = process(exp.shift)
      method.last_line = exp.get_last_line_number
      method.body = process(exp.shift)
      method.node = s(:defn, method.name, method.args, method.body.dup)
      method.flat_body_array = method.body.dup.remove_literals.to_flat_ary
      method.block_body = get_block_body(method.body)
      method.filename = exp.file
      method.line = exp.line
      
      @sexp_blocks << method
      method.node
    end
    
    def process_block(exp)
      block_node = BlockNode.new
      block_node.body = s()
      until (exp.empty?) do
        block_node.body << process(exp.shift)
      end
      block_node.node = s(:block, *block_node.body.dup)
      block_node.flat_body_array = block_node.body.dup.remove_literals.to_flat_ary
      block_node.filename = exp.file
      block_node.line = exp.line
      
      @sexp_blocks << block_node
      block_node.node
    end
    
    def process_iter(exp)
      unless exp[2][0] == :block
        iter_node = IterNode.new
        iter_node.call_node = process(exp.shift)
        iter_node.asgn_node = process(exp.shift)
        iter_node.last_line = exp.get_last_line_number
        iter_node.body = process(exp.shift)
        iter_node.node = s(:iter, iter_node.call_node, iter_node.asgn_node, iter_node.body.dup)
        iter_node.flat_body_array = iter_node.body.dup.remove_literals.to_flat_ary
        iter_node.filename = exp.file
        iter_node.line = exp.line
    
        @sexp_blocks << iter_node
        iter_node.node
      else
        call_node = process(exp.shift)
        asgn_node = process(exp.shift)
        body = process(exp.shift)
        s(:iter, call_node, asgn_node, body)
      end
    end
    
    private
      def get_block_body(node) #:nodoc:
        block = node[1].dup
        block.shift
        block_body = s()
        until (block.empty?)
          block_body << block.shift
        end
        return block_body
      end
    
  end
end
