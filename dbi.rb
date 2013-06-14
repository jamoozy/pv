#!/usr/bin/ruby -w

require 'cgi'
require 'sqlite3'

cgi = CGI.new
puts cgi.header

unless (cgi.params.include? 'dir')
  puts '{error:"dir key missing"}'
  exit
end

db = SQLite3::Database.new("#{cgi['dir']}/comments.db")

if cgi['type'] == 'fetch' then
  print '{okay:['
  db.execute("select comments.name,comments.comment
              from images,comments
              where images.name=? and images.id=img_id", cgi['img']) do |row|
    print "{name:\"#{row[0]}\",comment:\"#{row[1]}\"}"
  end
  puts ']}'
elsif cgi['type'] == 'put' then
  img_id = db.execute("select id from images where name=?", cgi['img'])
  db.execute("insert into comments
                (name, comment, utime, ip, img_id)
              values
                (?, ?, ?, ?, ?)",
             [cgi['name'], cgi['comment'], Time.now.to_i, cgi['REMOTE_ADDR'], img_id])
end
