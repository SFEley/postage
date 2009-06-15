namespace :postage do
  desc "Show Postage configuration"
  task :config => :environment do
    puts "Postage configuration [#{Rails.env}]"

    Postage.config.keys.each do |key|
      puts "  #{key}=#{Postage.config[key]}"
    end
  end
  
  desc "Test Postage configuration"
  task :test => :environment do
    puts "Testing Postage configuration for #{Rails.env}"
    
    Postage.config.exists?
    result = Postage.new.test
    
    if (result['error'])
      puts "Error: #{result['error']['message']}"
      puts "NOTE: Run rake:config to see the configuration being used"
    else
      if (result['project'])
        puts "Project URL: #{result['project']['href']}"
      else
        puts "No project information retrieved."
      end
    end
  end
end
