# The Sexp extension of this library excelent examples of repeated comparisons
# between "blocks" that need to be trimmed from the output. So I've duplicated
# and frozen it in this file.

class Sexp
  # Performs the block on every Sexp in this sexp.
  def deep_each(&block)
    self.each_sexp do |sexp|
      block[sexp]
      sexp.deep_each(&block)
    end
  end
  
  # Finds the last line of the Sexp if that information is available.
  def last_line_number
    line_number = nil
    self.deep_each do |sub_node|
      if sub_node.respond_to? :line
        line_number = sub_node.line
      end
    end
    line_number
  end
  
  # Maps all sub Sexps into a new Sexp, if the node isn't a Sexp
  # performs the block and maps the result into the new Sexp.
  def map_sexps
    self.inject(s()) do |sexps, sexp|
      unless Sexp === sexp
        sexps << sexp
      else
        sexps << yield(sexp)
      end
      sexps
    end
  end
  
  # Rejects all objects in the Sexp that return true for the block.
  def deep_reject(&block)
    output_sexp = self.reject do |node|
      block[node]
    end
    output_sexp.map_sexps do |sexp|
      sexp.deep_reject(&block)
    end
  end
  
  # Removes all literals from the Sexp (Symbols aren't excluded as they are used internally
  # by Sexp for node names which identifies structure important for comparison.)
  def remove_literals
    output = self.dup
    output.deep_reject do |node|
      !((node.is_a?(Symbol)) || (node.is_a?(Sexp)))
    end
  end
  
  # Iterates through each child Sexp of the current Sexp.
  def each_sexp
    self.each do |sexp|
      next unless Sexp === sexp

      yield sexp
    end
  end
  
  # Performs the block on every Sexp in this sexp, looking for one that returns true.
  def deep_any?(&block)
    self.any_sexp? do |sexp|
      block[sexp] || sexp.deep_any?(&block)
    end
  end
  
  # Iterates through each child Sexp of the current Sexp and looks for any Sexp
  # that returns true for the block.
  def any_sexp?
    self.any? do |sexp|
      next unless Sexp === sexp

      yield sexp
    end
  end
  
  # Determines if the passed in block node is contained with in the Sexp node.
  def contains_block?(block_node)
    self.deep_any? do |sexp|
      sexp == block_node
    end
  end
  
  # First turns the Sexp into an Array then flattens it.
  def to_flat_ary
    self.to_a.flatten
  end
end
