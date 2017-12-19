require 'fileutils'
require File.expand_path('../parts/src/classes/obsfucate_string.rb', File.dirname(__FILE__))

test_dir = File.expand_path('test_dir', File.dirname(__FILE__))

FileUtils.rm_rf test_dir if File.exist?(test_dir)
FileUtils.mkdir test_dir

system("rake encrypt_file[#{File.expand_path('test2.rb', File.dirname(__FILE__))},#{test_dir}/test2.png]")

def set_env_var(name, value)
  ENV[name] = ObsfucateString.new.mangle(value)
end

{
  '__TP_CJK' => File.expand_path('../.keys/config.json', File.dirname(__FILE__)),
  '__TP_XET' => 'png',
  '__TP_OAL' => test_dir
}.each{|name,value|
  set_env_var(name, value)
}

$:.push File.expand_path('../lib', File.dirname(__FILE__))

require 'transparent'

Kernel.exec('bash')
