require 'bundler/gem_tasks'
require 'bundler/gem_helper'
require 'base64'
require 'json'
require 'symmetric-encryption'
require 'sshkey'
require 'fileutils'
require 'rake/extensiontask'
require 'erb'
require 'stringio'
require 'git'

require File.expand_path('parts/src/classes/obsfucate_string.rb', File.dirname(__FILE__))

raise "
must build native gems
to do so you must execute:

   rake build native gem

" if ARGV.include?('build') and !(ARGV.include?('native') and ARGV.include?('gem'))

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end

Rake.application.remove_task('build')
Rake.application.remove_task('clean')

spec = Gem::Specification.load('transparent.gemspec')
Rake::ExtensionTask.new('engine', spec)

desc "clean"
task :clean do
  %w{
    ext/engine/engine.c
    lib/engine.bundle
    tmp
  }.each{|io_object|
    io_object = File.expand_path("../#{io_object}", File.dirname(__FILE__))
    next unless File.exist?(io_object)
    FileUtils.rm_rf(io_object)
  }
end

desc "mangle env vars"
task :mangle_env_vars do
  %w{
    transparent_encrypted_confile_file_env
    transparent_encrypted_source_file_ext_env
    transparent_encryption_source_dir_path_env
  }.each{|env_var_part|
    env_var_name = ENV["#{env_var_part}_name"]
    env_var_value = ENV["#{env_var_part}_value"]
    mangled_value = ObsfucateString.new.mangle("#{env_var_value}")
    puts "
env_var_name:       #{env_var_name}
env_var_value:      #{env_var_value}
"
    puts "export #{env_var_name}=#{mangled_value}"

    unmangled_string = ObsfucateString.new.unmangle(mangled_value)
    puts "unmangled [value]: [#{unmangled_string}]"

    unmangled_string = eval unmangled_string
    puts "evaluates to[value]: [#{unmangled_string}]"
  }
end


desc "mangle"
task :mangle, :string do |t,args|
  puts ObsfucateString.new.mangle(args[:string])
end

desc "unmangle"
task :unmangle, :env_var do |t,args|
  puts ObsfucateString.new.unmangle(ENV[args[:env_var]])
end

desc "unmangle file"
task :unmangle_file, :file_path do |t,args|
  puts ObsfucateString.new.unmangle(IO.read(args[:file_path]))
end

desc "configure keys"
task :configure_keys do
  create_key_pair
end

desc "encrypt file"
task :encrypt_file, :in, :out do |t, args|
  encrypt_file(args.in, args.out)
end

desc "decrypt file"
task :decrypt_file, :in, :out do |t, args|
  decrypt_file(args.in, args.out)
end

task :create_engine do
  missing_env_vars = false
  missing_env_vars = ENV['transparent_encrypted_confile_file_env_name'].nil?
  missing_env_vars = ENV['transparent_encrypted_source_file_ext_env_name'].nil? unless missing_env_vars
  missing_env_vars = ENV['transparent_encryption_source_dir_path_env_name'].nil? unless missing_env_vars
  missing_env_vars = ENV['transparent_debug_env_name'].nil? unless missing_env_vars

  raise "
one or more of the following environment variables are missing, the values below are examples(consider changing them):
  * export transparent_encrypted_confile_file_env_name=__TP_CJK
  * export transparent_encrypted_source_file_ext_env_name=__TP_XET
  * export transparent_encryption_source_dir_path_env_name=__TP_OAL
  * export transparent_debug_env_name=__TP_GEB

" if missing_env_vars

  source_files_path = File.expand_path("parts/src/classes", File.dirname(__FILE__))
  template_file_path = File.expand_path("parts/templates/engine.c.erb", File.dirname(__FILE__))
  engine_file_path = File.expand_path("ext/engine/engine.c", File.dirname(__FILE__))

  code_content = StringIO.new

  Dir.glob("#{source_files_path}/*"){|source_file_path|
    process_source_file(code_content, source_file_path)
  }

  run_file_path = File.expand_path("parts/src/run.rb", File.dirname(__FILE__))
  process_source_file(code_content, run_file_path)

  code = code_content.string

  File.open(engine_file_path,"w") {|file|
    file.write ERB.new(File.read(template_file_path)).result(binding)
  }
end

def process_source_file(code_content, source_file_path)
  code_content.puts "\\n\\"
  StringIO.open(ERB.new(File.read(source_file_path)).result(binding),"r").each{|line|
    double_slash = "\\\\"
    parts = line.split("\\n")
    line = parts.join("#{double_slash}n")

    line.gsub!(/"/, '\"')
    line.chomp!

    code_content.puts "#{line}\\n\\"
  }
end

helper = Bundler::GemHelper.new
built_gem_path = nil

desc "build"
task :build => [:create_engine, :set_gem_version]

desc "don't call this task"
task :publish  => :build do
  raise "this gem is not published to a gem server"
end

desc "set gem version rev number"
task :set_gem_version do
  version_file = File.expand_path("lib/transparent/version.rb", File.dirname(__FILE__))

  gem_version = Git.version(File.dirname(__FILE__))

  content = File.read(version_file)

  content.gsub!(/(VERSION\s+=\s+["|']\d+\.\d+\.)\d+(["|'])/, '\1' + gem_version + '\2')

  raise "Could not find gem version to set in gem version.rb!" if content == nil

  File.open(version_file, "w") do |fileWriter|
    fileWriter.write content
  end
end

def create_key_pair()
  key_dir = File.expand_path(".keys", File.dirname(__FILE__))
  encryption_config_file = File.expand_path("config.json", key_dir)
  private_key_path = File.expand_path("id_rsa", key_dir)
  public_key_path = File.expand_path("id_rsa.pub", key_dir)

  key_pair = SSHKey.generate(:type => "RSA", :bits => 2048)#, :passphrase => SecureRandom.hex)

  FileUtils.mkdir_p(key_dir)
  sh "chmod 0700 #{key_dir}"

  File.open(private_key_path, 'w') do |file|
    file.write(key_pair.private_key)
  end
  sh "chmod 0600 #{private_key_path}"

  File.open(public_key_path, 'w') do |file|
    file.write(key_pair.ssh_public_key)
  end
  sh "chmod 0644 #{public_key_path}"

  rsa_key = key_pair.key_object

  symmetric_key_pair = SymmetricEncryption::Cipher.random_key_pair('aes-256-cbc')

  config = {
    private_rsa_key: key_pair.private_key,
    ciphers: [
      {
        key: ::Base64.encode64(rsa_key.public_encrypt(symmetric_key_pair[:key])),
        iv: ::Base64.encode64(rsa_key.public_encrypt(symmetric_key_pair[:iv]))
      }
    ]
  }

  key_content = ObsfucateString.new.mangle(JSON.pretty_generate config)

  File.open(encryption_config_file, "wb") { |file| file.write(key_content) }
end

def config_encryption()
  key_dir = File.expand_path(".keys", File.dirname(__FILE__))
  encryption_config_file = File.expand_path("config.json", key_dir)

  mangled_encryption_config_content = File.read(encryption_config_file)
  encryption_config_content = ObsfucateString.new.unmangle(mangled_encryption_config_content)

  config = JSON.parse(
    encryption_config_content,
    symbolize_names: true
  )
  SymmetricEncryption.cipher = SymmetricEncryption::Cipher.new(config[:ciphers].shift)
  SymmetricEncryption.secondary_ciphers = SymmetricEncryption::Cipher.new(config[:ciphers].shift) unless config[:ciphers].empty?
end

def encrypt_file(source_file_path, target_file_path)
  config_encryption
  SymmetricEncryption::Writer.open(target_file_path, compress: true) do |writer|
    File.open(source_file_path, 'r'){ |reader|
      reader.each_line do |line|
        writer.write line
      end
    }
  end
end

def decrypt_file(source_file_path, target_file_path)
  config_encryption
  File.open(target_file_path, "w") { |writer|
    SymmetricEncryption::Reader.open(source_file_path, compress: true) do |reader|
      reader.each_line{ |line|
        writer.write(line)
      }
    end
  }
end
