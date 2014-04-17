require 'spec_helper'

describe ShellEnvironment do
  subject(:env) { ShellEnvironment.new('lemon' => 'yellow', 'tomato' => 'red') }

  its(:class) { should be < Hash }

  describe '.new' do
    it 'also accepts a list of variables' do
      expect { env }.not_to raise_error
    end
  end

  it 'can be compared to a hash' do
    expect(env).to eq({ 'lemon' => 'yellow', 'tomato' => 'red' })
  end

  describe '#get' do
    it 'expects an argument' do
      expect { env.get }.to raise_error(ArgumentError)
    end

    it 'returns the value' do
      expect(env.get('lemon')).to eq('yellow')
    end
  end

  describe '#set' do
    it 'expects an argument' do
      expect { env.set }.to raise_error(ArgumentError)
    end

    it 'sets the environment variable(s)' do
      expect { env.set('cherry' => 'red', 'kiwi' => 'green') }.
        to change { env.count }.from(2).to(4)
    end

    it 'converts the arguments to to strings' do
      env.set(cherry: :red)
      expect(env.get('cherry')).to eq('red')
    end

    it 'returns the environment' do
      expect(env.set('cherry' => 'red')).to be_an_instance_of(ShellEnvironment)
    end
  end

  describe '#unset' do
    it 'unsets the given environment variables' do
      expect { env.unset('lemon', 'tomato') }.
        to change { env.count }.from(2).to(0)
    end

    it 'converts the names to symbols' do
      expect { env.unset('lemon') }.
        to change { env.count }.from(2).to(1)
    end

    it 'returns the environment' do
      expect(env.unset('lemon')).to be_an_instance_of(ShellEnvironment)
    end

    it 'does not complain if the variable is not found' do
      expect { env.unset('chips') }.not_to raise_error
    end
  end
end
