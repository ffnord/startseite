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

Customization
-------------
You should customize text in the following files:

 * treffen.html
 * mitmachen.html
 * distributor.html

Before you deploy the included "impressum.html" please contact
the "Förderverein Freie Netzwerke e. V." and ask for their
permission to do so. Thanks.

Build
-----

Choose an arbitrary location for the checkout of this repository. For editing above files, we suggest to create a new branch in your local git repository. Patches local to your installation then remain in that branch, others commit to your master branch and please push those back to the archive. 

The complete directory structure of what (under Debian/Ubuntu) should reside under /var/www will be built from the templates provided by

	jekyll build

and is stored in the local folder "build". If something analogous to  "rm -r /var/www; mv build /var/www" is no possible, you may decided for something like

	(cd build && tar cf - .)|(cd /var/www && sudo tar xf -)

to have the data transferred without deleting independent contributions.

Aftermath
---------

There are several bits and pieces still missing after the installation of this startseite. 
 * map/graph/List from the ffnord/ffmap-d3 repository on github
 * integration of the www-providing machine with the batman-adv mesh
 * mailing lists and email setup in general
