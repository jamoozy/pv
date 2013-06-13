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
`cp style.css #$tmp_dir`

def make_page(entry)
  html_name = "#$tmp_dir/#{entry[:bname]}.html"
  `ln -s "#{entry[:location]}" "#$tmp_dir/#{entry[:dir]}"` unless File.exists?("#$tmp_dir/#{entry[:dir]}")
  f = File.new(html_name, 'w')
  f.write('<!DOCTYPE html>')
  f.write('<html><head>')
  f.write('<meta charset="utf-8">')
  f.write("<title>#{entry[:title]}</title>")
  f.write('<link rel="stylesheet" type="text/css" href="style.css">')
  f.write('</head><body><div class="content"><ul>')
  entry[:images].each do |image|
    f.write("<li><a href=\"#{entry[:dir]}/#{image[1]}\"><img src=\"#{entry[:dir]}/#{image[0]}\"></a>")
  end
  f.write('</ul></div></body><html>')
  f.close
end

entries = [
  { :title => 'Engagement',
    :bname => 'engagement',
    :dir => 'engagement',
    :location => '/home/jamoozy/Pictures/engagement',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['IMG_0464-thumb.jpg',     'IMG_0464.jpg'],
      ['IMG_0475-thumb.jpg',     'IMG_0475.jpg'],
      ['IMG_0485-thumb.jpg',     'IMG_0485.jpg'],
      ['IMG_0500-thumb.jpg',     'IMG_0500.jpg'],
      ['IMG_0504-thumb.jpg',     'IMG_0504.jpg'],
      ['IMG_0508-thumb.jpg',     'IMG_0508.jpg'],
      ['IMG_0525-thumb.jpg',     'IMG_0525.jpg'],
      ['IMG_0550-thumb.jpg',     'IMG_0550.jpg'],
      ['IMG_0554-thumb.jpg',     'IMG_0554.jpg'],
      ['IMG_0563-thumb.jpg',     'IMG_0563.jpg'],
      ['IMG_0598-thumb.jpg',     'IMG_0598.jpg'],
      ['IMG_0601-thumb.jpg',     'IMG_0601.jpg'],
      ['IMG_0618 copy-thumb.jpg','IMG_0618 copy.jpg'],
      ['IMG_0618-thumb.jpg',     'IMG_0618.jpg'],
      ['IMG_0630-thumb.jpg',     'IMG_0630.jpg'],
      ['IMG_0639-thumb.jpg',     'IMG_0639.jpg'],
      ['IMG_0648-thumb.jpg',     'IMG_0648.jpg'],
      ['IMG_0652-thumb.jpg',     'IMG_0652.jpg'],
      ['IMG_0666 copy-thumb.jpg','IMG_0666 copy.jpg'],
      ['IMG_0666-thumb.jpg',     'IMG_0666.jpg'],
      ['IMG_0670-thumb.jpg',     'IMG_0670.jpg'],
      ['IMG_0683-thumb.jpg',     'IMG_0683.jpg'],
      ['IMG_0685-thumb.jpg',     'IMG_0685.jpg'],
      ['IMG_0690-thumb.jpg',     'IMG_0690.jpg'],
      ['IMG_0692-thumb.jpg',     'IMG_0692.jpg'],
      ['IMG_0712 copy-thumb.jpg','IMG_0712 copy.jpg'],
      ['IMG_0712-thumb.jpg',     'IMG_0712.jpg'],
      ['IMG_0732 copy-thumb.jpg','IMG_0732 copy.jpg'],
      ['IMG_0732-thumb.jpg',     'IMG_0732.jpg'] ] } ]

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
