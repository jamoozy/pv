#!/usr/bin/ruby -w
#
# Copyright (c) 2013-2015 Andrew "Jamoozy" C. Sabisch,
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

require 'erb'
require 'cgi'
require 'yaml'
require 'ftools'
require 'sqlite3'
require 'optparse'

# Do ERB processing on 'iname' and spit it out to 'oname'
def erb(iname, oname, bind)
  f = File.open(oname, 'w') do |o|
    File.open(iname, 'r') do |i|
      o.write(ERB.new(i.read).result(bind))
    end
  end
end


include SQLite3


# Makes a page for an album according to the entry.
#   entry: And entry like what's described in the comments below.
def make_page(entry)
  `ln -s "#{entry[:loc]}" "#$tmp_dir/#{entry[:sln]}"` unless File.exists?("#$tmp_dir/#{entry[:sln]}")

  data_file = entry[:loc] + '/data.yml'
  puts 'Reading file: ' + data_file
  images = File.open(data_file){|f|YAML.load(f)}
  puts "Got #{images.size} images"

  # Check if DB already exists.  If not, create it.
  full_db_name = "#$tmp_dir/#{entry[:sln]}/comments.db"
  unless File.exists?(full_db_name)
    begin
      puts 'Making new DB at: ' + full_db_name
      $db = Database.new(full_db_name)
    rescue CantOpenException => e
      puts "Can't create DB: ", full_db_name
      return
    end
    $db.execute("create table images (
                   id integer primary key,
                   name text,
                   title text
                 )")
    $db.execute("create table comments (
                   id integer primary key,
                   name text,
                   comment text,
                   utime datetime,
                   ip text,
                   img_id integer,
                   foreign key(img_id) references images(id)
                 )")

    # Initial entries for all the images.
    $db.transaction
    images.each do |img|
      puts 'Adding image ' + img[1]
      $db.execute('insert into images (name,title) values (?,?)', [img[1], img[2]])
    end
    $db.commit

    # Set the right permissions for the webserver to handle the DB & prompt
    # the user to run the chown on the DB and its directory.
    `chmod 664 #{full_db_name}`
    puts "Please run \"sudo chown :www-data #{full_db_name} && sudo chown :www-data #$tmp_dir/#{entry[:sln]}\""
  else
    begin
      $db = Database.new(full_db_name)
    rescue CantOpenException => e
      puts "Can't open db: ", full_db_name
    end

    # Make sure all the images' titles are up to date.
    images.each do |img|
      r = $db.execute('select * from images where name=?', [img[1]])
      if !r || r.size < 1
        $db.execute('insert into images (name,title) values (?,?)', [img[1], img[2]])
      elsif r.size > 1
        puts "Error: got #{r.size} results for img #{img[1]}"
      elsif r[0][2] != img[2]
        puts "Updating #{img[1]} title to \"#{img[2]}\""
        $db.execute('update images set title=? where id=?', [img[2], r[0][0]])
      end
    end
  end

  # Write HTML file.
  erb('page.html.erb', "#$tmp_dir/#{entry[:bname]}.html", binding)
end

class Options
  attr_accessor :verbose
  attr_accessor :tmp
  attr_accessor :dst
  attr_accessor :entries
  attr_accessor :tp
end

def parse_args
  options = Options.new
  options.verbose = false
  options.tmp = '.gen'
  options.dst = '/home/jamoozy/www/pv'
  options.entries = 'entries.yaml'
  options.tp = 'rsync -avP'

  OptionParser.new do |opts|
    opts.banner = "Usage: maker.rb [options]"
    opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
      puts 'verbose: ' + v.to_s
      options.verbose = v
    end
    opts.on('-TTP', '--transfer-protocol=TP', 'Speicfy transfer protocol') do |tp|
      puts 'transfer-protocol: ' + tp.to_s
      options.tp = tp
    end
    opts.on('-dDST', '--destination=DST', 'Specify a destination') do |d|
      puts 'destination: ' + d
      options.dst = File.expand_path(d.to_s)
    end
    opts.on('-tTMP', '--tmp=TMP', 'Specify temorary directory.') do |t|
      puts 'tmp: ' + t.to_s
      options.tmp = File.expand_path(t)
    end
    opts.on('-yYML', '--yaml=YML', 'Specify YAML-formatted ') do |y|
      puts 'yml: ' + y.to_s
      options.entries = File.expand_path(y)
    end
  end.parse!
  options
end

if __FILE__ == $0
  options = parse_args

  $tmp_dir = options.tmp
  $dst_dir = options.dst
  $entries = options.entries
  $tp = options.tp

  File.makedirs($tmp_dir) unless File.exists?($tmp_dir)
  File.makedirs($dst_dir) unless File.exists?($dst_dir)
  `cp icons/*.png .htaccess upload.rb dbi.rb *.js style.css background.jpg #$tmp_dir`

  # Load entries from the yaml file.
  entries = File.open($entries) {|f| YAML.load(f)}

  # Generate the list of albums for the main page.
  content = '<ul>'
  entries.each do |entry|
    html_name = "#{entry[:bname]}.html"
    content << "<li><a href=\"#{html_name}\"><img src=\"#{entry[:sln]}/#{entry[:thumb]}\"><br>#{entry[:title]}</a>"
    make_page(entry)
  end
  content << '</ul>'

  # Write index.html with the above content.
  erb('index.html.erb', "#$tmp_dir/index.html", binding)

  # Copy tmp dir to final location.
  `#$tp #$tmp_dir/ #$dst_dir/`
end
