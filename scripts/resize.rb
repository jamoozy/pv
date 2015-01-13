#!/usr/bin/ruby -w
#
# Copyright (c) 2015 Andrew "Jamoozy" C. Sabisch,
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


# Ensure we're not being "required" (imported?).
if __FILE__ != $0
  STDERR.puts "This script (#{__FILE__}) meant only to be run as main."
  exit -1
end


# Ensure right amount of args.
if ARGV.size != 3
  puts "usage: #$0 [file] [size] [dst]"
  puts "  [file] is the name of the file to resize."
  puts "  [size] is the max width / height."
  puts "  [dst] is the destination directory."
  exit 1
end

# "Parse" args.
$src = ARGV[0]
$size = ARGV[1]
$dst = ARGV[2] + "/#$src"

def run_cmd(cmd)
  puts "running #{cmd}"
  `#{cmd}`
end

# Ensure this doesn't already exist.
if File.exists?($dst)
  puts "#$dst already exists.  Skipping."
else
  # Check if we're doing width or height, and rotate.
  /(\d+)x(\d+)/ =~ `identify #$src`
  w,h = $1.to_i,$2.to_i
  if w > h
    STDOUT.write("[#$src] landscape ... ")
    run_cmd("convert #$src -resize #{$size}x #$dst")
  else
    STDOUT.write("[#$src] portrait ... ")
    run_cmd("convert #$src -resize x#$size #$dst")
  end
end

# Check Exif metadata to see if this needs rotating.
o = `identify -format "%[exif:orientation]" #$dst`.to_i

puts "have orientation: #{o}"
case o
when 6
  puts("mogrify -rotate 90 #$dst")
when 8
  puts("mogrify -rotate 270 #$dst")
when 3
  puts("mogrify -rotate 180 #$dst")
end
