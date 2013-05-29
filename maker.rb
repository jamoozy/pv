#!/usr/bin/ruby -w

require 'ftools'

if __FILE__ != $0
  puts 'Must run as separate file.  This is not a library!'
  exit
end

# "parse args"
tmp_dir = '.gen/'
dst_dir = '~/www/pv'

File.makedirs(tmp_dir) unless File.exists?(tmp_dir)
File.makedirs(dst_dir) unless File.exists?(dst_dir)

def make_page(entry)
  html_name = "#{tmp_dir}/#{entry[:bname]}.html"
  `ln -s "#{entry[:location]}" "#{tmp_dir}/#{entry[:dir]}"`
  f = File.new(html_name, 'w')
  f.write('<!DOCTYPE html>')
  f.write('<html><head>')
  f.write('<meta charset="utf-8">')
  f.write("<title>#{entry[:title]}</title>")
  f.write('<link rel="stylesheet" type="text/css" src="style.css">')
  f.write('</head><body><div class="content"><ul>')
  entry[:images].each do |image|
    f.write("<li><a href=\"#{image[1]}\"><img src=\"#{image[0]}\"></a>")
  end
  f.write('</ul></div></body><html>')
  f.close!
end

entries = [
  { :title => 'Engagement',
    :bname => 'engagement',
    :dir => 'engagement',
    :location => '/home/jamoozy/Pictures/engagement',
    :thumbnail => 'thumb.jpg',
    :images => [
      ['IMG_0464 copy-thumb.jpg',     'IMG_0464 copy.jpg'],
      ['IMG_0475 copy-thumb.jpg',     'IMG_0475 copy.jpg'],
      ['IMG_0485 copy-thumb.jpg',     'IMG_0485 copy.jpg'],
      ['IMG_0500 copy-thumb.jpg',     'IMG_0500 copy.jpg'],
      ['IMG_0504 copy-thumb.jpg',     'IMG_0504 copy.jpg'],
      ['IMG_0508 copy-thumb.jpg',     'IMG_0508 copy.jpg'],
      ['IMG_0525 copy-thumb.jpg',     'IMG_0525 copy.jpg'],
      ['IMG_0550 copy-thumb.jpg',     'IMG_0550 copy.jpg'],
      ['IMG_0554 copy-thumb.jpg',     'IMG_0554 copy.jpg'],
      ['IMG_0563 copy-thumb.jpg',     'IMG_0563 copy.jpg'],
      ['IMG_0598 copy-thumb.jpg',     'IMG_0598 copy.jpg'],
      ['IMG_0601 copy-thumb.jpg',     'IMG_0601 copy.jpg'],
      ['IMG_0618 copy copy-thumb.jpg','IMG_0618 copy copy.jpg'],
      ['IMG_0618 copy-thumb.jpg',     'IMG_0618 copy.jpg'],
      ['IMG_0630 copy-thumb.jpg',     'IMG_0630 copy.jpg'],
      ['IMG_0639 copy-thumb.jpg',     'IMG_0639 copy.jpg'],
      ['IMG_0648 copy-thumb.jpg',     'IMG_0648 copy.jpg'],
      ['IMG_0652 copy-thumb.jpg',     'IMG_0652 copy.jpg'],
      ['IMG_0666 copy copy-thumb.jpg','IMG_0666 copy copy.jpg'],
      ['IMG_0666 copy-thumb.jpg',     'IMG_0666 copy.jpg'],
      ['IMG_0670 copy-thumb.jpg',     'IMG_0670 copy.jpg'],
      ['IMG_0683 copy-thumb.jpg',     'IMG_0683 copy.jpg'],
      ['IMG_0685 copy-thumb.jpg',     'IMG_0685 copy.jpg'],
      ['IMG_0690 copy-thumb.jpg',     'IMG_0690 copy.jpg'],
      ['IMG_0692 copy-thumb.jpg',     'IMG_0692 copy.jpg'],
      ['IMG_0712 copy copy-thumb.jpg','IMG_0712 copy copy.jpg'],
      ['IMG_0712 copy-thumb.jpg',     'IMG_0712 copy.jpg'],
      ['IMG_0732 copy copy-thumb.jpg','IMG_0732 copy copy.jpg'],
      ['IMG_0732 copy-thumb.jpg',     'IMG_0732 copy.jpg'] ] }
]

content = '<ul>'
entries.each do |entry|
  html_name = "#{entry[:bname]}.html"
  content << "<li><a href=\"#{html_name}\"><img src=\"#{entry['dir']}/#{entry['thumbnail']}\"></a>"
  make_page(entry)
end
content << '</ul>'


f = File.new("#{tmp_dir}/index.html", 'w')
f.write(
<<eos
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" type="text/css" src="style.css">
  </head>
  <body>
    <div class="content">#{content}</div>
  </body>
</html>
eos
       )
f.close!

`rsync -avzP #{tmp_dir} #{dst_dir}`
