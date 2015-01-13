#!/usr/bin/ruby -w
#
# Copyright (c) 2015 Andrew "Jamoozy" C. Sabisch,
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

require 'yaml'
require 'ftools'
require 'sqlite3'
require 'optparse'
require 'peach'


class Options
  attr_accessor :verbose    # verbose output
  attr_accessor :dry_run    # don't actually do anything
  attr_accessor :procs      # num of parallel processes
  attr_accessor :yaml       # just make YAML file

  attr_accessor :files      # image files to use

  attr_accessor :full_size  # full size images dir
  attr_accessor :thumbs     # thumbs dir

  attr_accessor :size       # image size
  attr_accessor :thumb_size # thumb size
end

def parse_args
  options = Options.new
  options.verbose = false
  options.dry_run = false
  options.yaml = false
  options.procs = 1
  options.files = []
  options.full_size = 'full-size'
  options.thumbs = 'thumbs'
  options.size = 1200
  options.thumb_size = 200

  OptionParser.new do |opts|
    opts.banner = "Usage: #{__FILE__} [options]"

    opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
      puts 'verbose: ' + v.to_s
      options.verbose = v
    end
    opts.on('-d', '--dry-run', "Do a dry run (print commands but don't execute them)") do |d|
      puts 'Dry run.'
      options.dry_run = true;
    end
    opts.on('-pNUM', '--processes=NUM', 'Speicfy number of processes to run in parallel.') do |p|
      puts 'procs: ' + p
      options.procs = p.to_i
    end
    opts.on('-y', '--yaml', 'Just produce YAML file.') do |y|
      puts 'YAML.'
      options.yaml = true
    end

    opts.on('-iF', '--include=F', 'Specify files to include. (multiple uses okay)') do |f|
      puts 'files: ' + f
      options.files << Dir[File.expand_path(f)]
      options.files.flatten!
    end

    opts.on('-fDIR', '--full-size=DIR', 'Specify "full-size" dir name') do |d|
      puts 'full-size: ' + d
      options.full_size = File.expand_path(d)
    end
    opts.on('-tDIR', '--thumb-dir=DIR', 'Set thumbs dir.') do |d|
      puts 'thumbs dir: ' + d
      options.thumbs = d
    end

    opts.on('-sSIZE', '--size=SIZE', 'Specify "normal" image size') do |s|
      puts 'size: ' + s
      options.size = s.to_i
    end
    opts.on('-SSIZE', '--thumb-size=SIZE', 'Specify thumbnail size.') do |s|
      puts 'thumb size: ' + s
      options.thumb_size = s.to_i
    end
  end.parse!

  if options.files.empty?
    puts "Error: No input files."
    exit
  end

  et = File.expand_path(options.thumbs)
  ef = File.expand_path(options.full_size)
  options.files.each do |f|
    dn = File.dirname(f)
    if et == dn
      puts "Error: \"#{f}\" in thumbs dir \"#{options.thumbs}\""
      exit
    elsif ef == dn
      puts "Error: \"#{f}\" in thumbs dir \"#{options.full_size}\""
      exit
    end
  end

  options
end

def run_cmd(cmd)
  puts 'Running: ' + cmd if $opts.verbose or $opts.dry_run
  `#{cmd}` unless $opts.dry_run
end

if __FILE__ == $0
  $opts = parse_args

  # Make thumbs/ and full-size/ dirs.
  unless $opts.dry_run or $opts.yaml
    File.makedirs($opts.full_size) unless File.directory?($opts.full_size)
    File.makedirs($opts.thumbs) unless File.directory?($opts.thumbs)
  end

  # Generate data.yml
  puts 'Generating data.yml ...'
  run_cmd('rm -rf data.yml')
  data_file = File.new('data.yml', 'w')
  $opts.files.sort.each do |f|
    local = File.basename(f)
    data_file.puts("- - #{$opts.thumbs}/#{local}")
    data_file.puts("  - #{local}")
    data_file.puts("  - ''")
  end
  data_file.close

  # If "just make YAML", then we're done.
  exit if $opts.yaml

  # Move current images to "full-size" dir.
  run_cmd("mv #{$opts.files.reduce{|a,b|a+' '+b}} #{$opts.full_size}")

  # Image resizes.
  scripts_dir = File.dirname(__FILE__)
  Dir.chdir($opts.dry_run ? '.' : $opts.full_size) do
    $opts.files.peach($opts.procs) do |f|
      local = File.basename(f)
      run_cmd("#{scripts_dir}/resize.rb #{local} #{$opts.size} ../")
      run_cmd("#{scripts_dir}/resize.rb #{local} #{$opts.thumb_size} ../#{$opts.thumbs}")
    end
  end
end
