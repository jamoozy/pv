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

if ARGV.size != 1
  STDERR.puts "Usage: #$0 [fname]"
  STDERR.puts "  Where [fname] is the name of the file to generate data for."
  exit 1
end

$fname = ARGV[0]

puts "  - - thumbs/#$fname"
puts "    - #$fname"
puts '    - ""'
