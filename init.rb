# Gem Dependencies

gem 'httparty'

# Standard Libraries

require 'fileutils'

# Custom Library

require 'postage'

# Install the perform_delivery_postage method into ActionMailer
class ActionMailer::Base
  include Postage::Mailer
end
