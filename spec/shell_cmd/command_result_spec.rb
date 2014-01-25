require 'spec_helper'

describe CommandResult do
  # NOTE: Tests are OS-specific.
  #       These are written for linux (assuming coreutils)

  before :each do
    allow(result).to receive(:pid).with(no_args).and_return(1234)
  end

  let(:cmd) { ShellCmd.new('echo', '-e', '\n this!') }
  let(:result) { cmd.execute }


  subject { result }

  its(:command) { should be(cmd) }
  its(:exit_code) { should eq(0) }
  its(:output) { should eq("\n this!\n") }
  its(:pid) { should eq(1234) }
  its(:success?) { should eq(true) }


    @text = <<-END.gsub(/^ {6}/, '')
      "Faith" is a fine invention
      When Gentlemen can see
      But Microscopes are prudent
                 In an Emergency.
      (Emily Dickinson 1830-1886)
    END

  context 'when the command exists' do
    its(:report) do
      should eq(<<-END.gsub(/^ {8}/, '')
         ---- Command (sanitized when executing):
        echo '-e' '\\n this!'
         ---- Execution details:
        PID 1234, exit status 0
         ---- Outputs (STDOUT and STDERR):

         this!
        END
      )
    end
  end

  context 'when the command does not exist' do
    it 'also has a report' do
      cmd = ShellCmd.new('nonexistingcommand')
      begin
        cmd.execute
      rescue ShellCmdError => e
        expect(e.command.result.report).to eq(
          <<-END.gsub(/^ {10}/, '')
           ---- Command (sanitized when executing):
          nonexistingcommand 
           ---- Execution details:
          PID (none), exit status 127
           ---- Outputs (STDOUT and STDERR):
          (none)
          END
        )
      end
    end
  end
end