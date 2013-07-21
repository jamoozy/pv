#!/usr/bin/ruby -w
#
# Copyright (c) 2013 Andrew "Jamoozy" Correa S.,
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

require 'ftools'
require 'cgi'

cgi = CGI.new
puts cgi.header('text/html')

unless cgi.params.include?('files[]')
  puts '{error:"files[] key missing"}';
  exit
end

$dname = "upload/#{Time.now}"
File.makedirs($dname) unless File.exists?($dname)
cgi.params['files[]'].each do |file|
  File.open("#$dname/#{file.original_filename}", 'w') do |f|
    f.write(file.readlines())
  end
end

puts '{status:"Success!  Andrew will review your files and post them soon."}'
