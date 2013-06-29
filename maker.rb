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
    :loc => '/home/media/pictures/aa-engagement',
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
    :loc => '/home/media/pictures/aa-maui-wpc',
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
      ['26-thumb.jpg', '26.jpg', "But first, more dolphins!"] ] },
  { :title => 'Photobooth',
    :bname => 'photobooth',
    :sln => 'photobooth',
    :loc => '/home/media/pictures/aa-photobooth',
    :thumb => 'thumb.jpg',
    :images => [
      [ 'thumbs/IMG_0009.JPG', 'IMG_0009.JPG', '' ],
      [ 'thumbs/IMG_0010.JPG', 'IMG_0010.JPG', '' ],
      [ 'thumbs/IMG_0011.JPG', 'IMG_0011.JPG', '' ],
      [ 'thumbs/IMG_0012.JPG', 'IMG_0012.JPG', '' ],
      [ 'thumbs/IMG_0013.JPG', 'IMG_0013.JPG', '' ],
      [ 'thumbs/IMG_0014.JPG', 'IMG_0014.JPG', '' ],
      [ 'thumbs/IMG_0015.JPG', 'IMG_0015.JPG', '' ],
      [ 'thumbs/IMG_0016.JPG', 'IMG_0016.JPG', '' ],
      [ 'thumbs/IMG_0017.JPG', 'IMG_0017.JPG', '' ],
      [ 'thumbs/IMG_0018.JPG', 'IMG_0018.JPG', '' ],
      [ 'thumbs/IMG_0019.JPG', 'IMG_0019.JPG', '' ],
      [ 'thumbs/IMG_0020.JPG', 'IMG_0020.JPG', '' ],
      [ 'thumbs/IMG_0021.JPG', 'IMG_0021.JPG', '' ],
      [ 'thumbs/IMG_0022.JPG', 'IMG_0022.JPG', '' ],
      [ 'thumbs/IMG_0023.JPG', 'IMG_0023.JPG', '' ],
      [ 'thumbs/IMG_0024.JPG', 'IMG_0024.JPG', '' ],
      [ 'thumbs/IMG_0025.JPG', 'IMG_0025.JPG', '' ],
      [ 'thumbs/IMG_0026.JPG', 'IMG_0026.JPG', '' ],
      [ 'thumbs/IMG_0027.JPG', 'IMG_0027.JPG', '' ],
      [ 'thumbs/IMG_0028.JPG', 'IMG_0028.JPG', '' ],
      [ 'thumbs/IMG_0029.JPG', 'IMG_0029.JPG', '' ],
      [ 'thumbs/IMG_0030.JPG', 'IMG_0030.JPG', '' ],
      [ 'thumbs/IMG_0031.JPG', 'IMG_0031.JPG', '' ],
      [ 'thumbs/IMG_0032.JPG', 'IMG_0032.JPG', '' ],
      [ 'thumbs/IMG_0033.JPG', 'IMG_0033.JPG', '' ],
      [ 'thumbs/IMG_0034.JPG', 'IMG_0034.JPG', '' ],
      [ 'thumbs/IMG_0035.JPG', 'IMG_0035.JPG', '' ],
      [ 'thumbs/IMG_0036.JPG', 'IMG_0036.JPG', '' ],
      [ 'thumbs/IMG_0037.JPG', 'IMG_0037.JPG', '' ],
      [ 'thumbs/IMG_0038.JPG', 'IMG_0038.JPG', '' ],
      [ 'thumbs/IMG_0039.JPG', 'IMG_0039.JPG', '' ],
      [ 'thumbs/IMG_0040.JPG', 'IMG_0040.JPG', '' ],
      [ 'thumbs/IMG_0041.JPG', 'IMG_0041.JPG', '' ],
      [ 'thumbs/IMG_0042.JPG', 'IMG_0042.JPG', '' ],
      [ 'thumbs/IMG_0043.JPG', 'IMG_0043.JPG', '' ],
      [ 'thumbs/IMG_0044.JPG', 'IMG_0044.JPG', '' ],
      [ 'thumbs/IMG_0045.JPG', 'IMG_0045.JPG', '' ],
      [ 'thumbs/IMG_0046.JPG', 'IMG_0046.JPG', '' ],
      [ 'thumbs/IMG_0047.JPG', 'IMG_0047.JPG', '' ],
      [ 'thumbs/IMG_0048.JPG', 'IMG_0048.JPG', '' ],
      [ 'thumbs/IMG_0049.JPG', 'IMG_0049.JPG', '' ],
      [ 'thumbs/IMG_0050.JPG', 'IMG_0050.JPG', '' ],
      [ 'thumbs/IMG_0051.JPG', 'IMG_0051.JPG', '' ],
      [ 'thumbs/IMG_0052.JPG', 'IMG_0052.JPG', '' ],
      [ 'thumbs/IMG_0053.JPG', 'IMG_0053.JPG', '' ],
      [ 'thumbs/IMG_0054.JPG', 'IMG_0054.JPG', '' ],
      [ 'thumbs/IMG_0055.JPG', 'IMG_0055.JPG', '' ],
      [ 'thumbs/IMG_0056.JPG', 'IMG_0056.JPG', '' ],
      [ 'thumbs/IMG_0057.JPG', 'IMG_0057.JPG', '' ],
      [ 'thumbs/IMG_0058.JPG', 'IMG_0058.JPG', '' ],
      [ 'thumbs/IMG_0059.JPG', 'IMG_0059.JPG', '' ],
      [ 'thumbs/IMG_0060.JPG', 'IMG_0060.JPG', '' ],
      [ 'thumbs/IMG_0061.JPG', 'IMG_0061.JPG', '' ],
      [ 'thumbs/IMG_0062.JPG', 'IMG_0062.JPG', '' ],
      [ 'thumbs/IMG_0063.JPG', 'IMG_0063.JPG', '' ],
      [ 'thumbs/IMG_0064.JPG', 'IMG_0064.JPG', '' ],
      [ 'thumbs/IMG_0065.JPG', 'IMG_0065.JPG', '' ],
      [ 'thumbs/IMG_0066.JPG', 'IMG_0066.JPG', '' ],
      [ 'thumbs/IMG_0067.JPG', 'IMG_0067.JPG', '' ],
      [ 'thumbs/IMG_0068.JPG', 'IMG_0068.JPG', '' ],
      [ 'thumbs/IMG_0069.JPG', 'IMG_0069.JPG', '' ],
      [ 'thumbs/IMG_0070.JPG', 'IMG_0070.JPG', '' ],
      [ 'thumbs/IMG_0071.JPG', 'IMG_0071.JPG', '' ],
      [ 'thumbs/IMG_0072.JPG', 'IMG_0072.JPG', '' ],
      [ 'thumbs/IMG_0073.JPG', 'IMG_0073.JPG', '' ],
      [ 'thumbs/IMG_0074.JPG', 'IMG_0074.JPG', '' ],
      [ 'thumbs/IMG_0075.JPG', 'IMG_0075.JPG', '' ],
      [ 'thumbs/IMG_0076.JPG', 'IMG_0076.JPG', '' ],
      [ 'thumbs/IMG_0077.JPG', 'IMG_0077.JPG', '' ],
      [ 'thumbs/IMG_0078.JPG', 'IMG_0078.JPG', '' ],
      [ 'thumbs/IMG_0079.JPG', 'IMG_0079.JPG', '' ],
      [ 'thumbs/IMG_0080.JPG', 'IMG_0080.JPG', '' ],
      [ 'thumbs/IMG_0081.JPG', 'IMG_0081.JPG', '' ],
      [ 'thumbs/IMG_0082.JPG', 'IMG_0082.JPG', '' ],
      [ 'thumbs/IMG_0083.JPG', 'IMG_0083.JPG', '' ],
      [ 'thumbs/IMG_0084.JPG', 'IMG_0084.JPG', '' ],
      [ 'thumbs/IMG_0085.JPG', 'IMG_0085.JPG', '' ],
      [ 'thumbs/IMG_0086.JPG', 'IMG_0086.JPG', '' ],
      [ 'thumbs/IMG_0087.JPG', 'IMG_0087.JPG', '' ],
      [ 'thumbs/IMG_0088.JPG', 'IMG_0088.JPG', '' ],
      [ 'thumbs/IMG_0089.JPG', 'IMG_0089.JPG', '' ],
      [ 'thumbs/IMG_0090.JPG', 'IMG_0090.JPG', '' ],
      [ 'thumbs/IMG_0091.JPG', 'IMG_0091.JPG', '' ],
      [ 'thumbs/IMG_0092.JPG', 'IMG_0092.JPG', '' ],
      [ 'thumbs/IMG_0093.JPG', 'IMG_0093.JPG', '' ],
      [ 'thumbs/IMG_0094.JPG', 'IMG_0094.JPG', '' ],
      [ 'thumbs/IMG_0095.JPG', 'IMG_0095.JPG', '' ],
      [ 'thumbs/IMG_0096.JPG', 'IMG_0096.JPG', '' ],
      [ 'thumbs/IMG_0097.JPG', 'IMG_0097.JPG', '' ],
      [ 'thumbs/IMG_0098.JPG', 'IMG_0098.JPG', '' ],
      [ 'thumbs/IMG_0099.JPG', 'IMG_0099.JPG', '' ],
      [ 'thumbs/IMG_0100.JPG', 'IMG_0100.JPG', '' ],
      [ 'thumbs/IMG_0101.JPG', 'IMG_0101.JPG', '' ],
      [ 'thumbs/IMG_0102.JPG', 'IMG_0102.JPG', '' ],
      [ 'thumbs/IMG_0103.JPG', 'IMG_0103.JPG', '' ],
      [ 'thumbs/IMG_0104.JPG', 'IMG_0104.JPG', '' ],
      [ 'thumbs/IMG_0105.JPG', 'IMG_0105.JPG', '' ],
      [ 'thumbs/IMG_0106.JPG', 'IMG_0106.JPG', '' ],
      [ 'thumbs/IMG_0107.JPG', 'IMG_0107.JPG', '' ],
      [ 'thumbs/IMG_0108.JPG', 'IMG_0108.JPG', '' ],
      [ 'thumbs/IMG_0109.JPG', 'IMG_0109.JPG', '' ],
      [ 'thumbs/IMG_0110.JPG', 'IMG_0110.JPG', '' ],
      [ 'thumbs/IMG_0111.JPG', 'IMG_0111.JPG', '' ],
      [ 'thumbs/IMG_0112.JPG', 'IMG_0112.JPG', '' ],
      [ 'thumbs/IMG_0113.JPG', 'IMG_0113.JPG', '' ],
      [ 'thumbs/IMG_0114.JPG', 'IMG_0114.JPG', '' ],
      [ 'thumbs/IMG_0115.JPG', 'IMG_0115.JPG', '' ],
      [ 'thumbs/IMG_0116.JPG', 'IMG_0116.JPG', '' ],
      [ 'thumbs/IMG_0117.JPG', 'IMG_0117.JPG', '' ],
      [ 'thumbs/IMG_0118.JPG', 'IMG_0118.JPG', '' ],
      [ 'thumbs/IMG_0119.JPG', 'IMG_0119.JPG', '' ],
      [ 'thumbs/IMG_0120.JPG', 'IMG_0120.JPG', '' ],
      [ 'thumbs/IMG_0121.JPG', 'IMG_0121.JPG', '' ],
      [ 'thumbs/IMG_0122.JPG', 'IMG_0122.JPG', '' ],
      [ 'thumbs/IMG_0123.JPG', 'IMG_0123.JPG', '' ],
      [ 'thumbs/IMG_0124.JPG', 'IMG_0124.JPG', '' ],
      [ 'thumbs/IMG_0125.JPG', 'IMG_0125.JPG', '' ],
      [ 'thumbs/IMG_0126.JPG', 'IMG_0126.JPG', '' ],
      [ 'thumbs/IMG_0127.JPG', 'IMG_0127.JPG', '' ],
      [ 'thumbs/IMG_0128.JPG', 'IMG_0128.JPG', '' ],
      [ 'thumbs/IMG_0129.JPG', 'IMG_0129.JPG', '' ],
      [ 'thumbs/IMG_0130.JPG', 'IMG_0130.JPG', '' ],
      [ 'thumbs/IMG_0131.JPG', 'IMG_0131.JPG', '' ],
      [ 'thumbs/IMG_0132.JPG', 'IMG_0132.JPG', '' ],
      [ 'thumbs/IMG_0133.JPG', 'IMG_0133.JPG', '' ],
      [ 'thumbs/IMG_0134.JPG', 'IMG_0134.JPG', '' ],
      [ 'thumbs/IMG_0135.JPG', 'IMG_0135.JPG', '' ],
      [ 'thumbs/IMG_0136.JPG', 'IMG_0136.JPG', '' ],
      [ 'thumbs/IMG_0137.JPG', 'IMG_0137.JPG', '' ],
      [ 'thumbs/IMG_0138.JPG', 'IMG_0138.JPG', '' ],
      [ 'thumbs/IMG_0139.JPG', 'IMG_0139.JPG', '' ],
      [ 'thumbs/IMG_0140.JPG', 'IMG_0140.JPG', '' ],
      [ 'thumbs/IMG_0141.JPG', 'IMG_0141.JPG', '' ],
      [ 'thumbs/IMG_0142.JPG', 'IMG_0142.JPG', '' ],
      [ 'thumbs/IMG_0143.JPG', 'IMG_0143.JPG', '' ],
      [ 'thumbs/IMG_0144.JPG', 'IMG_0144.JPG', '' ],
      [ 'thumbs/IMG_0145.JPG', 'IMG_0145.JPG', '' ],
      [ 'thumbs/IMG_0146.JPG', 'IMG_0146.JPG', '' ],
      [ 'thumbs/IMG_0147.JPG', 'IMG_0147.JPG', '' ],
      [ 'thumbs/IMG_0148.JPG', 'IMG_0148.JPG', '' ],
      [ 'thumbs/IMG_0149.JPG', 'IMG_0149.JPG', '' ],
      [ 'thumbs/IMG_0150.JPG', 'IMG_0150.JPG', '' ],
      [ 'thumbs/IMG_0151.JPG', 'IMG_0151.JPG', '' ],
      [ 'thumbs/IMG_0152.JPG', 'IMG_0152.JPG', '' ],
      [ 'thumbs/IMG_0153.JPG', 'IMG_0153.JPG', '' ],
      [ 'thumbs/IMG_0154.JPG', 'IMG_0154.JPG', '' ],
      [ 'thumbs/IMG_0155.JPG', 'IMG_0155.JPG', '' ],
      [ 'thumbs/IMG_0156.JPG', 'IMG_0156.JPG', '' ],
      [ 'thumbs/IMG_0157.JPG', 'IMG_0157.JPG', '' ],
      [ 'thumbs/IMG_0158.JPG', 'IMG_0158.JPG', '' ],
      [ 'thumbs/IMG_0159.JPG', 'IMG_0159.JPG', '' ],
      [ 'thumbs/IMG_0160.JPG', 'IMG_0160.JPG', '' ],
      [ 'thumbs/IMG_0161.JPG', 'IMG_0161.JPG', '' ],
      [ 'thumbs/IMG_0162.JPG', 'IMG_0162.JPG', '' ],
      [ 'thumbs/IMG_0163.JPG', 'IMG_0163.JPG', '' ],
      [ 'thumbs/IMG_0164.JPG', 'IMG_0164.JPG', '' ],
      [ 'thumbs/IMG_0165.JPG', 'IMG_0165.JPG', '' ],
      [ 'thumbs/IMG_0166.JPG', 'IMG_0166.JPG', '' ],
      [ 'thumbs/IMG_0167.JPG', 'IMG_0167.JPG', '' ],
      [ 'thumbs/IMG_0168.JPG', 'IMG_0168.JPG', '' ],
      [ 'thumbs/IMG_0169.JPG', 'IMG_0169.JPG', '' ],
      [ 'thumbs/IMG_0170.JPG', 'IMG_0170.JPG', '' ],
      [ 'thumbs/IMG_0171.JPG', 'IMG_0171.JPG', '' ],
      [ 'thumbs/IMG_0172.JPG', 'IMG_0172.JPG', '' ],
      [ 'thumbs/IMG_0173.JPG', 'IMG_0173.JPG', '' ],
      [ 'thumbs/IMG_0174.JPG', 'IMG_0174.JPG', '' ],
      [ 'thumbs/IMG_0175.JPG', 'IMG_0175.JPG', '' ],
      [ 'thumbs/IMG_0176.JPG', 'IMG_0176.JPG', '' ],
      [ 'thumbs/IMG_0177.JPG', 'IMG_0177.JPG', '' ],
      [ 'thumbs/IMG_0178.JPG', 'IMG_0178.JPG', '' ],
      [ 'thumbs/IMG_0179.JPG', 'IMG_0179.JPG', '' ],
      [ 'thumbs/IMG_0180.JPG', 'IMG_0180.JPG', '' ],
      [ 'thumbs/IMG_0181.JPG', 'IMG_0181.JPG', '' ],
      [ 'thumbs/IMG_0182.JPG', 'IMG_0182.JPG', '' ],
      [ 'thumbs/IMG_0183.JPG', 'IMG_0183.JPG', '' ],
      [ 'thumbs/IMG_0184.JPG', 'IMG_0184.JPG', '' ],
      [ 'thumbs/IMG_0189.JPG', 'IMG_0189.JPG', '' ],
      [ 'thumbs/IMG_0190.JPG', 'IMG_0190.JPG', '' ],
      [ 'thumbs/IMG_0191.JPG', 'IMG_0191.JPG', '' ],
      [ 'thumbs/IMG_0192.JPG', 'IMG_0192.JPG', '' ],
      [ 'thumbs/IMG_0193.JPG', 'IMG_0193.JPG', '' ],
      [ 'thumbs/IMG_0194.JPG', 'IMG_0194.JPG', '' ],
      [ 'thumbs/IMG_0195.JPG', 'IMG_0195.JPG', '' ],
      [ 'thumbs/IMG_0196.JPG', 'IMG_0196.JPG', '' ],
      [ 'thumbs/IMG_0197.JPG', 'IMG_0197.JPG', '' ],
      [ 'thumbs/IMG_0198.JPG', 'IMG_0198.JPG', '' ],
      [ 'thumbs/IMG_0199.JPG', 'IMG_0199.JPG', '' ],
      [ 'thumbs/IMG_0200.JPG', 'IMG_0200.JPG', '' ],
      [ 'thumbs/IMG_0201.JPG', 'IMG_0201.JPG', '' ],
      [ 'thumbs/IMG_0202.JPG', 'IMG_0202.JPG', '' ],
      [ 'thumbs/IMG_0203.JPG', 'IMG_0203.JPG', '' ],
      [ 'thumbs/IMG_0204.JPG', 'IMG_0204.JPG', '' ],
      [ 'thumbs/IMG_0205.JPG', 'IMG_0205.JPG', '' ],
      [ 'thumbs/IMG_0206.JPG', 'IMG_0206.JPG', '' ],
      [ 'thumbs/IMG_0207.JPG', 'IMG_0207.JPG', '' ],
      [ 'thumbs/IMG_0208.JPG', 'IMG_0208.JPG', '' ],
      [ 'thumbs/IMG_0209.JPG', 'IMG_0209.JPG', '' ],
      [ 'thumbs/IMG_0210.JPG', 'IMG_0210.JPG', '' ],
      [ 'thumbs/IMG_0211.JPG', 'IMG_0211.JPG', '' ],
      [ 'thumbs/IMG_0212.JPG', 'IMG_0212.JPG', '' ],
      [ 'thumbs/IMG_0213.JPG', 'IMG_0213.JPG', '' ],
      [ 'thumbs/IMG_0214.JPG', 'IMG_0214.JPG', '' ],
      [ 'thumbs/IMG_0215.JPG', 'IMG_0215.JPG', '' ],
      [ 'thumbs/IMG_0216.JPG', 'IMG_0216.JPG', '' ],
      [ 'thumbs/IMG_0217.JPG', 'IMG_0217.JPG', '' ],
      [ 'thumbs/IMG_0218.JPG', 'IMG_0218.JPG', '' ],
      [ 'thumbs/IMG_0219.JPG', 'IMG_0219.JPG', '' ],
      [ 'thumbs/IMG_0220.JPG', 'IMG_0220.JPG', '' ],
      [ 'thumbs/IMG_0221.JPG', 'IMG_0221.JPG', '' ],
      [ 'thumbs/IMG_0222.JPG', 'IMG_0222.JPG', '' ],
      [ 'thumbs/IMG_0223.JPG', 'IMG_0223.JPG', '' ],
      [ 'thumbs/IMG_0224.JPG', 'IMG_0224.JPG', '' ],
      [ 'thumbs/IMG_0225.JPG', 'IMG_0225.JPG', '' ],
      [ 'thumbs/IMG_0226.JPG', 'IMG_0226.JPG', '' ],
      [ 'thumbs/IMG_0227.JPG', 'IMG_0227.JPG', '' ],
      [ 'thumbs/IMG_0228.JPG', 'IMG_0228.JPG', '' ],
      [ 'thumbs/IMG_0229.JPG', 'IMG_0229.JPG', '' ],
      [ 'thumbs/IMG_0230.JPG', 'IMG_0230.JPG', '' ],
      [ 'thumbs/IMG_0232.JPG', 'IMG_0232.JPG', '' ],
      [ 'thumbs/IMG_0233.JPG', 'IMG_0233.JPG', '' ],
      [ 'thumbs/IMG_0234.JPG', 'IMG_0234.JPG', '' ],
      [ 'thumbs/IMG_0235.JPG', 'IMG_0235.JPG', '' ],
      [ 'thumbs/IMG_0236.JPG', 'IMG_0236.JPG', '' ],
      [ 'thumbs/IMG_0237.JPG', 'IMG_0237.JPG', '' ],
      [ 'thumbs/IMG_0238.JPG', 'IMG_0238.JPG', '' ],
      [ 'thumbs/IMG_0239.JPG', 'IMG_0239.JPG', '' ],
      [ 'thumbs/IMG_0240.JPG', 'IMG_0240.JPG', '' ],
      [ 'thumbs/IMG_0241.JPG', 'IMG_0241.JPG', '' ],
      [ 'thumbs/IMG_0242.JPG', 'IMG_0242.JPG', '' ],
      [ 'thumbs/IMG_0243.JPG', 'IMG_0243.JPG', '' ],
      [ 'thumbs/IMG_0244.JPG', 'IMG_0244.JPG', '' ],
      [ 'thumbs/IMG_0245.JPG', 'IMG_0245.JPG', '' ],
      [ 'thumbs/IMG_0246.JPG', 'IMG_0246.JPG', '' ],
      [ 'thumbs/IMG_0247.JPG', 'IMG_0247.JPG', '' ],
      [ 'thumbs/IMG_0248.JPG', 'IMG_0248.JPG', '' ],
      [ 'thumbs/IMG_0249.JPG', 'IMG_0249.JPG', '' ],
      [ 'thumbs/IMG_0250.JPG', 'IMG_0250.JPG', '' ],
      [ 'thumbs/IMG_0251.JPG', 'IMG_0251.JPG', '' ],
      [ 'thumbs/IMG_0252.JPG', 'IMG_0252.JPG', '' ],
      [ 'thumbs/IMG_0253.JPG', 'IMG_0253.JPG', '' ],
      [ 'thumbs/IMG_0254.JPG', 'IMG_0254.JPG', '' ],
      [ 'thumbs/IMG_0255.JPG', 'IMG_0255.JPG', '' ],
      [ 'thumbs/IMG_0256.JPG', 'IMG_0256.JPG', '' ],
      [ 'thumbs/IMG_0257.JPG', 'IMG_0257.JPG', '' ],
      [ 'thumbs/IMG_0258.JPG', 'IMG_0258.JPG', '' ],
      [ 'thumbs/IMG_0259.JPG', 'IMG_0259.JPG', '' ],
      [ 'thumbs/IMG_0260.JPG', 'IMG_0260.JPG', '' ],
      [ 'thumbs/IMG_0261.JPG', 'IMG_0261.JPG', '' ],
      [ 'thumbs/IMG_0262.JPG', 'IMG_0262.JPG', '' ],
      [ 'thumbs/IMG_0263.JPG', 'IMG_0263.JPG', '' ],
      [ 'thumbs/IMG_0264.JPG', 'IMG_0264.JPG', '' ],
      [ 'thumbs/IMG_0265.JPG', 'IMG_0265.JPG', '' ],
      [ 'thumbs/IMG_0266.JPG', 'IMG_0266.JPG', '' ],
      [ 'thumbs/IMG_0267.JPG', 'IMG_0267.JPG', '' ],
      [ 'thumbs/IMG_0268.JPG', 'IMG_0268.JPG', '' ],
      [ 'thumbs/IMG_0269.JPG', 'IMG_0269.JPG', '' ],
      [ 'thumbs/IMG_0270.JPG', 'IMG_0270.JPG', '' ],
      [ 'thumbs/IMG_0271.JPG', 'IMG_0271.JPG', '' ],
      [ 'thumbs/IMG_0272.JPG', 'IMG_0272.JPG', '' ],
      [ 'thumbs/IMG_0273.JPG', 'IMG_0273.JPG', '' ],
      [ 'thumbs/IMG_0274.JPG', 'IMG_0274.JPG', '' ],
      [ 'thumbs/IMG_0275.JPG', 'IMG_0275.JPG', '' ],
      [ 'thumbs/IMG_0276.JPG', 'IMG_0276.JPG', '' ],
      [ 'thumbs/IMG_0277.JPG', 'IMG_0277.JPG', '' ],
      [ 'thumbs/IMG_0278.JPG', 'IMG_0278.JPG', '' ],
      [ 'thumbs/IMG_0279.JPG', 'IMG_0279.JPG', '' ],
      [ 'thumbs/IMG_0280.JPG', 'IMG_0280.JPG', '' ],
      [ 'thumbs/IMG_0281.JPG', 'IMG_0281.JPG', '' ],
      [ 'thumbs/IMG_0282.JPG', 'IMG_0282.JPG', '' ],
      [ 'thumbs/IMG_0283.JPG', 'IMG_0283.JPG', '' ],
      [ 'thumbs/IMG_0284.JPG', 'IMG_0284.JPG', '' ],
      [ 'thumbs/IMG_0285.JPG', 'IMG_0285.JPG', '' ],
      [ 'thumbs/IMG_0286.JPG', 'IMG_0286.JPG', '' ],
      [ 'thumbs/IMG_0287.JPG', 'IMG_0287.JPG', '' ],
      [ 'thumbs/IMG_0288.JPG', 'IMG_0288.JPG', '' ],
      [ 'thumbs/IMG_0289.JPG', 'IMG_0289.JPG', '' ],
      [ 'thumbs/IMG_0290.JPG', 'IMG_0290.JPG', '' ],
      [ 'thumbs/IMG_0291.JPG', 'IMG_0291.JPG', '' ],
      [ 'thumbs/IMG_0292.JPG', 'IMG_0292.JPG', '' ],
      [ 'thumbs/IMG_0293.JPG', 'IMG_0293.JPG', '' ],
      [ 'thumbs/IMG_0294.JPG', 'IMG_0294.JPG', '' ],
      [ 'thumbs/IMG_0295.JPG', 'IMG_0295.JPG', '' ],
      [ 'thumbs/IMG_0296.JPG', 'IMG_0296.JPG', '' ],
      [ 'thumbs/IMG_0297.JPG', 'IMG_0297.JPG', '' ],
      [ 'thumbs/IMG_0298.JPG', 'IMG_0298.JPG', '' ],
      [ 'thumbs/IMG_0299.JPG', 'IMG_0299.JPG', '' ],
      [ 'thumbs/IMG_0300.JPG', 'IMG_0300.JPG', '' ],
      [ 'thumbs/IMG_0301.JPG', 'IMG_0301.JPG', '' ],
      [ 'thumbs/IMG_0302.JPG', 'IMG_0302.JPG', '' ],
      [ 'thumbs/IMG_0303.JPG', 'IMG_0303.JPG', '' ],
      [ 'thumbs/IMG_0304.JPG', 'IMG_0304.JPG', '' ],
      [ 'thumbs/IMG_0305.JPG', 'IMG_0305.JPG', '' ],
      [ 'thumbs/IMG_0306.JPG', 'IMG_0306.JPG', '' ],
      [ 'thumbs/IMG_0307.JPG', 'IMG_0307.JPG', '' ],
      [ 'thumbs/IMG_0308.JPG', 'IMG_0308.JPG', '' ],
      [ 'thumbs/IMG_0309.JPG', 'IMG_0309.JPG', '' ],
      [ 'thumbs/IMG_0310.JPG', 'IMG_0310.JPG', '' ],
      [ 'thumbs/IMG_0311.JPG', 'IMG_0311.JPG', '' ],
      [ 'thumbs/IMG_0312.JPG', 'IMG_0312.JPG', '' ],
      [ 'thumbs/IMG_0313.JPG', 'IMG_0313.JPG', '' ],
      [ 'thumbs/IMG_0314.JPG', 'IMG_0314.JPG', '' ],
      [ 'thumbs/IMG_0315.JPG', 'IMG_0315.JPG', '' ],
      [ 'thumbs/IMG_0316.JPG', 'IMG_0316.JPG', '' ],
      [ 'thumbs/IMG_0317.JPG', 'IMG_0317.JPG', '' ],
      [ 'thumbs/IMG_0318.JPG', 'IMG_0318.JPG', '' ],
      [ 'thumbs/IMG_0319.JPG', 'IMG_0319.JPG', '' ],
      [ 'thumbs/IMG_0320.JPG', 'IMG_0320.JPG', '' ],
      [ 'thumbs/IMG_0321.JPG', 'IMG_0321.JPG', '' ],
      [ 'thumbs/IMG_0322.JPG', 'IMG_0322.JPG', '' ],
      [ 'thumbs/IMG_0323.JPG', 'IMG_0323.JPG', '' ],
      [ 'thumbs/IMG_0324.JPG', 'IMG_0324.JPG', '' ],
      [ 'thumbs/IMG_0325.JPG', 'IMG_0325.JPG', '' ],
      [ 'thumbs/IMG_0326.JPG', 'IMG_0326.JPG', '' ],
      [ 'thumbs/IMG_0327.JPG', 'IMG_0327.JPG', '' ],
      [ 'thumbs/IMG_0328.JPG', 'IMG_0328.JPG', '' ],
      [ 'thumbs/IMG_0329.JPG', 'IMG_0329.JPG', '' ],
      [ 'thumbs/IMG_0330.JPG', 'IMG_0330.JPG', '' ],
      [ 'thumbs/IMG_0331.JPG', 'IMG_0331.JPG', '' ],
      [ 'thumbs/IMG_0332.JPG', 'IMG_0332.JPG', '' ],
      [ 'thumbs/IMG_0333.JPG', 'IMG_0333.JPG', '' ],
      [ 'thumbs/IMG_0334.JPG', 'IMG_0334.JPG', '' ],
      [ 'thumbs/IMG_0335.JPG', 'IMG_0335.JPG', '' ],
      [ 'thumbs/IMG_0336.JPG', 'IMG_0336.JPG', '' ],
      [ 'thumbs/IMG_0337.JPG', 'IMG_0337.JPG', '' ],
      [ 'thumbs/IMG_0338.JPG', 'IMG_0338.JPG', '' ],
      [ 'thumbs/IMG_0339.JPG', 'IMG_0339.JPG', '' ],
      [ 'thumbs/IMG_0340.JPG', 'IMG_0340.JPG', '' ],
      [ 'thumbs/IMG_0341.JPG', 'IMG_0341.JPG', '' ],
      [ 'thumbs/IMG_0342.JPG', 'IMG_0342.JPG', '' ],
      [ 'thumbs/IMG_0343.JPG', 'IMG_0343.JPG', '' ],
      [ 'thumbs/IMG_0344.JPG', 'IMG_0344.JPG', '' ],
      [ 'thumbs/IMG_0345.JPG', 'IMG_0345.JPG', '' ],
      [ 'thumbs/IMG_0346.JPG', 'IMG_0346.JPG', '' ],
      [ 'thumbs/IMG_0347.JPG', 'IMG_0347.JPG', '' ],
      [ 'thumbs/IMG_0348.JPG', 'IMG_0348.JPG', '' ],
      [ 'thumbs/IMG_0349.JPG', 'IMG_0349.JPG', '' ],
      [ 'thumbs/IMG_0350.JPG', 'IMG_0350.JPG', '' ],
      [ 'thumbs/IMG_0351.JPG', 'IMG_0351.JPG', '' ],
      [ 'thumbs/IMG_0352.JPG', 'IMG_0352.JPG', '' ],
      [ 'thumbs/IMG_0353.JPG', 'IMG_0353.JPG', '' ],
      [ 'thumbs/IMG_0354.JPG', 'IMG_0354.JPG', '' ],
      [ 'thumbs/IMG_0355.JPG', 'IMG_0355.JPG', '' ],
      [ 'thumbs/IMG_0356.JPG', 'IMG_0356.JPG', '' ] ] } ]

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
