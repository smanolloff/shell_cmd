class ErrorFile
  attr_reader :filename

  def initialize(dir)
    @filename = self.class.generate_name(dir)
    # Touch the file to prevent other instances from
    # taking the generated name.
    FileUtils.touch(@filename)
  end

  def write(content)
    File.open(@filename, 'a') { |f| f.write(content) }
  end

  def delete
    FileUtils.rm(@filename)
  end

  private
  def self.generate_name(dir)
    unless File.directory?(dir)
      fail ArgumentError, "Directory does not exist: #{dir}" 
    end

    base = File.join(dir, "error_#{Time.now.to_i}")
    suffix = ''
    failed = 10.times do |i|
      break unless File.exists?(base + suffix)
      suffix = "-#{i}"
    end
    fail "Failed to generate filename in #{dir} (10 attempts)" if failed

    base + suffix
  end
end