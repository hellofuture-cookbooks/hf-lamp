#!/bin/sh

bundle exec foodcritic -f any .
bundle exec rspec --color --format progress
bundle exec rubocop