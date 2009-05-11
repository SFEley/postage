task :postage do
  desc "Install Configuration"
  
  desc "Test configuration"
  task :test => :environment do
    Postage.config.exists?
  end
end
