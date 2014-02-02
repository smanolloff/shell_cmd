require 'spec_helper'

describe RemoteShell::CmdSet do
  let(:ssh) { { user: 'simo', pass: '123456', fqdn: 'localhost' } }
  let(:cmd) { ShellCmd.new('cat', '/etc/redhat-release') }
  let(:cmd_set) { RemoteShell::CmdSet.new(ssh[:fqdn], ssh[:user], ssh[:pass]) }

  subject { cmd_set }

  its(:class) { should be < Array }

  describe '#add_command' do
    it 'expects a ShellCmd object' do
      expect { cmd_set.add_command('bla') }.to raise_error(ArgumentError)
      expect { cmd_set.add_command(cmd) }.not_to raise_error
    end

    it 'returns the command set' do
      expect(cmd_set.add_command(cmd)).to be_an_instance_of(RemoteShell::CmdSet)
    end
  end

  describe '#execute_all' do
    it 'runs the commands' do
      file = File.expand_path('test_data/test_file', File.dirname(__FILE__))
      cmd_set = RemoteShell::CmdSet.new(ssh[:fqdn], ssh[:user], ssh[:pass])
      cmd_set.add_command(ShellCmd.new('touch', file))
      FileUtils.rm_f(file)

      expect { cmd_set.execute_all }.to change { File.exists?(file) }.to(true)
    end

    it 'raises unless all commands succeed' do
      cmd_set.add_command(ShellCmd.new('cat', '/non/existing/file'))
      expect { cmd_set.execute_all }.to raise_error(RemoteShell::CmdSetError)
    end

    it 'sets the result' do
      cmd_set.add_command(cmd)
      cmd_set.execute_all rescue raise cmd_set.result.report
      expect(cmd_set.result).to be_an_instance_of(RemoteShell::CmdSetResult)
    end

    it 'returns the result' do
      cmd_set.add_command(cmd)
      expect(cmd_set.execute_all).to be_an_instance_of(RemoteShell::CmdSetResult)
    end
  end
end
