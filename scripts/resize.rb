#!/usr/bin/ruby -w
#
# Copyright (c) 2013 Andrew "Jamoozy" Correa,
# 
# This file is part of Picture Viewer.
# 
# Picture Viewer is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Ensure right amount of args.
if ARGV.size != 3
  puts "usage: #$0 [file] [size] [dst]"
  puts "  [file] is the name of the file to resize."
  puts "  [size] is the max width & height."
  puts "  [dst] is the destination directory."
  exit 1
end

# "Parse" args.
$src = ARGV[0]
$size = ARGV[1]
$dst = ARGV[2] + "/#$src"

# Ensure this doesn't already exist.
if File.exists?($dst)
  puts "#$dst already exists.  Skipping."
  exit 2
end

# Check if we're doing width or height.
`identify #$src` =~ /(\d+)x(\d+)/
w,h = $1,$2

if w > h
  puts "[#$src] landscape"
  `convert #$src -resize #{$size}x #$dst`
else
  puts "[#$src] portrait"
  `convert #$src -resize x#$size #$dst`
end
