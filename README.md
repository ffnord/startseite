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

### Perl 
For parsing the gluon site.conf we also need perl
and the following perl module:

 * perl-json

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

	jekyll build
