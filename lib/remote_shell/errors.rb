# Public
# Raised if one or more of the commands in the set have failed
class RemoteShell::CmdSetError < RuntimeError
  attr_reader :cmd_set

  def initialize(cmd_set, message = "Remote execution failed")
    @cmd_set = cmd_set
    super(message)
  end

  def report_to_file(file)
    report = cmd_set.result.report

    errfile = ErrorFile.new(file)
    errfile.write(report)
    errfile.filename
  end
end