RSpec.configure do |config|
  config.after(:each) do
    Current.reset
  end
end
