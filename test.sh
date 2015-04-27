#!/bin/sh

set -e

chef exec foodcritic -f any .
chef exec rspec --color --format progress
chef exec rubocop
chef exec kitchen test