name             'hf-lamp'
maintainer       'Hello Future Ltd'
maintainer_email 'andy@hellofutu.re'
license          'All rights reserved'
description      'Installs/Configures phpapp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.8'

depends "apache2"
depends "mysql", '4.1.2'
depends "php"
depends "database"

suggests 'apt'