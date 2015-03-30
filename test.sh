#!/bin/sh

chef exec foodcritic -f any .
chef exec rspec --color --format progress
chef exec rubocop
