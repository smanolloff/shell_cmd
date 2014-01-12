class ShellEnvironment < Hash
  def initialize(variables = {})
    super
    set(variables)
  end

  def get(variable)
    self[variable.to_s]
  end

  def set(variables)
    variables.each { |var, val| self[var.to_s] = val.to_s }
    self
  end

  def unset(*variables)
    variables.each { |var| delete(var.to_s) }
    self
  end
end
