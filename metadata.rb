name 'hf-lamp'
maintainer 'Hello Future Ltd'
maintainer_email 'andy@hellofutu.re'
license 'All rights reserved'
description 'Installs/Configures phpapp'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.18'

depends 'apache2', '1.8.14'
depends 'mysql', '4.1.2'
depends 'php', '1.4.6'
depends 'database', '1.4.0'
depends 'apt'
