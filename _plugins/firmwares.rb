require 'net/http'
require 'uri'
require 'nokogiri'
require 'pp'

######### Configuration ##############
COMMUNITY_TLD = 'ffki'
FIRMWARE_VERSION = '2016.1.5.1'
FIRMWARE_BASE = 'http://freifunk.in-kiel.de/' + COMMUNITY_TLD + '-firmware/latest/'
FIRMWARE_MIRROR = 'http://freifunk.discovibration.de/firmware/firmware-0.7.1/'
######################################

FIRMWARE_PREFIX = 'gluon-' + COMMUNITY_TLD
FIRMWARE_REGEX = Regexp.new('^' + FIRMWARE_PREFIX + '-' + FIRMWARE_VERSION + '-')

GROUPS = {
  "8Devices" => {
    models: [
      "Carambola2-Board",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Alfa" => {
    models: [
      "AP121",
      "AP121U",
      "Hornet-UB",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Allnet" => {
    models: [
      "ALL0315N"
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Buffalo" => {
    models: [
      "WZR-600DHP",
      "WZR-HP-AG300H",
      "WZR-HP-G300NH",
      "WZR-HP-G450H",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "D-Link" => {
    models: [
      "DIR-505",
      "DIR-615",
      "DIR-825",
    ],
    extract_rev: lambda { |model, suffix| /^-rev-(.+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1].upcase },
  },
  "GL-iNet" => {
    models: [
      "6408A",
      "6416A",
    ],
    extract_rev: lambda { |model, suffix| /^-(.+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "Linksys" => {
    models: [
      "WRT160NL",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Meraki" => {
    models: [
      "mr12",
      "mr16",
      "mr62",
      "mr66",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "NETGEAR" => {
    models: [
      "WNDR3700",
      "WNDR3800",
      "WNDR4300",
      "WNDRMAC"
    ],
    extract_rev: lambda { |model, suffix| /^(.*?)(?:-sysupgrade)?\.[^.]+$/.match(suffix)[1].sub(/^$/, 'v1') },
  },
  "Onion" => {
    models: [
      "Omega",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "OpenMesh" => {
    models: [
      "MR600",
      "MR900",
      "OM2P",
      "OM2P-HS",
      "OM2P-LC",
      "OM5P",
      "OM5P-AN",
    ],
    extract_rev: lambda { |model, suffix| /^(.*?)(?:-sysupgrade)?\.[^.]+$/.match(suffix)[1].sub(/^$/, 'v1') },
  },
  "TP-Link" => {
    models: [
      "ARCHER-C5",
      "ARCHER-C7",
      "CPE210",
      "CPE220",
      "CPE510",
      "CPE520",
      "TL-MR13U",
      "TL-MR3020",
      "TL-MR3040",
      "TL-MR3220",
      "TL-MR3420",
      "TL-WA701N/ND",
      "TL-WA750RE",
      "TL-WA7510N",
      "TL-WA801N/ND",
      "TL-WA830RE",
      "TL-WA850RE",
      "TL-WA860RE",
      "TL-WA901N/ND",
      "TL-WDR3500",
      "TL-WDR3600",
      "TL-WDR4300",
      "TL-WDR4900",
      "TL-WR1043N/ND",
      "TL-WR2543N/ND",
      "TL-WR703N",
      "TL-WR710N",
      "TL-WR740N/ND",
      "TL-WR741N/ND",
      "TL-WR743N/ND",
      "TL-WR841N/ND",
      "TL-WR842N/ND",
      "TL-WR843N/ND",
      "TL-WR940N/ND",
      "TL-WR941N/ND",
    ],
    extract_rev: lambda { |model, suffix| /^-(.+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "Ubiquiti" => {
    models: [
      "Airgateway",
      "Airrouter",
      "Loco M",
      "Nanostation-Loco M2",
      "Nanostation-Loco M5",
      "Bullet M",
      "LS-SR71", #LiteStation-SR71
      "Nanostation M",
      "Nanostation M5",
      "Picostation M",
      "Rocket M",
      "Rocket M XW",
      "UniFi AP Pro",
      "UniFi",
      "UniFiAP Outdoor",
    ],
    extract_rev: lambda { |model, suffix|
      rev = /^(.*?)(?:-sysupgrade)?\.bin$/.match(suffix)[1]

      if rev == '-xw'
        'XW'
      elsif model == 'Nanostation M' or model == 'Nanostation-Loco M' or model == 'Bullet M'
        'XM'
      else
        nil
      end
    },
    transform_label: lambda { |model|
      #if model == 'Bullet M' then
      #  'Bullet M, Loco M'
      #els
      if model == 'UniFi' then
        'UniFi AP (LR)'
      else
        model
      end
    }
  },
  "wd-my-net" => {
    models: [
      "N600",
      "N750",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "x86" => {
    models: [
      "64",
      "Generic",
      "KVM",
      "VirtualBox",
      "VMware",
      "64-VirtualBox",
      "64-VMware",
      "xen",
      "x86-64",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
}

module Jekyll
  class Firmware
    attr_accessor :group
    attr_accessor :label
    attr_accessor :factory
    attr_accessor :sysupgrade
    attr_accessor :hwrev

    def to_liquid
      {
        "factory" => factory,
        "sysupgrade" => sysupgrade,
        "hwrev" => hwrev
      }
    end

    def to_s
      self.label
    end
  end

  class FirmwareListGenerator < Generator
    def generate(site)
      class << site
        attr_accessor :firmwares
        def site_payload
          result = super
          result["site"]["firmwares"] = self.firmwares
          result["site"]["firmware_version"] = FIRMWARE_VERSION
          result["site"]["firmware_mirror"] = FIRMWARE_MIRROR
          result["site"]["community_tld"] = COMMUNITY_TLD
          result
        end
      end

      def get_files(url)
        uri = URI.parse(url)
        puts ("load firmware from " + url)
        response = Net::HTTP.get_response uri
        doc = Nokogiri::HTML(response.body)
        doc.css('a').map do |link|
          link.attribute('href').to_s
        end.uniq.sort.select do |href|
          href.match(FIRMWARE_REGEX)
        end
      end

      def sanitize_model_name(name)
        name
          .downcase
          .gsub(/[^\w\-\.]+/, '-')
          .gsub(/\.+/, '.')
          .gsub(/[\-\.]*-[\-\.]*/, '-')
          .gsub(/-+$/, '')
      end

      def prefix_of(sub, str)
        str[0, sub.length].eql? sub
      end

      def find_prefix(name)
        @prefixes.each do |prefix|
          return prefix if prefix_of(prefix, name)
        end

        nil
      end

      firmwares = Hash[GROUPS.collect_concat { |group, info|
        info[:models].collect do |model|
          basename = FIRMWARE_PREFIX + '-' + FIRMWARE_VERSION + '-' + sanitize_model_name(group + ' ' + model)
          #print basename
          label = if info[:transform_label] then
                    info[:transform_label].call model
                  else
                    model
                  end
          [basename,
           {
             :extract_rev => info[:extract_rev],
             :model => model,
             :revisions => Hash.new { |hash, rev|
               fw = Firmware.new
               fw.label = label
               fw.group = group
               fw.hwrev = rev
               fw
             },
           }
          ]
        end
      }]

      @prefixes = firmwares.keys.sort_by { |p| p.length }.reverse

      factory = get_files(FIRMWARE_BASE + "factory/")
      sysupgrade = get_files(FIRMWARE_BASE + "sysupgrade/")

      factory.each do |href|
        basename = find_prefix href
        if basename.nil? then
          puts "error in "+href
        else
          suffix = href[basename.length..-1]
          info = firmwares[basename]

          hwrev = info[:extract_rev].call info[:model], suffix

          fw = info[:revisions][hwrev]
          fw.factory = FIRMWARE_BASE + "factory/" + href
          info[:revisions][hwrev] = fw
        end
      end

      sysupgrade.each do |href|
        basename = find_prefix href
        if basename.nil? then
          puts "error in "+href
        else
          suffix = href[basename.length..-1]
          info = firmwares[basename]

          hwrev = info[:extract_rev].call info[:model], suffix

          fw = info[:revisions][hwrev]
          fw.sysupgrade = FIRMWARE_BASE + "sysupgrade/" + href
          info[:revisions][hwrev] = fw
        end
      end

      firmwares.delete_if { |k, v| v[:revisions].empty? }

      groups = firmwares
               .collect { |k, v| v[:revisions] }
               .group_by { |revs| revs.values.first.label }
               .collect { |k, v| [k, v.first] }
               .sort
               .group_by { |k, v| v.first[1].group }
               .to_a
               .sort

      site.firmwares = groups
    end
  end
end
