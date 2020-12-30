#!/usr/bin/env ruby

require 'metadown'
require 'erb'
require 'fileutils'

issue = ARGV[0]
source_directory = File.join('source', "issue_#{issue}")

source_files = Dir.glob("#{source_directory}/??.md").sort

Issue = Struct.new(:url, :title, :author, :content)

items = source_files.map do |i|
  data = Metadown.render(File.read(i))
  Issue.new(
    data.metadata['url'],
    data.metadata['title'],
    data.metadata['author'],
    data.output
  )
end

intro_file = File.join(source_directory, 'intro.md')
if File.exist?(intro_file)
  intro = Metadown.render(File.read(intro_file))
end

template = ERB.new(File.read('template/newsletter.html.erb'))
result = template.result(binding)
File.open('output/output.html', 'w') { |file| file.write(result) }
FileUtils.cp_r('template/stylesheets', 'output/', remove_destination: true)

require 'premailer'

premailer = Premailer.new('output/output.html',
                          warn_level: Premailer::Warnings::SAFE)

File.open("output/issue_#{issue}.html", 'w') do |file|
  file.write(premailer.to_inline_css)
end
