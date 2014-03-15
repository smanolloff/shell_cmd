# Public
# Raised if the command failed
class ShellCmdError < RuntimeError
  attr_reader :command

  def initialize(command, message = 'Command failed')
    @command = command
    super(message)
  end

  def report_to_file(dir)
    report = command.result.report

    errfile = ErrorFile.new(dir)
    errfile.write(report)
    errfile.filename
  end
end