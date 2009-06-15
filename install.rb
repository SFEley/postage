unless (Postage.config.exist?)
  Postage.config.create!
end

puts "==========================================================================="
puts "  Postage plugin successfully installed"
puts "==========================================================================="
puts ""
puts "  Check the configuration file and make any changes as required:"
puts ""
puts "     #{Postage.config.config_file_path}"
puts ""
puts "  Testing required Ruby Gems:"

missing_gems = [ ]
required_gems = %w[ httparty crack ]

required_gems.each do |gem_name|
  found = false
  begin
    gem gem_name
    
    found = true
  rescue
    missing_gems << gem_name
  end
  
  puts "    #{gem_name} = #{found ? 'Installed' : 'Not found'}"
end

unless (missing_gems.empty?)
  puts ""
  puts "  The missing gems can usually be installed with:"
  puts ""
  puts "     % sudo gem install #{missing_gems}"
end

puts ""
puts "  Don't forget to add the gem dependencies to the environment.rb file:"
puts ""
required_gems.each do |gem_name|
  puts "    config.gem '#{gem_name}'"
end

puts ""
puts "==========================================================================="
puts "  http://postageapp.com/"
puts "==========================================================================="
