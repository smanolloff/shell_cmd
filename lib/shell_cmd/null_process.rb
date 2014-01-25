class NullProcess
  def self.exitstatus
    127
  end

  def self.pid
    '(none)'
  end

  def self.success?
    false
  end
end