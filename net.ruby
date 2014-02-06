#!/usr/bin/ruby

puts `cat /proc/net/dev`.scan /(#{ARGV[0] or '\w*'}):\s*(\d*)(?:\s*\d*){7}\s*(\d*)/
