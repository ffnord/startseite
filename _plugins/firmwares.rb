#!/usr/bin/ruby

# error handling for "undefined method `[]' for nil:NilClass (NoMethodError)" with
# jekyll build --trace

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

# {} ist ein hash
# [] ist ein array
# foo: weist den key :foo im hash zu
# "foo" => ist äquivalent mit foo: aber kann auch sonderzeichen enthalten (das ganze aber erst in zukunft, ab ruby 2.3)
# lambda ist eine spezielle anonyme funktion
GROUPS = {
  "8Devices" => {
    models: [
      "Carambola2-Board",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "A5" => {
    models: [
      "v11",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "AVM" => {
    models: [
      "FRITZ-BOX-4020",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Alfa" => {
    models: [
      "AP121",
      "AP121U",
      "Hornet-UB",
      "Network-N2-N5",
      "Network-Tube2H",
      "Network-AP121",
      "Network-AP121U",
      "Network-Hornet-UB"
    ],
    #FIXME: alfa-networks to alfa in OpenWRT Wiki info links and Router node pictures
    extract_rev: lambda { |model, suffix| nil },
  },
  "Allnet" => {
    models: [
      "ALL0315N",
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
      "DIR-860L",
    ],
    extract_rev: lambda { |model, suffix| /^-(((rev-|)|b).+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "GL-iNet" => {
    models: [
      "6408A",
      "6416A",
    ],
    extract_rev: lambda { |model, suffix| /^-(.+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "GL" => { #this one is also GL.inet
    models: [
      "AR150",
      "AR300M",
      "AR750",
      "MT300A",
      "MT300N",
      "MT750",
    ],
    extract_rev: lambda { |model, suffix| /^-(.+?)(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "Lemaker" => {
    models: [
      "Banana-PI",
      "Banana-PRO",
      "Lamobo-R1",
    ],
    extract_rev: lambda { |model, suffix| nil },
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
  "MikroTik" => {
    models: [
      "rootfs",
      "vmlinux-lzma",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "NETGEAR" => {
    models: [
      "WNDR3700",
      "WNDR3800",
      "WNDR4300",
      "WNDRMAC",
      "WNR2200", # nur sysupgrade
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
      "A40",
      "A60",
      "MR600",
      "MR900",
      "OM2P",
      "OM2P-HS",
      "OM2P-LC",
      "OM5P",
      "OM5P-AN",
      "mr1750",
      "mr1750v2",
    ],
    extract_rev: lambda { |model, suffix| /^(.*?)(?:-sysupgrade)?\.[^.]+$/.match(suffix)[1].sub(/^$/, 'v1') },
  },
  "Raspberry Pi" => {
    models: [
      "",
      "2"
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "TP-Link" => {
    models: [
      "ARCHER-C25",
      "ARCHER-C5",
      "ARCHER-C58",
      "ARCHER-C59",
      "ARCHER-C60",
      "ARCHER-C7",
      "CPE210",
      "CPE220",
      "CPE510",
      "CPE520",
      "RE450",
      "TL-WA7210N",
      "TL-WA730RE",
      "TL-WR1043N",
      "WBS210",
      "WBS510",
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
      "TL-WR802N",
      "TL-WR810N",
      "TL-WR841N/ND",
      "TL-WR842N/ND",
      "TL-WR843N/ND",
      "TL-WR940N",
      "TL-WR940N/ND",
      "TL-WR941N/ND",
    ],
    #            lambda macht nur, dass es jedes mal ausgeführt wird
    extract_rev: lambda { |model, suffix| rev = /^(?:-(?!sysupgrade)(.+?))?(?:-sysupgrade)?\.bin$/.match(suffix)[1] },
  },
  "Ubnt" => {
    models: [
      "erx",
      "erx-sfp",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },

  "Ubiquiti" => {
    models: [
      "Airgateway",
      "Airgateway LR",
      "Airgateway Pro",
      "Airrouter",
      "Bullet M",
      "Bullet M2",
      "Bullet M5",
      "Loco M",
      "Nanobeam M5",
      "Nanostation-Loco M2",
      "Nanostation-Loco M5",
      "LS-SR71", #LiteStation-SR71
      "Nanostation M",
      "Nanostation M2",
      "Nanostation M5",
      "Picostation M2",
      "Rocket M",
      "Rocket M2",
      "Rocket M5",
      "UniFi AC Lite",
      "UniFi AC LR",
      "UniFi AC Mesh",
      "UniFi AC Pro",
      "UniFi AP LR",
      "UniFi AP Pro",
      "UniFi AP",
      "UniFi",
      "UniFiAP Outdoor",
    ],
    extract_rev: lambda { |model, suffix|
      rev = /^(.*?)(?:-sysupgrade)?\.bin$/.match(suffix)[1]

      if rev == '-xw'
        'XW'
      elsif rev == '-xm'
        'XM'
      elsif rev == '-ti'
        'TI'
      elsif rev == '+'
        '+'
      else
        nil
      end
    },
    # transform_label: lambda { |model|
    #   if model == 'UniFi' then
    #     'UniFi AP (LR)'
    #   else
    #     model
    #   end
    # },
  },
  "VoCore" => {
    models: [
      "",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "WD" => {
    models: [
      "My-Net-N600",
      "My-Net-N750",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "x86" => {
    models: [
      "64",
      "Generic",
      "Geode",
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
  "x86-64" => {
    models: [
      "Generic",
      "KVM",
      "VirtualBox",
      "VMware",
    ],
    extract_rev: lambda { |model, suffix| nil },
  },
  "Zyxel" => {
    models: [
      "nbg6716",
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
        #for debugging
        #puts "Checking prefix for "+name
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

      # sort_by erwartet einen block in dem auf jedes Element eine funktion angewendet wird: .length  
      #@prefixes = firmwares.keys.sort_by { |p| p.length }.reverse
      @prefixes = firmwares.keys.sort_by(&:length).reverse

      factory = get_files(FIRMWARE_BASE + "factory/")
      sysupgrade = get_files(FIRMWARE_BASE + "sysupgrade/")

      @prefixes.each do |prefix|
        # for debugging:
        #puts "Prefixes: " + prefix
      end

      factory.each do |href|
      	# for debugging:
      	#puts "search " + href
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
          puts "cannot assosiate sysupgrade "+href
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
