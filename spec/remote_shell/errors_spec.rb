require 'spec_helper'

describe RemoteShell::CmdSetError do
  before :each do
    if File.directory?(errors_dir)
      FileUtils.rm Dir.glob(File.join(errors_dir, '*'))
    else
      FileUtils.mkdir(errors_dir)
    end
  end

  let(:errors_dir) { File.expand_path('../test_data', __FILE__) }
  let(:error_file) { Dir.glob(File.join(errors_dir, '*')).first }
  let(:error_report) { File.read(error_file) }
  let(:ssh) { { user: 'simo', pass: '123456', fqdn: 'localhost' } }
  let(:cmd_set) do
    RemoteShell::CmdSet.new(ssh[:fqdn], ssh[:user], ssh[:pass]).
                            add_command(ShellCmd.new('echo', '-e', '\n this!')).
                            add_command(ShellCmd.new('nonexistingcommand'))
  end
  let(:error) do
    begin
      cmd_set.execute_all
    rescue RemoteShell::CmdSetError => error
      error
    end
  end

  subject { error }

  its(:message) { should eq("Remote execution failed") }
  its(:cmd_set) { should be(cmd_set) }

  describe '#report_to_file' do
    before :each do
      result = double("result", :report => "the report", :add => nil)
      allow(cmd_set).to receive(:result).and_return(result)
      error.report_to_file(errors_dir)
    end

    it 'creates an error file with the right content' do
      expect(error_report).to eq("the report")
    end
  end
end
