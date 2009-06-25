ENV['RAILS_ENV'] = 'test'

require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'postage'

module RailsEnvironment
  module TestEnvironment
    def self.root
      File.dirname(__FILE__)
    end
  end
  
  def self.default
    TestEnvironment
  end
end