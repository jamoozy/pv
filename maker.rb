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

require 'yaml'
require 'ftools'
require 'sqlite3'

if __FILE__ != $0
  puts 'Must run as separate file.  This is not a library!'
  exit
end

# "parse args"
$tmp_dir = '.gen'
$dst_dir = '/home/jamoozy/www/pv'
$entries_yaml = 'entries.yaml'

File.makedirs($tmp_dir) unless File.exists?($tmp_dir)
File.makedirs($dst_dir) unless File.exists?($dst_dir)
`cp icons/*.png .htaccess dbi.rb *.js style.css #$tmp_dir`

# Makes a page for an album according to the entry.
#   entry: And entry like what's described in the comments below.
def make_page(entry)
  `ln -s "#{entry[:loc]}" "#$tmp_dir/#{entry[:sln]}"` unless File.exists?("#$tmp_dir/#{entry[:sln]}")

  # Check if DB already exists.  If not, create it.
  full_db_name = "#$tmp_dir/#{entry[:sln]}/comments.db"
  unless File.exists?(full_db_name)
    begin
      db = SQLite3::Database.new(full_db_name)
    rescue SQLite3::CantOpenException => e
      puts "Can't open db: ", full_db_name
    end
    db.execute("create table images (
                  id integer primary key,
                  name text,
                  title text
                )")
    db.execute("create table comments (
                  id integer primary key,
                  name text,
                  comment text,
                  utime datetime,
                  ip text,
                  img_id integer,
                  foreign key(img_id) references images(id)
                )")

    # Initial entries for all the images.
    db.transaction
    entry[:images].each do |img|
      db.execute('insert into images (name,title) values (?,?)', [img[1], img[2]])
    end
    db.commit

    # Set the right permissions for the webserver to handle the DB & prompt
    # the user to run the chown on the DB and its directory.
    `chmod 664 #{full_db_name}`
    puts "Please run \"sudo chown :www-data #{full_db_name} && sudo chown :www-data #$tmp_dir/#{entry[:sln]}\""
  else
    begin
      db = SQLite3::Database.new(full_db_name)
    rescue SQLite3::CantOpenException => e
      puts "Can't open db: ", full_db_name
    end

    # Make sure all the images' titles are up to date.
    entry[:images].each do |img|
      r = db.execute('select * from images where name=?', [img[1]])
      if !r || r.size < 1
#        puts "inserting img #{img[1]}"
        db.execute('insert into images (name,title) values (?,?)', [img[1], img[2]])
      elsif r.size > 1
        puts "Error: got #{r.size} results for img #{img[1]}"
      elsif r[0][2] != img[2]
#        puts "Updating #{img[1]} title to \"#{img[2]}\""
        db.execute('update images set title=? where id=?', [img[2], r[0][0]])
#      else
#        puts "#{img[1]} has an updaetd title."
      end
    end
  end

  # Write HTML file.
  html_name = "#$tmp_dir/#{entry[:bname]}.html"
  f = File.new(html_name, 'w')
  f.write('<!DOCTYPE html>')
  f.write('<html><head>')
  f.write('<meta charset="utf-8">')
  f.write("<title>#{entry[:title]}</title>")
  f.write('<link rel="stylesheet" type="text/css" href="style.css">')
  f.write('<script src="jquery-1.10.1.min.js" type="text/javascript"></script>')
  f.write('<script src="photos.js" type="text/javascript"></script>')
  f.write('</head><body><h1>')
  f.write(entry[:title])
  f.write('</h1><div class="content"><ul>')
  entry[:images].each do |image|
    f.write("<li><span src=\"#{entry[:sln]}/#{image[1]}\"><img src=\"#{entry[:sln]}/#{image[0]}\" title=\"#{image[1]}\"><div class=\"fname\">#{image[1]}</div></span>")
  end
  f.write('</ul></div><div id="exit-bg"><div id="overlay"><div id="x"><img src="x.png""></div><div id="img-pane"><div id="left" class="navs"><img src="left-arrow.png"></div><div id="right" class="navs"><img src="right-arrow.png"></div><img id="image" src=""></div><div id="desc"></div><div id="comments"><ul class="comments-list"></ul><div id="form">Leave a comment!<br>Name:<input size="30" value="" id="name" type="text"><br><textarea cols="34" rows="5" id="comment"></textarea><input type="button" id="submit" value="Submit"></div></div></div></div></body><html>')
  f.close
end

# Load entries from the yaml file.
entries = File.open($entries_yaml) {|f| YAML.load(f)}

# Generate the list of albums for the main page.
content = '<ul>'
entries.each do |entry|
  html_name = "#{entry[:bname]}.html"
  content << "<li><a href=\"#{html_name}\"><img src=\"#{entry[:sln]}/#{entry[:thumb]}\"><br>#{entry[:title]}</a>"
  make_page(entry)
end
content << '</ul>'

# Write index.html with the above content.
f = File.new("#$tmp_dir/index.html", 'w')
f.write("<!DOCTYPE html><html><head><meta charset='utf-8'><link rel='stylesheet' type='text/css' href='style.css'></head><body><h1>Ashley &amp; Andrew</h1><p>Please feel free to leave comments ^_^</p><div class='content'>#{content}</div></body></html>")
f.close

# Copy tmp dir to final location.
`rsync -avzP #$tmp_dir/ #$dst_dir/`
