module Doppelganger
  class View
    # A simple method to take an array of method definitions and create
    # strings of Ruby code.
    def self.to_ruby(nodes)
      nodes.dup.inject("") do |string, method_def|
        string += Ruby2Ruby.new.process(method_def.node) + "\n\n"
        string
      end
    end
  end
end
