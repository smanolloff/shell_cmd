# Public
# Raised if the command failed
class ShellCmdError < RuntimeError
  attr_reader :command

  def initialize(command)
    @command = command
    super("Command failed")
  end

  def report_to_file(file)
    if command.result
      report = command.result.report
    else
      report = "Command not found -- #{command.command}"
    end

    errfile = ErrorFile.new(file)
    errfile.write(report)
    errfile.filename
  end
end