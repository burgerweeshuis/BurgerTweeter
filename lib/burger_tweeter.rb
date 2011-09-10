require "rubygems"
require "bundler/setup"
require 'open-uri'
require 'simple-rss'

# load config stuff
begin
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'..','config','initializers','**','*.rb'))].each {|f| require f}
rescue Errno::ENOENT => e
  raise "\n\e[1;37;44m\n\nPlease create the proper config file!\n\n#{e.message}\n\n\e[0m"
end

# add some extra tags defined in stream
SimpleRSS.item_tags << 'event:date'
SimpleRSS.item_tags << 'event:title'
SimpleRSS.item_tags << 'event:sub_title'
SimpleRSS.item_tags << 'event:opens_at'
SimpleRSS.item_tags << 'event:starts_at'
SimpleRSS.item_tags << 'event:published_at'

def snip(url)
  begin
    open("http://burgr.nl/api?url=#{url}").string
  rescue
    url
  end
end

def upcoming_items
  rss = SimpleRSS.parse open(FEED[:upcoming_url])
  rss.items.each do |event|
    opens_at = Time.parse(event.event_date).utc
    should_we_tweet = (opens_at - Time.now.utc)
    if should_we_tweet < APP_ENV[:interval] && should_we_tweet > 0 # kleiner dan 1 uur
      snipped_link = snip(event.link)
      time = "#{opens_at.hour}:#{"%02d" % opens_at.min}"
      string = "Vandaag in @burgerweeshuis om #{time}: #{event.title}"[0...(120-snipped_link.size)]
      string << " #{snipped_link}"
      tweet_it(:upcoming, string)
    end
  end
end

def expected_items
  rss = SimpleRSS.parse open(FEED[:expected_url])
  rss.items.each do |event|
    should_we_tweet = (event.pubDate - Time.now.utc)
    if should_we_tweet < 0 && should_we_tweet > - APP_ENV[:interval] # kleiner dan 1 uur
      date = Time.parse(event.event_date).utc
      snipped_link = snip(event.link)
      string = "Verwacht in @burgerweeshuis: #{event.title}, #{date.day} #{NL_ABBR_MONTHNAMES[date.month]} #{date.year}"[0...(120-snipped_link.size)]
      string << " #{snipped_link}"
      tweet_it(:expected, string)
    end
  end
end

def tweet_it(account_type, string)
  raise ArgumentError "Invalid Account Type (#{account_type})" unless [:upcoming, :expected].include?(account_type)
  if APP_ENV[:state] == 'production'
    puts "Passing to twitter: '#{string}'"
    oauth = Twitter::OAuth.new(TWITTER[:key], TWITTER[:secret])
    oauth.authorize_from_access(TWITTER[account_type][:access_token], TWITTER[account_type][:access_secret])

    tweeter = Twitter::Base.new(oauth)
    if tweeter.update(string)
      event.update_attribute(:posted_at, DateTime.now) if event && account_type == :upcoming
      sleep 120
    end
  else
    puts "Should pass to twitter: '#{string}'"
  end
end

upcoming_items
expected_items
