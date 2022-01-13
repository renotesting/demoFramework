require 'minitest/unit'
require 'rspec'
World(MiniTest::Assertions)
@browser = nil

at_exit do
  #@browser.database_layer.close_all() unless @browser.nil?
end