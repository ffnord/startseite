module Jekyll
  module HashFilter
    def hash(input, key)
      input[key]
    end
  end
end

Liquid::Template.register_filter(Jekyll::HashFilter)
