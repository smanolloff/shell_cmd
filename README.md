# ShellCmd

Yet another gem for executing shell commands

## Installation

Add this line to your application's Gemfile:

    gem 'shell_cmd'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shell_cmd

## Usage

Execute commands:

    require 'shell_cmd'

    cmd = ShellCmd.new('uname', '-m')
    result = cmd.execute

    result.output
    # => "x86_64\n"
    result.exit_code
    # => 0

    cmd.add_arguments('-r', '--kernel-version').execute.output
    # => "2.6.32-431.el6.x86_64 #1 SMP Fri Nov 22 03:15:09 UTC 2013 x86_64\n"

    cmd.illustrate
    # => "uname '-m' '-r' '--kernel-version'"

Write reports:
  
    bad_cmd = ShellCmd.new('cat', '/non/existing/file')

    begin
      bad_cmd.execute
    rescue ShellCmdError => error
      errors_dir = '/tmp'
      error.report_to_file(errors_dir)
    end
    # => /tmp/error_1394961663



## Contributing

1. Fork it ( http://github.com/<my-github-username>/shell_cmd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
