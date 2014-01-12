require 'shell_cmd/version'

class ShellCmd
  attr_reader :command, :arguments, :environment, :result

  def initialize(command, *arguments)
    @command = command
    @arguments = arguments
    @environment = ShellEnvironment.new
  end

  def add_argument(argument)
    arguments.push(argument.to_s)
    self
  end

  def add_arguments(*arguments)
    arguments.each { |arg| add_argument(arg) }
    self
  end 

  def illustrate
    args = arguments.map { |arg| "'#{arg}'" }.join(' ')
    "#{command} #{args}"
  end

  def execute
    begin
      io = IO.popen([
        environment,
        command, 
        *arguments, 
        err: [:child, :out]
      ])
      output = io.read
    rescue Errno::ENOENT => err
      raise ShellCmdError, self
    ensure
      if defined?(io) && io.respond_to?(:close)
        io.close
      end
    end

    @result = CommandResult.new(self, $?, output)
    unless result.success? 
      raise ShellCmdError, self
    end
    result
  end

  alias_method :run, :execute
end

require 'shell_cmd/error_file'
require 'shell_cmd/errors'
require 'shell_cmd/shell_environment'
require 'shell_cmd/command_result'


