#!/usr/bin/ruby -w
#
# Copyright (c) 2013-2015 Andrew "Jamoozy" C. Sabisch,
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

# Ensure we're not being "required" (included?).
if __FILE__ != $0
  STDERR.puts "This script (#{__FILE__}) meant only to be run as main."
  exit -1
end

# Usage
if ARGV.size != 1
  STDERR.puts "Usage: #$0 [fname]"
  STDERR.puts "  Where [fname] is the name of the file to generate data for."
  exit 1
end

# "Parse" args.
$fname = ARGV[0]

puts "  - - thumbs/#$fname"
puts "    - #$fname"
puts '    - ""'
