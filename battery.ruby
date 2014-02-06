#!/usr/bin/ruby

s = `acpi`
puts /([^ ]*)%/.match(s)[1].to_i / 100.0
puts "true" if /Discharging/.match s

