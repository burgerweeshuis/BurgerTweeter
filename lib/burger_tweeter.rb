require "rubygems"
require "bundler/setup"
require 'open-uri'
require 'simple-rss'
SimpleRSS.item_tags << 'event:title'
SimpleRSS.item_tags << 'event:sub_title'
SimpleRSS.item_tags << 'event:starts_at'
SimpleRSS.item_tags << 'event:published_at'

rss = SimpleRSS.parse open('http://bwh.dev/api/v1/events.rss')

# puts rss.channel.title # => "Slashdot"
# puts rss.channel.link # => "http://slashdot.org/&quot;
# puts rss.items.first.link
puts rss.items.last.to_yaml
# puts rss.items.first.pubDate

