require 'postage'

# Inject methods into ActionMailer::Base for compabibility
class ActionMailer::Base
  include PostageMailer
end
