#!/usr/bin/ruby -w

# Ensure right amount of args.
if ARGV.size != 3
  puts "usage: #$0 [file] [size] [dst]"
  puts "  [file] is the name of the file to resize."
  puts "  [size] is the max width & height."
  puts "  [dst] is the destination directory."
  exit 1
end

# "Parse" args.
$src = ARGV[0]
$size = ARGV[1]
$dst = ARGV[2] + "/#$src"

# Ensure this doesn't already exist.
if File.exists?($dst)
  puts "#$dst already exists.  Skipping."
  exit 2
end

# Check if we're doing width or height.
`identify #$src` =~ /(\d+)x(\d+)/
w,h = $1,$2

if w > h
  puts "[#$src] landscape"
  `convert #$src -resize #{$size}x #$dst`
else
  puts "[#$src] portrait"
  `convert #$src -resize x#$size #$dst`
end
