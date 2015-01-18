module RBFS
  class File
    attr_accessor :data_type
    attr_accessor :data

    def initialize(data = nil)
      @data = data
    end

    def self.parse(string_data)
      type_data, data = string_data.split(':', 2)
      if    type_data == 'string' then File.new(data)
      elsif type_data == 'symbol' then File.new(data.to_sym)
      elsif type_data == 'nil'    then File.new
      elsif data.include?('.')    then File.new(data.to_f)
      elsif type_data == 'number' then File.new(data.to_i)
      else                             File.new(data == 'true')
      end
    end

    def data_type
      case @data
      when String                then :string
      when Symbol                then :symbol
      when Fixnum, Float         then :number
      when TrueClass, FalseClass then :boolean
      when NilClass              then :nil
      end
    end

    def serialize
      data_type.to_s + ':' + @data.to_s
    end

    def self.parse_files(string_data)
      files = Hash.new
      file_counter = string_data.partition(':').first.to_i
      not_parsed = string_data.partition(':').last
      file_counter.times do
        file_name, file_size, tail = not_parsed.split(':', 3)
        files[file_name] = File.parse tail[0, file_size.to_i]
        not_parsed = tail[file_size.to_i, not_parsed.size]
      end
      [files, not_parsed]
    end
  end

  class Directory
    attr_accessor :files, :directories
    def initialize
      @directories = Hash.new
      @files = Hash.new
    end

    def add_file(name, file)
      @files[name] = file
    end

    def add_directory(name, directory = RBFS::Directory.new)
      @directories[name] = directory
    end

    def []=(name, file)
      if file.is_a? RBFS::Directory 
        @directories[name] = file
      else
        @files[name] = file
      end
    end

    def [](name)
      (@files[name] || @directories[name])
    end

    def serialize
      serialized = @files.size.to_s + ':'
      @files.each do |name, file|
        file_string = file.serialize
        serialized += name + ':' + file_string.size.to_s + ':' + file_string
      end
      serialized += @directories.size.to_s + ':'
      @directories.each do |name, directory|
        directory_string = directory.serialize
        serialized += name + ':' + directory_string.size.to_s + ':' + directory_string
      end
      serialized
    end

    def self.parse(string_data)
      directories, (files, not_parsed) ={}, File.parse_files(string_data)
      directory_counter = not_parsed.partition(':').first.to_i
      not_parsed = not_parsed.partition(':').last
      directory_counter.times do
        folder_name, folder_size, tail = not_parsed.split(':', 3)
        directories[folder_name] = Directory.parse(tail[0, folder_size.to_i])
        not_parsed = tail[folder_size.to_i, not_parsed.size]
      end
      directory = Directory.new
      directory.files = files
      directory.directories = directories
      directory
    end
  end
end
