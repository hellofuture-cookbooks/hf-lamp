#!/bin/sh

set -e

chef exec rubocop
chef exec foodcritic -f any .
chef exec rspec --color --format progress
chef exec kitchen test