require "rubygems"
require "bundler/setup"
require 'open-uri'
require 'simple-rss'

# load config stuff
Dir[File.expand_path(File.join(File.dirname(__FILE__),'..','config','initializers','**','*.rb'))].each {|f| require f}

# add some extra tags defined in stream
SimpleRSS.item_tags << 'event:title'
SimpleRSS.item_tags << 'event:sub_title'
SimpleRSS.item_tags << 'event:opens_at'
SimpleRSS.item_tags << 'event:starts_at'
SimpleRSS.item_tags << 'event:published_at'

rss = SimpleRSS.parse open(FEED[:url])

# puts rss.channel.title # => "Slashdot"
# puts rss.channel.link # => "http://slashdot.org/&quot;
puts rss.items.first.to_yaml
# puts rss.items.first.pubDate

def snip(url)
  begin
    open("http://burgr.nl/api?url=#{url}").string
  rescue
    url
  end
end

# puts snip(rss.items.first.link)

def tweet_upcoming_items(rss)
  rss.items.each do |event|
    opens_at = Time.parse(event.event_opens_at).utc
    if (opens_at - Time.now.utc) < 3700 # kleiner dan 1 uur
      time = "#{opens_at.hour}:#{"%02d" % opens_at.min}"
      string = "Vandaag in @burgerweeshuis om #{time}: #{event.event_title}, #{snip(event.link)}"
      tweet_it(:upcoming, string, event)
    end
  end
end

def tweet_expected_items
  snipped_link = snip(link)
  string = "Verwacht: #{item.title}, #{item.date.day} #{NL_ABBR_MONTHNAMES[item.date.month]} #{item.date.year}"[0...(120-snipped_link.size)]
  string << ", #{snipped_link}"
  tweet_it(:expected, string)
end

def tweet_it(account_type, string, event = nil)
  raise ArgumentError "Invalid Account Type (#{account_type})" unless [:upcoming, :expected].include?(account_type)
  # puts "Passing to twitter: '#{string}'" 
  # oauth = Twitter::OAuth.new(TWITTER[:key], TWITTER[:secret])
  # oauth.authorize_from_access(TWITTER[account_type][:access_token], TWITTER[account_type][:access_secret])
  # 
  # tweeter = Twitter::Base.new(oauth)
  # if tweeter.update(string)
  #   event.update_attribute(:posted_at, DateTime.now) if event && account_type == :upcoming
  #   sleep 120
  # end
  puts "Should pass to twitter: '#{string}'" 
end

tweet_upcoming_items(rss)
