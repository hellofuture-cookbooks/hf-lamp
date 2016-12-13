#!/bin/sh

set -e

chef exec rubocop
chef exec foodcritic -t ~FC064 -t ~FC065 -t ~FC022 -f any .
chef exec rspec --color --format progress
chef exec kitchen test