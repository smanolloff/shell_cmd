require 'spec_helper'
require 'tmpdir'

describe ErrorFile do
  before :each do
    allow(Time).to receive(:now).with(no_args).and_return(timesamp)
    @dir = Dir.mktmpdir('ERRORS-')
  end

  after :each do
    FileUtils.rm_rf(@dir)
  end

  let(:timesamp) { Time.now }
  let(:filename) { File.join(@dir, "error_#{timesamp.to_i}") }
  let(:error_file) { ErrorFile.new(@dir) }


  subject { error_file }

  its(:filename) { should eq(filename) }

  describe '.new' do
    it 'raises if the dir does not exist' do
      FileUtils.rmdir(@dir)
      expect { error_file }.
        to raise_error(ArgumentError, "Directory does not exist: #{@dir}")
    end

    it 'generates a new file' do
      expect { error_file }.to change { File.file?(filename) }.
        from(false).to(true)
    end

    it 'does not overwrite existing files' do
      FileUtils.touch(filename)
      expected_file = File.join(@dir, "error_#{timesamp.to_i}-0")

      expect { error_file }.
        to change { File.file?(expected_file) }.from(false).to(true)
    end
  end

  describe '#write' do
    before do
      # Just initialize (empty file)
      error_file
    end

    it 'writes the given string to the file' do
      expect { error_file.write('some content') }.
        to change { File.read(filename) }.from('').to('some content')
    end

    it 'keeps previous writes' do
      error_file.write('previous content.')

      expect { error_file.write('next content.') }.
        to change { File.read(filename) }.to('previous content.next content.')
    end
  end

  describe '#delete' do
    before do
      # Just initialize (empty file)
      error_file
    end

    it 'deletes the file' do
      expect { error_file.delete }.
        to change { File.file?(filename) }.from(true).to(false)
    end
  end
end
