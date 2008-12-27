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

EXTS = %w(avi srt mpeg xvid)

renames = {}
prefix = nil
season = 1

begin
  EXTS.each do |ext|
    files = Dir.glob("*.#{ext}").sort
    next if files.empty?

    puts "Found #{files.size} #{ext} files"

    first_title = files.first.gsub(/\.[a-z]+$/, '')
    prefix_match = first_title.match(/^[^0-9]+[a-z]/i)
    prefix_guess = !prefix_match.nil? && prefix_match[0] != "" ? prefix_match[0] : prefix
    prefix = ask("Prefix? ") { |q|
      q.default = prefix_guess if prefix_guess
    }

    season_match = first_title.match(/[1-9]/)
    season_guess = !season_match.nil? && season_match[0] != '0' ? season_match[0].to_i : season
    season = ask("Season? ", Integer) { |q|
      q.default = season_guess
      q.in = 1..900
    }

    files.each do |file|
      number_match = file.sub(season.to_s, '').match(/[1-9][0-9]*/)
      number_guess = !number_match.nil? ? number_match[0].to_i : 0
      number = ask("Episode number for \"#{file}\"? (0 to skip) ", Integer) { |q|
        q.default = number_guess
        q.in = 0..900
      }
      next if number == 0
      title = "%s-%s%02i" % [prefix, season, number]
      renames["#{title}.#{ext}"] = file
    end

  end

  renames = renames.select { |to, from| to != from }.sort
  abort "No files to rename found!" if renames.empty?

  puts "About to rename:"
  renames.each { |to, from| puts "#{to} (#{from})" }

  exit unless agree "Really rename all files? "
  renames.each { |to, from| FileUtils.mv(from, to) }

rescue EOFError
  abort "\n^D"
rescue Interrupt
  abort "\n^C"
end
