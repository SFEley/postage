require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_support'
require 'action_mailer'
require 'postage'
require 'redgreen' unless ENV['TM_FILEPATH']

class Test::Unit::TestCase
  
end
