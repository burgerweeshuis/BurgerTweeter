raw_config = File.read(File.join(File.dirname(__FILE__), '..','environment.yml'))
APP_ENV = YAML.load(raw_config)

