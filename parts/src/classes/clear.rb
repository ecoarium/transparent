require 'json'
require 'symmetric-encryption'

class Clear

  attr_reader :encrypted_confile_file_env_name
  attr_reader :encrypted_source_file_ext_env_name
  attr_reader :encryption_source_dir_path_env_name

  def initialize
    @encrypted_confile_file_env_name = '<%= ENV['transparent_encrypted_confile_file_env_name'] %>'
    @encrypted_source_file_ext_env_name = '<%= ENV['transparent_encrypted_source_file_ext_env_name'] %>'
    @encryption_source_dir_path_env_name = '<%= ENV['transparent_encryption_source_dir_path_env_name'] %>'

    SymmetricEncryption.cipher = SymmetricEncryption::Cipher.new(symmetric_encryption_config_content[:ciphers].shift)
    SymmetricEncryption.secondary_ciphers = SymmetricEncryption::Cipher.new(symmetric_encryption_config_content[:ciphers].shift) unless symmetric_encryption_config_content[:ciphers].empty?
  end

  def debug(message='')
    return unless !ENV['<%= ENV['transparent_debug_env_name'] %>'].nil? and ENV['<%= ENV['transparent_debug_env_name'] %>'].downcase == 'true'

    message_from_block = yield if block_given?

    if message_from_block.is_a?(String)
      message = "#{message}\n#{message_from_block}"
    end

    puts message
  end

  def default_symmetric_encryption_config_content
    {
      private_rsa_key: "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAuAzyV+2MKbwUiGKK7xuxRhaoBzcjnWqxBwqJnqPR1Dihkv6B\nafjfoEJHervzeMPDr9ICZivu+K4Wit1CZB3Ty2f2Bi7jSlu4nUKk5lqegGMemTYl\nRQuoJVHHLaDzLZwHBHkinewS08xROAZ/QYGkBycxkjAoSrWuXGQffHhL0mjzfy5x\n/jf4Bw4leIyIlmqMU6Hwfgjn8EYoOx1olXuvroflmlRKpa/Q87qOg7t5eHkinc6G\nYi4LSCM37uokL7d+XJCmpv3G+L4fBoR6HIqyrmR8W2VkqcQUeHhAPMVuaRlDU91O\nsWOZ2ru5WbbifW2Bgt5UYfic1emN7JTid509bwIDAQABAoIBAHbnxlmQGpGL9Sf3\nohLALVM+p+ehc9zrZNtLr4VSCOm2fIxe6HTyWGdM6qkcbDuFHhOk9e/USltW/TFR\nqObNbltnGsb729PaVfcjay13Nhdz8fzBwmpNEaCqqKeN6A17U/1L1VV5guBai85K\nRESp4LLOW3Q6sI0zuyXteXoMrc+M7QhMpQuVChAosT414wBoBWn7Z8Nw6Drxh1rq\n5k2zu8CJSYaKInQZHKBBk0txArDpu8S+ifPf9Qexg1+cCVn10YxOyqcWj39GtS6r\nOB/5sexrQa+QGAeDeD/4S6as0wOgG+sqFudoCCQIM5mwwEsvVN4zMMVOcXPK1J7O\nKWaHzCECgYEA6vwnUrbjTi5czKnqIf7BncGu7y3FJMGeI5T9ZaMmHadCwX0qMvMe\nYDlBWhsV4cDfiyl7ZJhIMY2XNW2NaxUgwxRAZnUphmK9nZMaBRQrohhPM2LZlNEU\nwioucIcqGDiu+76PQ6YY2gHbxkbl7uo/Hpgnsed2Sm82IaokZHhGtgMCgYEAyIKt\n2LqoPMnNXnke8nD+ZCukGkFjAvvO93DtoF0+nCLb7FHdr4S9Z5QBd3fVUj7p1Xlw\nI0w4XWUV2MFDUqS3HlUCNiV8wkenI4HgS2o2qgESOZikJQdp4yd3w/YtpY/nS6aV\nybwwUVhBifQM8V/czzui+nYQUgyPoFgwctgHpSUCgYB9JGh0vn1zZ3F4dY0BKcFH\nGJznN8Lj/lEPtgr1E9v6stb0YIoWtC8bI6LQL9iJb8QdQqw6OHdKHJPIml1UB954\nxdI+Pmss7Gz6/BpBViqemr+jKCOkA21AsmIk/3bFi3p1C1kUt+JIR/EZOSy+/fU7\nf+Cz+AahQXTcnNXgw8U0rQKBgE9+t+wIPPE01O5SuPlH4SPXxYz/RYEGUoz5wcxl\ni5AdpfGwl2KiDvHE1TwHT5T3CoAvUE0+R86HaDzyin12fn9RFrpe7HKeM964/DMK\nHjgSiqY5JULlCI8ds7cGoBxWzE3K8vHzYXius/U8w/Din8mtjDUen+PXxQ2+SR8P\nFSDdAoGAEwJK85v3iZvZkmxlhKeWRhajNHLjrYn+Dca9GtSbIAAZVi0nH91BsgX9\nJiE7HypO7HDkySFlR0OWRV87MvOI/ulPPQQuPAdE13yD/06FFpiD1YSbvYV++gfK\ntAJi/LoeHUpKl6eTX/W+im+fQnl2mhewp3fyPCK6CIcjbDppkTA=\n-----END RSA PRIVATE KEY-----\n",
      ciphers: [
        {
          key: "YN2P7jYoNvvMbC7iAfnuzOOpwrLs0nSXXX/fJVRXL0poHlv05hW6lpEbJPZ3\ntrHtygcDw7QVOGaDW/EM6297jGf1flosjwYWpRNabmWM9N68RY7kfjdCbLaW\nNT0cpLClzm51FJodyRwmxTaeJY6Ox/GXNuNju7H9N+aDkV9nGfgDrL/no6nz\nc/XnV5Hqeg8ZTfU5wHADIP7sYRZ0lgJBSU5GhIH1EAVLXjH31PmqL6vCkEyP\nGqhqiSf4icZEB0YfIDL87jSVykr9a+9c6wuo84sPRGQBTQuMyjueQ10PwdiE\nQNDeVeAHwD7dcz9T6v2TimFcL4MK8ZVgLdZz6b5E8g==\n",
          iv: "SUtQZrwz0eYDqwyZWutV02STW7qy/i9EZRembTEa6jyBdHe+VoZ9k6G2zos8\nsZ97RpXzBRH8ZKBm3HRxFrt7mpd6FoFw6Qygc6+vWJ7vQWETrG47O1jq/Js4\ndl5xZBEL025pb8d8TbMihjjBgRqB7YvbteosT3olq7LW+HQmW3yb3y/iD4pd\npqD4RYHT3gGT2MSCb93GXeK2x9jjwZ37hH3ewCrDGhxBoBjjJAppFcMKDBec\nVScVEPoR6+hH9Q/AaR0siQcDGeAY2puZK2FwHFjoWJKR3+CARdPb6niKQ1lv\nB4NZE2OYbehPc3A2C5dPzxxTjXATNrd2lDwPf72kGQ==\n"
        }
      ]
    }
  end

  def read_env_var(name)
    unmangled_string = ObsfucateString.new.unmangle(ENV[name])
    unmangled_string = eval unmangled_string

    debug "read_env_var(#{name}) -> #{unmangled_string}"

    unmangled_string
  end

  def symmetric_encryption_config_content
    return @symmetric_encryption_config_content unless @symmetric_encryption_config_content.nil?

    if ENV[encrypted_confile_file_env_name].nil?
      debug 'using default symmetric encryption config content'
      @symmetric_encryption_config_content = default_symmetric_encryption_config_content
    else
      encryption_confile_file_path = read_env_var(encrypted_confile_file_env_name)

      mangled_encryption_config_content = File.read(encryption_confile_file_path)
      encryption_config_content = ObsfucateString.new.unmangle(mangled_encryption_config_content)

      @symmetric_encryption_config_content = JSON.parse(
        encryption_config_content,
        symbolize_names: true
      )
    end

    @symmetric_encryption_config_content
  end

  def load_free
    source_dir_path = File.expand_path('../load', File.dirname(caller[0].split(':')[0]))

    unless ENV[encryption_source_dir_path_env_name].nil?
      source_dir_path = read_env_var(encryption_source_dir_path_env_name)
    end

    file_ext = 'eb'

    unless ENV[encrypted_source_file_ext_env_name].nil?
      file_ext = read_env_var(encrypted_source_file_ext_env_name)
    end

    Dir.glob("#{source_dir_path}/*.#{file_ext}") { |file|
      debug "loading: #{file}"

      source_code_buffer = StringIO.new
      SymmetricEncryption::Reader.open(file, compress: true) do |reader|
        reader.each_line{ |line|
          source_code_buffer.puts line
        }
      end


      debug{source_code_buffer.string}

      eval(source_code_buffer.string)
    }
  end

  def encrypt_file(source_file_path, target_file_path)
    SymmetricEncryption::Writer.open(target_file_path, compress: true) do |writer|
      File.open(source_file_path, 'r'){ |reader|
        reader.each_line do |line|
          writer.write line
        end
      }
    end
  end

  def decrypt_file(source_file_path, target_file_path)
    File.open(target_file_path, "w") { |writer|
      SymmetricEncryption::Reader.open(source_file_path, compress: true) do |reader|
        reader.each_line{ |line|
          writer.write(line)
        }
      end
    }
  end

  def create_key_pair(key_dir)
    encryption_config_file = File.expand_path("config.json", key_dir)
    private_key_path = File.expand_path("id_rsa", key_dir)
    public_key_path = File.expand_path("id_rsa.pub", key_dir)

    key_pair = SSHKey.generate(:type => "RSA", :bits => 2048)#, :passphrase => SecureRandom.hex)

    FileUtils.mkdir_p(key_dir) unless File.exist?(key_dir)
    command = "chmod 0700 #{key_dir}"
    output = `#{command}`
    raise "the following command failed with exit_code [#{$?.exitstatus}]:
#{command}" if $?.exitstatus != 0

    File.open(private_key_path, 'w') do |file|
      file.write(key_pair.private_key)
    end
    command "chmod 0600 #{private_key_path}"
    output = `#{command}`
    raise "the following command failed with exit_code [#{$?.exitstatus}]:
#{command}" if $?.exitstatus != 0

    File.open(public_key_path, 'w') do |file|
      file.write(key_pair.ssh_public_key)
    end
    command "chmod 0644 #{public_key_path}"
    output = `#{command}`
    raise "the following command failed with exit_code [#{$?.exitstatus}]:
#{command}" if $?.exitstatus != 0

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
end
