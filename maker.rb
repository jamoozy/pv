#!/usr/bin/ruby -w

require 'ftools'

if __FILE__ != $0
  puts 'Must run as separate file.  This is not a library!'
  exit
end

# "parse args"
$tmp_dir = '.gen/'
$dst_dir = '/home/jamoozy/www/pv'

File.makedirs($tmp_dir) unless File.exists?($tmp_dir)
File.makedirs($dst_dir) unless File.exists?($dst_dir)
`cp *.js style.css #$tmp_dir`

def make_page(entry)
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
  f.write('</ul></div><div id="exit-bg"><div id="overlay"><img src=""><div id="desc"></div><div id="comments"></div></div></div></body><html>')
  f.close
end

entries = [
  { :title => 'Engagement',
    :bname => 'engagement',
    :dir => 'engagement',
    :location => '/home/jamoozy/Pictures/engagement',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['IMG_0464-thumb.jpg', 'IMG_0464.jpg'],
      ['IMG_0475-thumb.jpg', 'IMG_0475.jpg'],
      ['IMG_0485-thumb.jpg', 'IMG_0485.jpg'],
      ['IMG_0500-thumb.jpg', 'IMG_0500.jpg'],
      ['IMG_0504-thumb.jpg', 'IMG_0504.jpg'],
      ['IMG_0508-thumb.jpg', 'IMG_0508.jpg'],
      ['IMG_0525-thumb.jpg', 'IMG_0525.jpg'],
      ['IMG_0550-thumb.jpg', 'IMG_0550.jpg'],
      ['IMG_0554-thumb.jpg', 'IMG_0554.jpg'],
      ['IMG_0563-thumb.jpg', 'IMG_0563.jpg'],
      ['IMG_0598-thumb.jpg', 'IMG_0598.jpg'],
      ['IMG_0601-thumb.jpg', 'IMG_0601.jpg'],
      ['IMG_0618-thumb.jpg', 'IMG_0618.jpg'],
      ['IMG_0630-thumb.jpg', 'IMG_0630.jpg'],
      ['IMG_0639-thumb.jpg', 'IMG_0639.jpg'],
      ['IMG_0648-thumb.jpg', 'IMG_0648.jpg'],
      ['IMG_0652-thumb.jpg', 'IMG_0652.jpg'],
      ['IMG_0666-thumb.jpg', 'IMG_0666.jpg'],
      ['IMG_0670-thumb.jpg', 'IMG_0670.jpg'],
      ['IMG_0683-thumb.jpg', 'IMG_0683.jpg'],
      ['IMG_0685-thumb.jpg', 'IMG_0685.jpg'],
      ['IMG_0690-thumb.jpg', 'IMG_0690.jpg'],
      ['IMG_0692-thumb.jpg', 'IMG_0692.jpg'],
      ['IMG_0712-thumb.jpg', 'IMG_0712.jpg'],
      ['IMG_0732-thumb.jpg', 'IMG_0732.jpg'] ] },
  { :title => 'Maui Underwater',
    :bname => 'maui',
    :dir => 'maui',
    :location => '/home/jamoozy/Pictures/maui',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['01-thumb.jpg', '01.jpg'],
      ['02-thumb.jpg', '02.jpg'],
      ['03-thumb.jpg', '03.jpg'],
      ['04-thumb.jpg', '04.jpg'],
      ['05-thumb.jpg', '05.jpg'],
      ['06-thumb.jpg', '06.jpg'],
      ['07-thumb.jpg', '07.jpg'],
      ['08-thumb.jpg', '08.jpg'],
      ['09-thumb.jpg', '09.jpg'],
      ['10-thumb.jpg', '10.jpg'],
      ['11-thumb.jpg', '11.jpg'],
      ['12-thumb.jpg', '12.jpg'],
      ['13-thumb.jpg', '13.jpg'],
      ['14-thumb.jpg', '14.jpg'],
      ['15-thumb.jpg', '15.jpg'],
      ['16-thumb.jpg', '16.jpg'],
      ['17-thumb.jpg', '17.jpg'],
      ['18-thumb.jpg', '18.jpg'],
      ['19-thumb.jpg', '19.jpg'],
      ['20-thumb.jpg', '20.jpg'],
      ['21-thumb.jpg', '21.jpg'],
      ['22-thumb.jpg', '22.jpg'],
      ['23-thumb.jpg', '23.jpg'],
      ['24-thumb.jpg', '24.jpg'],
      ['25-thumb.jpg', '25.jpg'],
      ['26-thumb.jpg', '26.jpg'] ] } ]

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
