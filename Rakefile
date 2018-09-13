require 'nokogiri'
require 'set'

desc "Put HTML of latest issue on clipboard for pasting into tinyletter"
task :tl do
  # Generate the site
  system("bundle exec jekyll b")

  # Find the latest post
  last_issue = Dir.glob('_site/[0-9][0-9].html').
               map {|f| File.basename(f, '.*') }.
               map(&:to_i).
               sort.
               last

  puts "Copying HTML of issue #{last_issue} to the clipboard"

  fn = File.join(File.dirname(__FILE__), '_site', "#{last_issue}.html")

  # Extract the HTML content
  doc = Nokogiri::HTML(open(fn))
  content = doc.xpath('//div[@class="post-content"]').first.inner_html

  # Copy to clipboard
  IO.popen('pbcopy', 'w') { |f| f << content }
end

desc "Get recent bookmarks from pinboard"
task :pins do
  require 'open-uri'
  require 'date'
  require 'dotenv'
  Dotenv.load

  since = Date.parse(ENV['SINCE']) || (Date.today - 30)

  (since..Date.today).reverse_each do |date|
    url = "https://api.pinboard.in/v1/posts/get?tag=waw&dt=#{date.to_s}"
    doc = Nokogiri::XML(open(url, http_basic_authentication: [ENV['PINBOARD_USER'], ENV['PINBOARD_PASSWORD']]))

    posts = doc.xpath('//post')

    posts.each do |post|
      title = post.attribute('description').value
      link = post.attribute('href').value
      body = post.attribute('extended').value

      title = title.empty? ? 'No title' : title
      body = body.empty? ? 'No body' : body

      puts "- [#{title}](#{link}): #{body}"
    end
  end
end

def all_links
  links = Set.new

  Dir.glob('_site/*.html').each do |fn|
    doc = Nokogiri::XML(open(fn))
    doc.xpath('//a').map do |link|
      links << link.attribute('href').value
    end
  end

  links
end
