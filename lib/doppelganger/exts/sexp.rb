class Sexp
  def deep_each(&block)
    self.each_sexp do |sexp|
      block[sexp]
      sexp.deep_each(&block)
    end
  end

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
  
  def deep_reject(&block)
    output_sexp = self.reject do |node|
      block[node]
    end
    output_sexp.map_sexps do |sexp|
      sexp.deep_reject(&block)
    end
  end
  
  def remove_literals
    output = self.dup
    output.deep_reject do |node|
      !((node.is_a?(Symbol)) || (node.is_a?(Sexp)))
    end
  end
  
  def to_flat_ary
    self.to_a.flatten
  end
end
