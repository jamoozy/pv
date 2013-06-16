#!/usr/bin/ruby -w

require 'cgi'
require 'sqlite3'

cgi = CGI.new
puts cgi.header('text/html')

unless (cgi.params.include? 'dir')
  puts '{error:"dir key missing"}'
  exit
end

begin
  $db = SQLite3::Database.new("#{cgi['dir']}/comments.db")
rescue SQLite3::CantOpenException => e
  puts "{error:'#{e}'}"
end

def jsonize(str)
  str.gsub(/\\/,'\\\\').gsub(/"/, '\\"')
end

if cgi['type'] == 'fetch' then
  print '{'
  $db.execute("select id,title from images where name=?", [cgi['img']]) do |row|
    $id = row[0]
    print "title:\"#{row[1]}\","
  end
  print 'comments:"'
  $db.execute("select name,comment from comments where img_id=?", [$id]) do |row|
    print "<li><span class='name'>#{jsonize(row[0])}</span><span class='comment'>#{jsonize(row[1])}</span></li>"
  end
  puts '"}'
elsif cgi['type'] == 'put' then
  begin
    $db.execute("select id from images where name=?", [cgi['img']]) do |row|
      $id = row[0]
    end
  rescue SQLite3::CantOpenException => e
    puts "{error:'#{e}',query:\"select id from images where name='#{cgi['img']}'\"}"
  end

  begin
    $db.execute("insert into comments
                  (name, comment, utime, ip, img_id)
                values
                  (?, ?, ?, ?, ?)",
               [cgi['name'], cgi['comment'], Time.now.to_i, cgi.remote_addr, $id])
  rescue SQLite3::CantOpenException => e
    puts "{error:'#{e}',query:\"insert into comments (name, comment, utime, ip, img_id) values (#{cgi['name']}, #{cgi['comment']}, #{Time.now.to_i}, #{ cgi.remote_addr}, #$id)\"}"
  end
else
  puts '{error:"type missing"}'
end
