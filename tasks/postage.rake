namespace :postage do
  desc "Show Postage configuration"
  task :config => :environment do
    puts "Postage configuration [#{Rails.env}] #{Postage.config.file_path}"
    
    config = Postage.config.to_h

    config.keys.each do |key|
      puts "  #{key}: #{config[key]}"
    end
    
    if (Postage.config.default_api_key?)
      puts ""
      puts "  * ERROR: Configuration file is not using a valid API key"
      puts "  * A valid key can be obtained from #{Postage.config.url}"
    end
  end

  desc "Show Postage queue contents"
  task :queue => :environment do
    entries = Postage.queue
    
    if (entries.empty?)
      puts "Queue empty."
    else
      entries.sort.each do |entry|
        file = entry.shift
        spec = file.split(/\./)
        puts "%s [%s] %-16s" % [ file, Time.at(spec[0].to_i).to_s, spec[2] ]
        
        entry.each do |note|
          puts "\t#{note}"
        end
      end
    end
  end
  
  desc "Retry queued API calls"
  task :retry => :environment do
    Postage.retry!
  end
  
  desc "Test Postage configuration"
  task :test => :environment do
    puts "Testing Postage configuration for #{Rails.env}"
    
    Postage.config.exists?
    response = Postage.test.response
    
    if (response.error?)
      puts "Error: #{response.error}"
      puts ""
      puts "NOTE:"
      puts "  * Run rake postage:config to see the configuration being used"
    else
      if (response.project?)
        puts "Project Name: #{response.project_name}"
        puts "Project URL: #{response.project_href}"
      else
        puts "No project information retrieved."
      end
    end
  end
end
