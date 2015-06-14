ffnord startseite
====================

Generic Homepage for FreiFunk Nord.

Dependencies
------------

* ruby

### Gems

* nokogiri
* jekyll
* json

On Ubuntu/Debian:

    sudo apt-get install ruby-nokogiri
    sudo gem install json jekyll

Customization
-------------
Fill out `_config.yml` and you should customize the text in the following files:

 * treffen.html
 * mitmachen.html
 * distributor.html

Before you deploy the included `impressum.html` please contact
the "Förderverein Freie Netzwerke e. V." and ask for their
permission to do so. Thanks.

Build
-----

Choose an arbitrary location for the checkout of this repository. For editing
above files, we suggest to create a new branch in your local git repository.
Patches local to your installation then remain in that branch, others commit
to your master branch and please push those back to the archive. 

The complete directory structure of what (under Debian/Ubuntu) should reside 
under `/path/to/www` will be built from the templates provided by

	jekyll build

so it is stored in the folder `_site` inside this repository. If
something analogous to `rm -r /path/to/www; mv _site /path/to/www` is not
possible, you may decided for something like

	(cd _site && tar cf - .)|(cd /path/to/www && sudo tar xf -)

to have the data transferred without deleting independent contributions.
Caveat: Ensure not to overwrite files you may have edited manually, e.g.
the _layouts/ffapi.json.

Site
----

The site doesn't run in a subdirectory, it only works correctly if it is
called via its own (sub)domain, so you have to configure your webserver to
route a domain on the site-path, otherwise the links to stylesheets, images,..
are not implemented correctly, for example in apache add this to your
sites-enabled:

	<VirtualHost *:80>
		ServerName freifunk.localhost
		DocumentRoot /path/to/www/
	</VirtualHost>

Or just start a SimpleHTTPServer with python:

    cd _site/
    python -m SimpleHTTPServer 8000
    
This will serve the `_site` folder on port http://localhost:8000


Aftermath
---------

There are several bits and pieces still missing after the installation of this
startseite:

 * map/graph/List from the ffnord/ffmap-d3 repository on github
 * integration of the www-providing machine with the batman-adv mesh
 * mailing lists and email setup in general
