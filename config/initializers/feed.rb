raw_config = File.read(File.join(File.dirname(__FILE__), '..','feed.yml'))
FEED = YAML.load(raw_config)
