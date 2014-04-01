hf-lamp
=======

Multi-site and vagrant compatible cookbook for PHP apache hosting

More docs and tests coming soon

Recipes
-------

###default

Sets up a server with Apache, MySQL and PHP on it. This is what you want to use if you're using this cookbook with Vagrant or on a single server.

###web

Sets up Apache and PHP. You'd use this recipe on a web server which doesn't need MySQL (or uses a MySQL server on a different box).

###web_dependencies

Installs the packages required for the **web** recipe. This recipe is included in the **web** recipe, you'd use this recipe if you needed to install all of the packages but didn't want to configure the web server. For example. if you were building a golden AMI image for auto-scaling.

###mysql_server

Sets up MySQL database for your sites in the sites data bag. *Currently only works on localhost, needs to be changed*

###mysql_dependencies

Installs the packages required for the **mysql_server** recipe. This recipe is included in the **web** recipe, you'd use this recipe if you need to install all of the packages but didn't want to configure the MySQL server. Again, if you were building a golden AMI image.

###php54

Installs PHP 5.4 from ondrej/php5-oldstable instead of 5.3. Only works on Ubuntu 12.04.

###htpasswds

Copies in a htpasswd file. A legacy recipe which will be removed.

