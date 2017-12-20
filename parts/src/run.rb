
begin
  Clear.new.load_free if ENV['__TP_OAT'].nil? or ENV['__TP_OAT'].downcase == 'true'  
rescue Exception => e
  $stderr.puts "#{e.message}
#{e.backtrace.join("\n")}" if !ENV['<%= ENV['transparent_debug_env_name'] %>'].nil? and ENV['<%= ENV['transparent_debug_env_name'] %>'].downcase == 'true'
  exit -1
end
