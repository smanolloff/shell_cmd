class CommandResult
  attr_reader :command, :exit_code, :output, :pid, :report

  def initialize(command, process_info, output)
    @command = command
    @exit_code = process_info.exitstatus
    @output = output.to_s
    @pid = process_info.pid
    @success = process_info.success?
  end

  def success?
    @success
  end

  def report
    lines = [
      ' ---- Command (sanitized when executing):',
      command.illustrate,
      ' ---- Execution details:',
      "PID #{pid}, exit status #{exit_code}",
      ' ---- Outputs (STDOUT and STDERR):',
      output
    ]

    lines.join("\n")
  end
end