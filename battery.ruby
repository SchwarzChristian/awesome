#!/usr/bin/ruby

s = `acpi`
puts /([^ ]*)%/.match(s)[1].to_i / 100.0
puts /%, (\d\d:\d\d)/.match(s)[1]
puts "true" if /Discharging/.match s

