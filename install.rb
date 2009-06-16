#
# Postage plugin installation script
#

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

require 'postage'

# -- Configuration ----------------------------------------------------------

# -- Announcement -----------------------------------------------------------

puts "==========================================================================="
puts "  Postage plugin successfully installed"
puts "==========================================================================="
puts ""

unless (Postage.config.exists?)
  puts "  No configuration file found, so generating an example one."
  Postage.config.create!
  puts ""
end

puts "  Check the configuration file and make any changes as required:"
puts ""
puts "     #{Postage.config.file_path}"
puts ""
puts "  Testing required Ruby Gems:"

missing_gems = [ ]
required_gems = %w[ httparty crack ]

required_gems.each do |gem_name|
  found = false
  begin
    gem gem_name
    
    found = true
  rescue Gem::LoadError
    missing_gems << gem_name
  end
  
  puts "    #{gem_name} = #{found ? 'Installed' : 'Not found'}"
end

unless (missing_gems.empty?)
  puts ""
  puts "  The missing gems can usually be installed with:"
  puts ""
  puts "     % sudo gem install #{missing_gems * ' '}"
end

puts ""
puts "  Don't forget to add the gem dependencies to the environment.rb file:"
puts ""
required_gems.each do |gem_name|
  puts "    config.gem '#{gem_name}'"
end

puts ""
puts "==========================================================================="
puts ""
puts "  Check that the plugin is installed correctly using:"
puts ""
puts "    rake postage:test"
puts ""
puts "==========================================================================="
puts "  http://postageapp.com/"
puts "==========================================================================="
