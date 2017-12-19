require 'base64'
require 'stringio'

class ObsfucateString

  def alternate_every_other(data, size)
    mixed_up = []
    the_other = nil
    data.each do |item| 
      mixed_up.push(item)
      mixed_up.push(the_other) unless the_other.nil?
    end
    mixed_up.join()
  end

  def reverse_by_two(data, size)
    make_array_count(size, data)
    mixed_up = []
    data.each_slice(2){|two_items|
      two_items = make_array_count(2, two_items)
      reversed_two_items = two_items.reverse
      mixed_up.push(reversed_two_items)
    }
    mixed_up.join()
  end

  def make_array_count(count, array)
    while array.length > count
      array << nil
    end
    array
  end

  def unmangle(string)
    decoded = Base64.decode64(string)
    tangle(decoded)
  end

  def mangle(string)
    tangle_string = tangle(string)    
    Base64.encode64(tangle_string).strip
  end

  def tangle(string)
    string_array = string.chars

    obsfucated_content = StringIO.new

    alternate_algorithms = {
      alternate_every_other: :reverse_by_two,
      reverse_by_two: :alternate_every_other
    }

    algorithm = alternate_algorithms.keys[0]
    chunk_size = 4
    string_array.each_slice(chunk_size){|chunk|
      algorithm = alternate_algorithms[algorithm]
      mixed_up = send(algorithm, chunk, chunk_size)
      obsfucated_content.write mixed_up
    }

    obsfucated_content.string
  end
end