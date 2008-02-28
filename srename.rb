#!/usr/bin/ruby
# srename.rb - Quickly rename tv series
# 
# Copyright 2008 Sunny Ripert <sunny@sunfox.org>
# Original python version by Antoine 'NaPs' Millet <antoine@inaps.org>
# This is just a ripoff of that good idea of his.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

require 'rubygems'
require 'highline/import'
require 'fileutils'

files = Dir.glob('*.avi').sort
abort "Error: no .avi found!" if files.size == 0

first_title = files.first.gsub(/\.[a-z]+$/, '')
prefix_guess = first_title.match(/^[^0-9]+[a-z]/i)[0] rescue ""
prefix = ask("Prefix? ") { |q|
  q.default = prefix_guess if prefix_guess != ""
}

season_guess = first_title.match(/[1-9]/)[0].to_i rescue 1
season = ask("Season? ", Integer) { |q|
  q.default = season_guess == 0 ? 1 : season_guess
  q.in = 1..900
}

renames = {}
files.each do |file|
  number_guess = file.sub(season.to_s, '').match(/[1-9][0-9]*/)[0].to_i rescue 0
  number = ask("Episode number for \"#{file}\" (0 to skip) ? ", Integer) { |q|
    q.default = number_guess
    q.in = 0..900
  }
  next if number == 0
  title = "%s-%s%02i" % [prefix, season, number]
  subf = file.gsub(/avi$/, 'srt')
  renames["#{title}.avi"] = file
  renames["#{title}.srt"] = subf if File.file?(subf)
end

puts "About to rename:"
renames = renames.to_a.sort
renames.each { |to, from| puts "#{to} (#{from})" }

exit unless agree "Really rename all files? "
renames.each { |to, from|
  FileUtils.mv(from, to) unless from == to
}

