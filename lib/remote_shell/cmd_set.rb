class RemoteShell::CmdSet < Array
  attr_reader :fqdn, :user, :password, :result

  def initialize(fqdn, user, password = nil)
    @fqdn = fqdn
    @user = user
    @password = password
  end

  def add_command(command)
    unless command.is_a?(ShellCmd)
      fail ArgumentError, 'Expected a ShellCmd instance'
    end

    push(command)
    self
  end

  def execute_all(fail_fast = true)
    @result = RemoteShell::CmdSetResult.new(self)
    failed = false
    Net::SSH.start(fqdn, user, password: password) do |ssh|
      self.each do |cmd|
        cmd_string = Shellwords.escape(cmd.command) + ' '
        cmd_string += cmd.arguments.map { |a| Shellwords.escape(a) }.join(' ')

        if failed && fail_fast
          output = ''
          exit_code = 'N/A'
        else
          output, exit_code = ssh_exec!(ssh, cmd_string)
          failed = true unless exit_code == 0
        end

        result.add(cmd, output, exit_code)
      end
    end

    fail RemoteShell::CmdSetError.new(self) if failed
    result
  end


  private
  def ssh_exec!(ssh, command)
    output = ""
    exit_code = nil
    exit_signal = nil
    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        unless success
          # FIXME: handle this (after finding out what exactly happends)
          abort "FAILED: couldn't execute command (ssh.channel.exec)"
        end

        channel.on_data { |ch,data| output.concat(data) }
        channel.on_extended_data { |ch,type,data| output.concat(data) }

        channel.on_request("exit-status") do |ch,data|
          exit_code = data.read_long
        end

        channel.on_request("exit-signal") do |ch, data|
          exit_signal = data.read_long
        end
      end
    end
    ssh.loop
    [output, exit_code]
  end
end
