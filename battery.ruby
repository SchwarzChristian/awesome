#!/usr/bin/ruby

puts `acpi`.scan /: (\w*), (\d*)%(?:, (\d\d:\d\d))?/
