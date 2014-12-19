require 'spec_helper'

describe CommandResult do
  # NOTE: Tests are OS-specific.
  #       These are written for linux (assuming coreutils)

  before :each do
    allow(result).to receive(:pid).with(no_args).and_return(1234)
  end

  let(:cmd) { ShellCmd.new('echo', '-e', '\n this!') }
  let(:environment) { {'BABA' => 'pena', 'DEDO' => 'spas'} }
  let(:result) { cmd.execute }


  subject { result }

  its(:command) { should be(cmd) }
  its(:exit_code) { should eq(0) }
  its(:output) { should eq("\n this!\n") }
  its(:pid) { should eq(1234) }
  its(:success?) { should eq(true) }

  context 'when the command exists' do
    before(:each) { cmd.environment.set(environment) }

    its(:report) do
      should eq(<<-END.gsub(/^\s+\|/, '')
        | ---- Command (sanitized when executing):
        |BABA=pena DEDO=spas echo -e \\\\n\\ this\\!
        | ---- Execution details:
        |PID 1234, exit status 0
        | ---- Outputs (STDOUT and STDERR):
        |
        | this!
        END
      )
    end
  end

  context 'when the command does not exist' do
    it 'also has a report' do
      cmd = ShellCmd.new('nonexistingcommand')
      cmd.environment.set(environment)

      begin
        cmd.execute
      rescue ShellCmdError => e
        expect(e.command.result.report).to eq(
          <<-END.gsub(/^\s+\|/, '')
          | ---- Command (sanitized when executing):
          |BABA=pena DEDO=spas nonexistingcommand
          | ---- Execution details:
          |PID (none), exit status 127
          | ---- Outputs (STDOUT and STDERR):
          |Command not found.
          END
        )
      end
    end
  end
end
