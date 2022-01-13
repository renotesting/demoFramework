result = %x[gem list bundler -i]
if result =~ /true/i
  puts "Bundler already installed"
else
  puts %x[gem install bundler]
end
file = File.join(File.dirname(__FILE__),'Gemfile')
puts %x[bundle install --gemfile=#{file} --binstubs --clean --jobs=4 --path vendor]
puts