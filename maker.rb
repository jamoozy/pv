#!/usr/bin/ruby -w

require 'ftools'
require 'sqlite3'

if __FILE__ != $0
  puts 'Must run as separate file.  This is not a library!'
  exit
end

# "parse args"
$tmp_dir = '.gen/'
$dst_dir = '/home/jamoozy/www/pv'

File.makedirs($tmp_dir) unless File.exists?($tmp_dir)
File.makedirs($dst_dir) unless File.exists?($dst_dir)
`cp icons/*.png .htaccess dbi.rb *.js style.css #$tmp_dir`

def make_page(entry)
  # Check if DB already exists.  If not, create it.
  full_db_name = "#$tmp_dir/#{entry[:dir]}/comments.db"
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

    # Set the right permissions for the webserver to handle the DB.
    `chmod 664 #{full_db_name}`
    puts "Remember to give your webserver access to #{full_db_name} and its directory."
  end

  # Write HTML file.
  html_name = "#$tmp_dir/#{entry[:bname]}.html"
  `ln -s "#{entry[:location]}" "#$tmp_dir/#{entry[:dir]}"` unless File.exists?("#$tmp_dir/#{entry[:dir]}")
  f = File.new(html_name, 'w')
  f.write('<!DOCTYPE html>')
  f.write('<html><head>')
  f.write('<meta charset="utf-8">')
  f.write("<title>#{entry[:title]}</title>")
  f.write('<link rel="stylesheet" type="text/css" href="style.css">')
  f.write('<script src="jquery-1.10.1.min.js" type="text/javascript"></script>')
  f.write('<script src="photos.js" type="text/javascript"></script>')
  f.write('</head><body><div class="content"><ul>')
  entry[:images].each do |image|
    f.write("<li><span src=\"#{entry[:dir]}/#{image[1]}\"><img src=\"#{entry[:dir]}/#{image[0]}\"></span>")
  end
  f.write('</ul></div><div id="exit-bg"><div id="overlay"><div id="img-pane"><div id="left" class="navs"><img src="left-arrow.png"></div><div id="right" class="navs"><img src="right-arrow.png"></div><img id="image" src=""></div><div id="desc"></div><div id="comments"><ul></ul><div id="form">Name:<input value="" id="name" type="text"><br>Comment:<input value="" id="comment" type="text"><input type="button" id="submit" value="Submit"></div></div></div></div></body><html>')
  f.close
end

entries = [
  { :title => 'Engagement',
    :bname => 'engagement',
    :dir => 'engagement',
    :location => '/home/jamoozy/Pictures/engagement',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['IMG_0464-thumb.jpg', 'IMG_0464.jpg', ''],
      ['IMG_0475-thumb.jpg', 'IMG_0475.jpg', ''],
      ['IMG_0485-thumb.jpg', 'IMG_0485.jpg', ''],
      ['IMG_0500-thumb.jpg', 'IMG_0500.jpg', ''],
      ['IMG_0504-thumb.jpg', 'IMG_0504.jpg', ''],
      ['IMG_0508-thumb.jpg', 'IMG_0508.jpg', ''],
      ['IMG_0525-thumb.jpg', 'IMG_0525.jpg', ''],
      ['IMG_0550-thumb.jpg', 'IMG_0550.jpg', ''],
      ['IMG_0554-thumb.jpg', 'IMG_0554.jpg', ''],
      ['IMG_0563-thumb.jpg', 'IMG_0563.jpg', ''],
      ['IMG_0598-thumb.jpg', 'IMG_0598.jpg', ''],
      ['IMG_0601-thumb.jpg', 'IMG_0601.jpg', ''],
      ['IMG_0618-thumb.jpg', 'IMG_0618.jpg', ''],
      ['IMG_0630-thumb.jpg', 'IMG_0630.jpg', ''],
      ['IMG_0639-thumb.jpg', 'IMG_0639.jpg', ''],
      ['IMG_0648-thumb.jpg', 'IMG_0648.jpg', ''],
      ['IMG_0652-thumb.jpg', 'IMG_0652.jpg', ''],
      ['IMG_0666-thumb.jpg', 'IMG_0666.jpg', ''],
      ['IMG_0670-thumb.jpg', 'IMG_0670.jpg', ''],
      ['IMG_0683-thumb.jpg', 'IMG_0683.jpg', ''],
      ['IMG_0685-thumb.jpg', 'IMG_0685.jpg', ''],
      ['IMG_0690-thumb.jpg', 'IMG_0690.jpg', ''],
      ['IMG_0692-thumb.jpg', 'IMG_0692.jpg', ""],
      ['IMG_0712-thumb.jpg', 'IMG_0712.jpg', ""],
      ['IMG_0732-thumb.jpg', 'IMG_0732.jpg', ""] ] },
  { :title => 'Maui Underwater',
    :bname => 'maui',
    :dir => 'maui',
    :location => '/home/jamoozy/Pictures/maui',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['01-thumb.jpg', '01.jpg', 'Cute!'],
      ['02-thumb.jpg', '02.jpg', 'We\'re flying!'],
      ['03-thumb.jpg', '03.jpg', 'The boat is far away ...'],
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
      ['14-thumb.jpg', '14.jpg', "Coral."],
      ['15-thumb.jpg', '15.jpg', "Andrew dives deep."],
      ['16-thumb.jpg', '16.jpg', "Spinner dolphins (now awake)!"],
      ['17-thumb.jpg', '17.jpg', "Andrew snorkelling for the first time."],
      ['18-thumb.jpg', '18.jpg', "Andrew again."],
      ['19-thumb.jpg', '19.jpg', "Ashley diving."],
      ['20-thumb.jpg', '20.jpg', "Andrew."],
      ['21-thumb.jpg', '21.jpg', "Ashley's fin."],
      ['22-thumb.jpg', '22.jpg', "Andrew's in the BG."],
      ['23-thumb.jpg', '23.jpg', ''],
      ['24-thumb.jpg', '24.jpg', ''],
      ['25-thumb.jpg', '25.jpg', ''],
      ['26-thumb.jpg', '26.jpg', ''] ] } ]

content = '<ul>'
entries.each do |entry|
  html_name = "#{entry[:bname]}.html"
  content << "<li><a href=\"#{html_name}\"><img src=\"#{entry[:dir]}/#{entry[:thumbnail]}\"><br>#{entry[:title]}</a>"
  make_page(entry)
end
content << '</ul>'


f = File.new("#$tmp_dir/index.html", 'w')
f.write(
<<eos
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" type="text/css" href="style.css">
  </head>
  <body>
    <div class="content">#{content}</div>
  </body>
</html>
eos
)
f.close

`rsync -avzP #$tmp_dir #$dst_dir`
