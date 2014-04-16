require 'json'

module Jekyll
  class GluonSite < Generator
    def generate(site)
      class << site
        attr_accessor :gluon_site
        def site_payload
          result = super
          result["site"]["gluon_site"] = self.gluon_site
          result
        end
      end

      siteconf = File.read(File.join(site.config['firmware']['gluon_site_dir'],'site.conf'))

      # Perl Code for converting perl datastruct from site.conf
      # into JSON. So we can evaluate it properly. 
      perlcode = "
        use JSON;
        \\$site = #{siteconf};
        \\$json = JSON->new->allow_nonref;

        \\$json_text = \\$json->encode( \\$site );
        print \\$json_text;
        "
      # Evaluate perl code and then parse resulting
      perleval = %x[/usr/bin/perl -e "#{perlcode}"]
      parsedsite = JSON.parse(perleval)

      site.gluon_site = parsedsite
    end
  end
end
