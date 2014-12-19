require 'spec_helper'

describe ShellCmd do
  before :each do
    ErrorFile.any_instance.stub(:write => 1)
    cmd.environment.set('BABA' => 'pena!', DEDO: 'spas?')
  end

  # NOTE: Tests are OS-specific.
  #       These are written for linux (assuming coreutils >= 8)
  let(:cmd) { ShellCmd.new('cat', '--dog', '= kaboom!') }


  subject { cmd }

  its(:command) { should eq('cat') }
  its(:arguments) { should eq(['--dog', '= kaboom!']) }

  describe '#add_argument' do
    it 'adds a given argument' do
      expect { cmd.add_argument('-f') }.to change { cmd.arguments.count }.by(1)
    end

    it 'returns the shell command' do
      expect(cmd.add_argument('-f')).to be_an_instance_of(ShellCmd)
    end
  end

  describe '#add_arguments' do
    it 'adds all given arguments' do
      expect { cmd.add_arguments('-f', '-s') }.to change { cmd.arguments.count }.by(2)
    end

    it 'returns the shell command' do
      expect(cmd.add_arguments('-f')).to be_an_instance_of(ShellCmd)
    end
  end

  describe '#illustrate' do
    it 'returns the command in a human-friendly form' do
      expect(cmd.illustrate).to eq('BABA=pena\! DEDO=spas\? cat --dog \=\ kaboom\!')
    end
  end

  describe '#environment' do
    it 'returns the shell environment' do
      expect(cmd.environment).to be_an_instance_of(ShellEnvironment)
    end
  end

  describe '#run' do
    pending 'is aliased to #execute'
  end

  describe '#execute' do
    let(:cmd) { ShellCmd.new('echo', 'cat', 'and dog') }

    it 'executes the command' do
      cmd = ShellCmd.new('echo', 'cat', 'and dog')
      expect(cmd.execute.output).to eq("cat and dog\n")
    end

    context 'when the command is not found' do
      it 'raises a ShellCmdError' do
        cmd = ShellCmd.new('unknowncommand')
        expect { cmd.execute }.to raise_error(ShellCmdError)
      end

      it 'includes a result in the error' do
        cmd = ShellCmd.new('unknowncommand')
        begin
          cmd.execute
        rescue ShellCmdError => e
          expect(e.command.result).to be_an_instance_of(CommandResult)
        end
      end
    end

    it 'raises if the command did not succeed' do
      cmd = ShellCmd.new('cat', '/non/existing/file')
      expect { cmd.execute }.to raise_error(ShellCmdError)
    end

    it 'sets the result' do
      cmd.execute rescue raise cmd.result.report
      expect(cmd.result).to be_an_instance_of(CommandResult)
    end

    it 'returns the result' do
      expect(cmd.execute).to be_an_instance_of(CommandResult)
    end

    it 'sets the environment before executing' do
      cmd = ShellCmd.new('bash')
      cmd.add_arguments('-c', 'exec echo $SOME_VAR')
      cmd.environment.set('SOME_VAR' => 'SOME_VAL')
      expect(cmd.execute.output).to eq("SOME_VAL\n")
    end
  end
end
