require 'postage'
class ActionMailer::Base
  include PostageMailer
end