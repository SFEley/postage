gem 'httparty'

require 'postage'

ActionMailer::Base.send :include, Postage::Mailer