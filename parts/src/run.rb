
begin
  Clear.new.load_free if ENV['__TP_OAT'].nil? or ENV['__TP_OAT'].downcase == 'true'  
rescue Exception => e
  $stderr.puts "#{e.message}
#{e.backtrace.join("\n")}" if !ENV['__TP_GEB'].nil? and ENV['__TP_GEB'].downcase == 'true'
  exit -1
end
