require 'spec_helper'

describe ShellCmdError do
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
  let(:cmd) { double('cmd', :command => 'command') }
  let(:error) { ShellCmdError.new(cmd) }


  subject { error }

  its(:message) { should eq('Command failed') }
  its(:command) { should be(cmd) }

  describe '#report_to_file' do
    before :each do
      result = double('result', :report => 'the report')
      allow(cmd).to receive(:result).and_return(result)
      error.report_to_file(errors_dir)
    end

    it 'creates an error file with the correct content' do
      expect(error_report).to eq('the report')
    end
  end
end