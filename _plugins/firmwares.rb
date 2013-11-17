require 'net/http'
require 'uri'
require 'nokogiri'

FIRMWARE_REGEX = /^(\w+)-([\d.]+)-\w+-\w+-([\w-]+)-squashfs-factory.bin$/
FIRMWARE_BASE = "http://metameute.de/~freifunk/firmware/0.3.2.2/"
HWREV_REGEX = /^(.+)-v(\d+)$/

MODELMAP = {
  "ubnt-bullet-m" => { :make => "Ubiquiti", :model => "Bullet M" },

  "tl-wdr3600"  => { :make => "TP-Link", :model => "TL-WDR3600" },
  "tl-wdr4300"  => { :make => "TP-Link", :model => "TL-WDR4300" },
  "tl-wr1043nd" => { :make => "TP-Link", :model => "TL-WR1043ND" },
  "tl-wr740n"   => { :make => "TP-Link", :model => "TL-WR741N" },
  "tl-wr741nd"  => { :make => "TP-Link", :model => "TL-WR741ND" },
  "tl-wr841n"   => { :make => "TP-Link", :model => "TL-WR841ND" },
  "tl-wr841nd"  => { :make => "TP-Link", :model => "TL-WR841ND" },
  "tl-wr842n"   => { :make => "TP-Link", :model => "TL-WR842N" }
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
    attr_accessor :url
    attr_accessor :filename
    attr_accessor :version
    attr_accessor :model
    attr_accessor :hwrev

    def to_liquid
      {
        "url" => url,
        "filename" => filename,
        "version" => version,
        "hwrev" => hwrev
      }
    end

    def to_s
      self.filename
    end
  end

  class FirmwareListGenerator < Generator
    def generate(site)
      class << site
        attr_accessor :firmwares
        def site_payload
          result = super
          result["site"]["firmwares"] = self.firmwares
          result
        end
      end

      uri = URI.parse(FIRMWARE_BASE)
      response = Net::HTTP.get_response uri
      doc = Nokogiri::HTML(response.body)
      links = doc.css('a')
      hrefs = links.map do |link|
        link.attribute('href').to_s
      end.uniq.sort.select do |href|
        href.match(FIRMWARE_REGEX)
      end

      firmwares = hrefs.map do |href|
        fw = Firmware.new
        fw.url = FIRMWARE_BASE + href
        fw.filename = href

        href.match(FIRMWARE_REGEX) do |m|
          fw.version = m[2]
          fw.model = m[3]

          fw.model.match(HWREV_REGEX) do |m|
            fw.model = m[1]
            fw.hwrev = m[2]
          end
        end

        fw
      end

      models = firmwares.group_by do |fw|
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

      site.firmwares = makes
    end
  end
end
