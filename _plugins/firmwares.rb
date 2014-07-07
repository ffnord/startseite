require 'net/http'
require 'uri'
require 'nokogiri'
require 'pp'

FIRMWARE_REGEX = /^gluon-((\w+)-([\d.]+)-([\w-]+)).bin$/
HWREV_REGEX = /^(.+)-v(\d+)$/

MODELMAP = {
  "ubiquiti-bullet-m"        => { :make => "Ubiquiti", :model => "Bullet M, Nanostation Loco M" },
  "ubiquiti-unifi"           => { :make => "Ubiquiti", :model => "UniFi AP (LR)" },
  "ubiquiti-nanostation-m"   => { :make => "Ubiquiti", :model => "Nanostation M" },
  "ubiquiti-unifiap-outdoor" => { :make => "Ubiquiti", :model => "UniFi AP Outdoor" },

  "tp-link-tl-mr3020"      => { :make => "TP-Link", :model => "TL-MR3020" },
  "tp-link-tl-mr3040"      => { :make => "TP-Link", :model => "TL-MR3040" },
  "tp-link-tl-mr3220"      => { :make => "TP-Link", :model => "TL-MR3220" },
  "tp-link-tl-mr3420"      => { :make => "TP-Link", :model => "TL-MR3420" },
  "tp-link-tl-wdr3500"     => { :make => "TP-Link", :model => "TL-WDR3500" },
  "tp-link-tl-wdr3600"     => { :make => "TP-Link", :model => "TL-WDR3600" },
  "tp-link-tl-wdr4300"     => { :make => "TP-Link", :model => "TL-WDR4300" },
  "tp-link-tl-wa901n-nd"   => { :make => "TP-Link", :model => "TL-WA901" },
  "tp-link-tl-wr740n-nd"   => { :make => "TP-Link", :model => "TL-WR740" },
  "tp-link-tl-wr741n-nd"   => { :make => "TP-Link", :model => "TL-WR741" },
  "tp-link-tl-wr841n-nd"   => { :make => "TP-Link", :model => "TL-WR841" },
  "tp-link-tl-wr842n-nd"   => { :make => "TP-Link", :model => "TL-WR842" },
  "tp-link-tl-wr941n-nd"   => { :make => "TP-Link", :model => "TL-WR941" },
  "tp-link-tl-wr1043n-nd"  => { :make => "TP-Link", :model => "TL-WR1043" },
}

module Jekyll
  class ModelDB
    def self.make(model)
      r = MODELMAP[model]
      if r.nil? then nil else r[:make] end
    end

    def self.model(model)
      r = MODELMAP[model]
      if r.nil? then nil else r[:model] end
    end
  end

  class Firmware
    attr_accessor :basename
    attr_accessor :factory
    attr_accessor :sysupgrade
    attr_accessor :version
    attr_accessor :model
    attr_accessor :make
    attr_accessor :hwrev

    def to_liquid
      {
        "basename" => basename,
        "factory" => factory,
        "sysupgrade" => sysupgrade,
        "version" => version,
        "hwrev" => hwrev
      }
    end

    def to_s
      self.basename
    end
  end

  class FirmwareListGenerator < Generator
    def generate(site)
      def get_files(url)
        uri = URI.parse(url)
        response = Net::HTTP.get_response uri
        doc = Nokogiri::HTML(response.body)
        doc.css('a').map do |link|
          link.attribute('href').to_s
        end.uniq.sort.select do |href|
          href.match(FIRMWARE_REGEX)
        end
      end

      firmware_base = site.config['firmware']['base']

      factory = get_files(firmware_base + "factory/")
      sysupgrade = get_files(firmware_base + "sysupgrade/")

      firmwares = Hash.new

      factory.each do |href|
        fw = Firmware.new
        fw.factory = firmware_base + "factory/" + href

        href.match(FIRMWARE_REGEX) do |m|
          fw.basename = m[1]
          fw.version = m[3]
          fw.model = m[4]

          fw.model.match(HWREV_REGEX) do |m|
            fw.model = m[1]
            fw.hwrev = m[2]
          end
        end

        firmwares[fw.basename] = fw
      end

      sysupgrade.each do |href|
        path = firmware_base + "sysupgrade/" + href

        href.match(FIRMWARE_REGEX) do |m|
          basename = m[1].chomp "-sysupgrade"

          if firmwares.has_key? basename
            firmwares[basename].sysupgrade = path
          end
        end
      end

      models = firmwares.values.group_by do |fw|
        ModelDB.model(fw.model)
      end

      makes = models.group_by do |k,v|
        ModelDB.make(v.first.model)
      end

      makes.each do |k,models|
        makes[k] = Hash[ models.map do |k,v|
          [ModelDB.model(k) || k, v.sort_by do |f|
            f.hwrev
          end
          ]
        end ]
      end

      page = site.pages.detect {|page| page.name == 'firmware.html'}
      page.data['makes'] = makes
    end
  end
end
