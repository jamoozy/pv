

exit(-1) if __FILE__ != $0

def make_page(html_name, title, dir, images)
  f = File.new(html_name, 'w')
  f.write('<!DOCTYPE html>')
  f.write('<html><head>')
  f.write('<meta charset="utf-8">')
  f.write("<title>#{title}</title>")
  f.write('<link rel="stylesheet" type="text/css" src="style.css">')
  f.write('</head><body><div class="content"><ul>')
  images.each do |image|
    f.write("<li><a href=\"#{image[1]}\"><img src=\"#{image[0]}\"></a>")
  end
  f.write('</ul></div></body><html>')
  f.close!
end

entries = [
  { 'title' => 'Engagement',
    'bname' => 'engagement',
    'dir' => 'engagement',
    'thumbnail' => 'thumb.jpg',
    'images' => [
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
  html_name = "#{bname}.html"
  content << "<li><a href=\"#{html_name}\"><img src=\"#{entry['dir']}/#{entry['thumbnail']}\"></a>"
  make_page(html_name, entry['dir'], entry['images'])
end

content << '</ul>'

string = <<eos
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
