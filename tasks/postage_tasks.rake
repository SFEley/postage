namespace :postage do
  
  desc 'Do the initial postage installation.'
  task :setup => :environment do
    
    if (key = ENV['API_KEY']).blank?
      print 'Please enter the API key: '
      key = STDIN.gets.gsub("\n", '')
    end
    
    filename = "#{Rails.root}/config/initializers/postage.rb"
    
    output = "
# Tell ActionMailer to use Postage App
ActionMailer::Base.delivery_method = :postage

# Specify the Postage API key
Postage.configure do |config|
  config.api_key      = '#{key}'
  config.api_version  = '1.0'
end
"
    File.open(filename, 'w'){|file| file.write(output)}
    puts "Created intializer: #{filename}"
    puts "With the following content: \n#{output}"
  end
  
  desc 'Check current plugin configuration'
  task :current_config => :environment do
    config_accessors = [
      [:api_key,            '               API Key: '],
      [:api_version,        '           API version: '],
      [:url,                'PostageApp service URL: '],
      [:recipient_override, '    Recipient Override: ']
    ]
    
    config_accessors.each do |k, v|
      puts "#{v} #{Postage.send(k).inspect}"
    end
  end
  
  desc 'Verify postage plugin installation by requesting project info from PostageApp.com'
  task :test => :environment do 
    puts "Attempting to contact PostageApp..."
    response = Postage::Request.new(:get_project_info).call!
    if response.blank?
      puts 'Failed to recieve a response. Check your configuration please.'
    else
      if response[:response] == 'success'
        puts %{
  Account details
  --------------------------- 
  Name: #{response[:account][:name]}
  URL: #{response[:account][:url]}
  Transmissions:
    this month: #{response[:account][:transmissions][:this_month]}
    today: #{response[:account][:transmissions][:today]}
    overall: #{response[:account][:transmissions][:overall]}

  Project details
  --------------------------- 
  Name: #{response[:project][:name]}
  URL: #{response[:project][:url]}
  Transmissions:
    this month: #{response[:project][:transmissions][:this_month]}
    today: #{response[:project][:transmissions][:today]}
    overall: #{response[:project][:transmissions][:overall]}
        }
        puts 'Everything seems to be in order.'
      else
        puts "Received unexpected response: #{response[:error][:message]}"
        puts 'Check your configuration please.'
      end
    end
  end
  
end