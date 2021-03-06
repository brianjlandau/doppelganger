module Doppelganger
  # This handles the comparison of the Ruby nodes.
  #
  # This will use various iterators to compare all the diffent block-like nodes
  # in your code base and find similar or duplicate nodes.
  class NodeAnalysis
    
    attr_accessor :sexp_blocks
    
    def initialize(sexp_blocks)
      @sexp_blocks = sexp_blocks
    end
    
    # Are there any duplicates in the code base.
    def duplication?
      not duplicates.empty?
    end
    
    # Finds blocks of code that are exact duplicates, node for node. All duplicate
    # blocks are grouped together.
    def duplicates
      block_nodes = @sexp_blocks.map{ |sblock| sblock.body.remove_literals }
      (@sexp_blocks.inject([]) do |duplicate_blocks, sblock|
        node_body = sblock.body.remove_literals
        if block_nodes.duplicates?(node_body)
          if duplicate_blocks.map{|sb| sb.first.body.remove_literals}.include?(node_body)
            duplicate_blocks.find{|sb| sb.first.body.remove_literals == node_body } << sblock
          else
            duplicate_blocks << [sblock]
          end
        end
        duplicate_blocks
      end).compact.uniq
    end
    
    # Finds block-like nodes that differ from another node by the threshold or less, but are not duplicates.
    def diff(threshold, progress_bar = nil)
      diff_nodes = []
      @compared_node_pairs = []
      stepwise_sblocks(progress_bar) do |block_node_1, block_node_2|
        if threshold >= Diff::LCS.diff(block_node_1.flat_body_array, block_node_2.flat_body_array).size
          diff_nodes << [block_node_1, block_node_2]
        end
        @compared_node_pairs << [block_node_1, block_node_2]
      end
      @compared_node_pairs = []
      cleanup_descendant_duplicate_matches(diff_nodes)
    end
    
    # Finds block-like nodes that differ by a given threshold percentage or less, but are not duplicates.
    def percent_diff(percentage, progress_bar = nil)
      # To calculate the percentage we can do this in one of two ways we can compare
      # total differences (the diff set flattened) over the total nodes (the flattened bodies added)
      # or we can compare the number of change sets (the size of the diff) over the average number of nodes
      # in the two methods.
      # Not sure which is best but I've gone with the former for now.
      diff_nodes = []
      @compared_node_pairs = []
      stepwise_sblocks(progress_bar) do |block_node_1, block_node_2|
        total_nodes = block_node_1.flat_body_array.size + block_node_2.flat_body_array.size
        diff_size = Diff::LCS.diff(block_node_1.flat_body_array, block_node_2.flat_body_array).flatten.size
        if percentage >= (diff_size.to_f/total_nodes.to_f * 100)
          diff_nodes << [block_node_1, block_node_2]
        end
        @compared_node_pairs << [block_node_1, block_node_2]
      end
      @compared_node_pairs = []
      cleanup_descendant_duplicate_matches(diff_nodes)
    end
    
    protected
      def stepwise_sblocks(progress_bar = nil)
        @sexp_blocks.dup.each do |node1|
          @sexp_blocks.dup.each do |node2|
            progress_bar.inc unless progress_bar.nil?
            next if nodes_compared? node1, node2
            next if node1.body.remove_literals == node2.body.remove_literals
            next if one_node_is_child_of_the_other? node1, node2
            yield node1, node2
          end
        end
      end
      
      def node_includes_block?(element, block_node)
        (element.filename == block_node.filename) && 
          ((element.line..(element.last_line+1)).include?(block_node.line) ||
          element.node.contains_block?(block_node.node))
      end
      
      def cleanup_descendant_duplicate_matches(diff_nodes)
        diff_nodes.reject do |block_node_pair|
          ancestor_pair_in_results?(block_node_pair, diff_nodes)
        end
      end
      
      def ancestor_pair_in_results?(pair, results)
        matches = results.select do |block_node_pair|
          block_node_pair.any?{|n| node_includes_block?(n, pair.first)} &&
            block_node_pair.any?{|n| node_includes_block?(n, pair.last)}
        end
        matches.size > 1
      end
      
      def one_node_is_child_of_the_other?(node1, node2)
        if node1.is_a?(MethodDef) && node2.is_a?(BlockNode)
          (node_includes_block?(node1, node2))
        elsif node1.is_a?(BlockNode) && node2.is_a?(MethodDef)
          (node_includes_block?(node2, node1))
        else
          (node_includes_block?(node1, node2) || node_includes_block?(node2, node1))
        end
      end
      
      def nodes_compared?(node1, node2)
        @compared_node_pairs.any? do |block_node_pair|
          block_pair_nodes = block_node_pair.map(&:node)
          block_pair_nodes.include?(node1.node) && block_pair_nodes.include?(node2.node)
        end
      end
  end
end
