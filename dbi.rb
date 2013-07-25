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

require 'cgi'
require 'sqlite3'

cgi = CGI.new
puts cgi.header('text/html')

# Ensure cgi['dir'] exists.
unless cgi.params.include?('dir')
  puts '{error:"dir key missing"}'
  exit
end

# Try to open the DB.
begin
  $db = SQLite3::Database.new("#{cgi['dir']}/comments.db")
rescue SQLite3::CantOpenException => e
  str = e.to_s.gsub(/'/, "\\'")
  puts "{error:'#{str}'}"
end

# Convenience function to escape quotes.
def jsonize(str) ; str.gsub(/\\/,'\\\\').gsub(/"/, '\\"') ; end

# Do a title & comments fetch.
if cgi['type'] == 'fetch' then
  print '{'
  $db.execute("select id,title from images where name=?", [cgi['img']]) do |row|
    $id = row[0]
    print "title:\"#{row[1]}\","
  end

  print 'comments:"'
  $db.execute("select name,comment from comments where img_id=?", [$id]) do |row|
    print "<li><span class='name'>#{jsonize(row[0])}</span><span class='comment'>#{jsonize(row[1])}</span></li>"
  end
  puts '"}'

# Place a new comment into the DB.
elsif cgi['type'] == 'put' then
  unless cgi.params.include? 'img'
    puts "{error:'No \"img\" key.}"
    exit
  end

  unless cgi.params.include? 'name'
    puts "{error:'No \"name\" key.}"
    exit
  end

  unless cgi.params.include? 'comment'
    puts "{error:'No \"comment\" key.}"
    exit
  end

  begin
    $db.execute("select id from images where name=?", [cgi['img']]) do |row|
      $id = row[0]
    end
  rescue SQLite3::CantOpenException => e
    puts "{error:'#{e}',query:\"select id from images where name='#{cgi['img']}'\"}"
  end

  begin
    $db.execute("insert into comments
                  (name, comment, utime, ip, img_id)
                values
                  (?, ?, ?, ?, ?)",
               [cgi['name'], cgi['comment'], Time.now.to_i, cgi.remote_addr, $id])
  rescue SQLite3::CantOpenException => e
    puts "{error:'#{e}',query:\"insert into comments (name, comment, utime, ip, img_id) values (#{cgi['name']}, #{cgi['comment']}, #{Time.now.to_i}, #{ cgi.remote_addr}, #$id)\"}"
  end
else
  puts '{error:"type missing"}'
end
