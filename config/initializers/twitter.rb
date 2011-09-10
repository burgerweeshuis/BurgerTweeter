raw_config = File.read(File.join(File.dirname(__FILE__), '..','twitter.yml'))
TWITTER = YAML.load(raw_config)