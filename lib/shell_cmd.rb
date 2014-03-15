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
    @result = popen_exec
    unless result.success?
      fail ShellCmdError, self 
    end
    result
  end

  alias_method :run, :execute

private
  def popen_exec
    popen_args = [environment, command, *arguments, err: [:child, :out]]
    out = IO.popen(popen_args) { |io| io.read }
    CommandResult.new(self, $?, out)
  rescue Errno::ENOENT => err
    CommandResult.new(self, NullProcess, "Command not found.\n")
  end
end

require 'shell_cmd/error_file'
require 'shell_cmd/errors'
require 'shell_cmd/shell_environment'
require 'shell_cmd/command_result'
require 'shell_cmd/null_process'



