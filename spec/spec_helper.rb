$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'active_record'
require 'activerecord-recursive_tree_relations'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Base.establish_connection(YAML.load(File.read(File.join(File.dirname(__FILE__), 'database.yml'))))

RSpec.configure do |config|
  config.before(:suite) do
    CreateSchema.suppress_messages{ CreateSchema.migrate(:up) }
  end

  config.after(:suite) do
    CreateSchema.suppress_messages{ CreateSchema.migrate(:down) }
  end
end
