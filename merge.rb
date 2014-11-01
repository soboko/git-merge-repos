#! /usr/bin/env ruby
# encoding: utf-8
# @author chris

require 'optparse'
require 'fileutils'
require 'colorize'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: merge.rb [options]"
  opts.on('-u', '--username NAME', 'Username') { |v| options[:user_name] = v }
  opts.on('-h', '--host NAME', 'Git repo host') { |v| options[:host] = v }
  opts.on('-p', '--port NAME', Integer, 'Git repo port') { |v| options[:port] = v }
end.parse!

port = options[:port] || 22
username = options[:user_name] || ENV['USER']
fail "Hostname not provided, type --help for help" unless options[:host]
host = options[:host]

cwd = Dir.pwd
repos_dir = "#{cwd}/repos"
FileUtils::rm_rf repos_dir
FileUtils::mkdir_p repos_dir

repos = Array.new
$stdin.each_line do |line|
  repo = line.strip
  puts "* Cloning #{repo}...".green
  repos.push("#{repos_dir}/#{repo}:#{repo}")
  Dir.chdir("#{repos_dir}")
  `git clone ssh://#{username}@#{host}:#{port}/#{repo}`
  Dir.chdir("#{repos_dir}/#{repo}")
  `git checkout develop`
end

Dir.chdir(cwd)
puts "Merging repos...".green
`mvn clean compile exec:java -Dexec.args="#{repos.join(' ')}"`
puts "Done.".green