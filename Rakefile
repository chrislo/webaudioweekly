require 'nokogiri'

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

  N_DAYS = 90

  (Date.today - N_DAYS..Date.today).reverse_each do |date|
    url = "https://api.pinboard.in/v1/posts/get?tag=waw&dt=#{date.to_s}"
    doc = Nokogiri::XML(open(url, http_basic_authentication: [ENV['PINBOARD_USER'], ENV['PINBOARD_PASSWORD']]))

    posts = doc.xpath('//post')

    posts.each do |post|
      desc = post.attribute('description').value
      href = post.attribute('href').value
      puts "[#{desc.empty? ? 'No description' : desc}](#{href})"
    end
  end
end
