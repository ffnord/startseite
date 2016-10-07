Startseite der Community Gotham City.
=======================================

Webseite: http://gotham.freifunk.net

Um einen Blog Beitrag zu erstellen brauchst du keine weitere Software. Das Blog kannst du **direkt im Browser [hier auf Github](https://github.com/ deine community hier /_posts) bearbeiten**. 

Um die Hauptseiten zu bearbeiten, clone dises Repository und installiere ein paar Abhängigkeiten, dann kannst du auch bei dir lokal eine Kopie erstellen und testen:

Dependencies
------------

* ruby

### Gems

* nokogiri
* jekyll
* json

On Ubuntu/Debian:

    sudo apt-get install ruby-nokogiri ruby-dev
    sudo gem install json jekyll

Customization
-------------
Customize the text/configuration in the following files:

 * `_config.yml`
 * `treffen.html`
 * `mitmachen.html`
 * `distributor.html`
 * `_plugins/firmwares.rb`

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

Site
----

The site doesn't run in a subdirectory, it only works correctly if it is
called via its own (sub)domain, so you have to configure your webserver to
route a domain on the site-path, otherwise the links to stylesheets, images,..
are not implemented correctly.

Example Configurations
----------------------

# Apache 2

Add this to your `/etc/apache2/sites-enabled/`:

	<VirtualHost *:80>
		ServerName freifunk.localhost
		DocumentRoot /path/to/www
	</VirtualHost>

# nginx

	server {
	    listen   80;
	    server_name freifunk.localhost fflocal;
		root /path/to/www;
		index index.html index.php;

		location / {
			try_files $uri $uri/ =404;
		}
		location ~ /\.ht {
			deny all;
		}
	}


# SimpleHTTPServer

For development, you can just start a SimpleHTTPServer with python:

    cd _site/
    python -m SimpleHTTPServer 8000
    
This will serve the `_site` folder on port http://localhost:8000


Aftermath
---------

There are several bits and pieces still missing after the installation of this
startseite:

 * [meshviewer](https://github.com/ffnord/meshviewer) or [HopGlass](https://github.com/plumpudding/hopglass) from github
 * integration of the www-providing machine with the batman-adv mesh
 * mailing lists and email setup in general
 * optionally exclude the blog in an external repository like in Freifunk Nord or customize this completely so the Community can add blog articles more easily
