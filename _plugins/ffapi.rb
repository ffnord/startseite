module Jekyll
  module Filters
    def date_to_stamp(date)
      date.to_i
    end
  end
  class FreifunkAPIPage < Page
    def initialize(site, base, dir,name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(@name)
      self.read_yaml(File.join(base,'_layouts'),name)

    end
  end

  class FreifunkAPIPageGenerator < Generator
    safe true
    def generate(site)
      site.pages << FreifunkAPIPage.new(site,site.source,'','ffapi.json')
    end
  end
end
