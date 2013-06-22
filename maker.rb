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

require 'ftools'
require 'sqlite3'

if __FILE__ != $0
  puts 'Must run as separate file.  This is not a library!'
  exit
end

# "parse args"
$tmp_dir = '.gen'
$dst_dir = '/home/jamoozy/www/pv'

File.makedirs($tmp_dir) unless File.exists?($tmp_dir)
File.makedirs($dst_dir) unless File.exists?($dst_dir)
`cp icons/*.png .htaccess dbi.rb *.js style.css #$tmp_dir`

# Makes a page for an album according to the entry.
#   entry: And entry like what's described in the comments below.
def make_page(entry)
  # Check if DB already exists.  If not, create it.
  full_db_name = "#$tmp_dir/#{entry[:sln]}/comments.db"
  unless File.exists?(full_db_name)
    db = SQLite3::Database.new(full_db_name)
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
  end

  # Write HTML file.
  html_name = "#$tmp_dir/#{entry[:bname]}.html"
  `ln -s "#{entry[:loc]}" "#$tmp_dir/#{entry[:sln]}"` unless File.exists?("#$tmp_dir/#{entry[:sln]}")
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
    f.write("<li><span src=\"#{entry[:sln]}/#{image[1]}\"><img src=\"#{entry[:sln]}/#{image[0]}\"></span>")
  end
  f.write('</ul></div><div id="exit-bg"><div id="overlay"><div id="x"><img src="x.png""></div><div id="img-pane"><div id="left" class="navs"><img src="left-arrow.png"></div><div id="right" class="navs"><img src="right-arrow.png"></div><img id="image" src=""></div><div id="desc"></div><div id="comments"><ul></ul><div id="form">Leave a comment!<br>Name:<input size="30" value="" id="name" type="text"><br><textarea cols="34" rows="5" id="comment"></textarea><input type="button" id="submit" value="Submit"></div></div></div></div></body><html>')
  f.close
end

# List the entries in the main page.  Expected top-level keys:
#     title: Title of the album.
#     bname: Base name of the album's page.
#       sln: Sym-link to create to loc.
#       loc: Location on disk of the files.
#     thumb: Name of the thumbnail to display on the main page.
#    images: List of images in the album.  Each element in the list consists
#            of a thumbnail, an image, and a title for the image.
entries = [
  { :title => 'Engagement',
    :bname => 'engagement',
    :sln => 'engagement',
    :loc => '/home/jamoozy/Pictures/engagement',
    :thumb => 'thumb.jpg',
    :images => [
      ['IMG_0464-thumb.jpg', 'IMG_0464.jpg', "MIT Advertisement?"],
      ['IMG_0475-thumb.jpg', 'IMG_0475.jpg', "Framed Love"],
      ['IMG_0485-thumb.jpg', 'IMG_0485.jpg', "Mmmmm"],
      ['IMG_0500-thumb.jpg', 'IMG_0500.jpg', "A beautiful skyline."],
      ['IMG_0504-thumb.jpg', 'IMG_0504.jpg', "A beautiful couple."],
      ['IMG_0508-thumb.jpg', 'IMG_0508.jpg', "&mdash;"],
      ['IMG_0525-thumb.jpg', 'IMG_0525.jpg', "&mdash;"],
      ['IMG_0550-thumb.jpg', 'IMG_0550.jpg', "&lt;3"],
      ['IMG_0554-thumb.jpg', 'IMG_0554.jpg', "Climbing a tree."],
      ['IMG_0563-thumb.jpg', 'IMG_0563.jpg', "Tree Huggers"],
      ['IMG_0598-thumb.jpg', 'IMG_0598.jpg', "At the docks."],
      ['IMG_0601-thumb.jpg', 'IMG_0601.jpg', "Kissing at the docs."],
      ['IMG_0618-thumb.jpg', 'IMG_0618.jpg', "Dip"],
      ['IMG_0630-thumb.jpg', 'IMG_0630.jpg', "Doing math &amp; drawing."],
      ['IMG_0639-thumb.jpg', 'IMG_0639.jpg', "What have we proven?"],
      ['IMG_0648-thumb.jpg', 'IMG_0648.jpg', "Framed Love #2"],
      ['IMG_0652-thumb.jpg', 'IMG_0652.jpg', "Acorn St."],
      ['IMG_0666-thumb.jpg', 'IMG_0666.jpg', "Kiss."],
      ['IMG_0670-thumb.jpg', 'IMG_0670.jpg', "Chilling."],
      ['IMG_0683-thumb.jpg', 'IMG_0683.jpg', "Our Front Page Shot"],
      ['IMG_0685-thumb.jpg', 'IMG_0685.jpg', "Love."],
      ['IMG_0690-thumb.jpg', 'IMG_0690.jpg', "Our Save the Date"],
      ['IMG_0692-thumb.jpg', 'IMG_0692.jpg', "Alternate Shot"],
      ['IMG_0712-thumb.jpg', 'IMG_0712.jpg', "A pretty doorstep."],
      ['IMG_0732-thumb.jpg', 'IMG_0732.jpg', "<3"] ] },
  { :title => 'Maui Underwater',
    :bname => 'maui',
    :sln => 'maui',
    :loc => '/home/jamoozy/Pictures/maui',
    :thumb => 'thumb.jpg',
    :images => [
      ['01-thumb.jpg', '01.jpg', 'Cute!'],
      ['02-thumb.jpg', '02.jpg', "We're flying!"],
      ['03-thumb.jpg', '03.jpg', "We're 50 floors above the water"],
      ['04-thumb.jpg', '04.jpg', 'Ashley'],
      ['05-thumb.jpg', '05.jpg', 'Our feet.'],
      ['06-thumb.jpg', '06.jpg', 'Ashley & Maui'],
      ['07-thumb.jpg', '07.jpg', 'Maui'],
      ['08-thumb.jpg', '08.jpg', "Us&mdash;we're a UFO!"],
      ['09-thumb.jpg', '09.jpg', 'Scary!'],
      ['10-thumb.jpg', '10.jpg', 'Coming back to our boat.'],
      ['11-thumb.jpg', '11.jpg', 'Dolpins!  They were sleeping.'],
      ['12-thumb.jpg', '12.jpg', "Andrew, chilling with a turtle."],
      ['13-thumb.jpg', '13.jpg', "That's a turtle."],
      ['14-thumb.jpg', '14.jpg', "Needle Nose Fish"],
      ['15-thumb.jpg', '15.jpg', "Andrew dives deep."],
      ['16-thumb.jpg', '16.jpg', "Spinner dolphins (now awake)!"],
      ['17-thumb.jpg', '17.jpg', "Andrew snorkeling for the first time."],
      ['18-thumb.jpg', '18.jpg', "Andrew again."],
      ['19-thumb.jpg', '19.jpg', "Ashley diving."],
      ['20-thumb.jpg', '20.jpg', "Andrew."],
      ['21-thumb.jpg', '21.jpg', "Ashley's fin."],
      ['22-thumb.jpg', '22.jpg', "Andrew's in the BG."],
      ['23-thumb.jpg', '23.jpg', "Coral"],
      ['24-thumb.jpg', '24.jpg', "Coral with Hidden Fish"],
      ['25-thumb.jpg', '25.jpg', "Heading back to land."],
      ['26-thumb.jpg', '26.jpg', "But first, more dolphins!"] ] } ]

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
f.write("<!DOCTYPE html><html><head><meta charset='utf-8'><link rel='stylesheet' type='text/css' href='style.css'></head><body><div class='content'>#{content}</div></body></html>")
f.close

# Copy tmp dir to final location.
`rsync -avzP #$tmp_dir/ #$dst_dir/`
