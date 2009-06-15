require 'fileutils'

gem 'httparty'

require 'postage'

# Install the perform_delivery_postage method into ActionMailer
class ActionMailer::Base
  include Postage::Mailer
end
