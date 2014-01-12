class ErrorFile
  attr_reader :filename

  def initialize(dir)
    @filename = self.class.generate_name(dir)
    # Touch the file to prevent other instances from
    # taking the generated name.
    FileUtils.touch(@filename)
  end

  def write(content)
    File.open(@filename, 'a') do |f|
      f.write(content)
    end
  end

  def delete
    FileUtils.rm(@filename)
  end

  private
  def self.generate_name(dir)
    unless File.directory?(dir)
      raise ArgumentError, "Directory does not exist: #{dir}" 
    end

    timestamp = Time.now.to_i
    filename  = File.join(dir, "error_#{timestamp}")

    10.times do |i|
      return filename unless File.exists?(filename)
      filename = File.join(dir, "error_#{timestamp}-#{i}")
    end

    # Loop exited normally -- no suitable name was found
    raise "Failed to generate filename in #{dir}"
  end
end