require "#{Doppelganger::LIBPATH}doppelganger/unified_ruby"

MethodDef = Struct.new(:name, :args, :body, :node, :filename, :line, :flat_body_array, :last_line)
BlockNode = Struct.new(:body, :node, :filename, :line, :flat_body_array, :last_line)
IterNode = Struct.new(:call_node, :asgn_node, :body, :node, :filename, :line, :flat_body_array, :last_line)

module Doppelganger
  # This class goes through all the ruby files in a directory and parses it into Sexp's.
  # It then exracts the definitions and stores them all and then includes the NodeAnalysis module
  # with allows a number of comparisons.
  class Extractor < SexpProcessor
    include UnifiedRuby
    
    attr_reader :sexp_blocks, :dir
    
    def initialize
      super
      self.auto_shift_type = true
      @rp = RubyParser.new
      @sexp_blocks = []
    end
    
    # This goes through all the files in the directory and parses them extracting
    # all the block-like nodes.
    def extract_blocks(dir)
      @dir = File.expand_path(dir)
      if File.directory? @dir
        Find.find(*Dir["#{self.dir}/**/*.rb"]) do |filename|
          if File.file? filename
            sexp = @rp.process(File.read(filename), filename)
            self.process(sexp)
          end
        end
      elsif File.file? @dir
        sexp = @rp.process(File.read(@dir), @dir)
        self.process(sexp)
      end
      @sexp_blocks
    end
    
    def process_defn(exp)
      method = MethodDef.new
      method.name = exp.shift
      method.args = process(exp.shift)
      method.last_line = exp.last_line_number
      method.body = process(exp.shift)
      method.node = s(:defn, method.name, method.args, method.body.dup)
      method.flat_body_array = method.body.dup.remove_literals.to_flat_ary
      method.filename = exp.file
      method.line = exp.line
      
      unless method.body == s(:scope, s(:block, s(:nil)))
        @sexp_blocks << method
      end
      method.node
    end
    
    def process_block(exp)
      block_node = BlockNode.new
      block_node.last_line = exp.last_line_number
      if exp.size > 1
        block_node.body = s()
        until (exp.empty?) do
          block_node.body << process(exp.shift)
        end
        block_node.node = s(:block, *block_node.body.dup)
      else
        block_node.body = exp.shift
        block_node.node = s(:block, block_node.body.dup)
      end

      block_node.flat_body_array = block_node.body.dup.remove_literals.to_flat_ary
      block_node.filename = exp.file
      block_node.line = exp.line
      
      unless block_node.body == s(:nil)
        @sexp_blocks << block_node
      end
      block_node.node
    end
    
    def process_iter(exp)
      unless exp[2][0] == :block
        iter_node = IterNode.new
        iter_node.call_node = process(exp.shift)
        iter_node.asgn_node = process(exp.shift)
        iter_node.last_line = exp.last_line_number
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
    
  end
end
