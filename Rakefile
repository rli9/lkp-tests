require 'rubygems'
require 'bundler/setup'
require 'rake/file_utils'
require 'rspec/core/rake_task'
require 'fileutils'
require 'rubocop/rake_task'
require 'English'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

def tool_available?(cmd)
  system("which #{cmd} >/dev/null 2>&1")
end

desc 'Show help'
task :help do
  puts <<~EOF
## SPEC

usage
  rake spec [spec=result_path]

example
  rake spec                       # check all unit tests status
  rake spec spec=job              # check spec/job_spec.rb status

## RUBOCOP

usage
  rake rubocop [file=pattern]

example
  rake rubocop file="lib/**/*.rb" # check all lib files
  EOF
end

RSpec::Core::RakeTask.new do |t|
  ENV['LKP_SRC'] ||= File.expand_path File.dirname(__FILE__).to_s

  puts "PWD = #{Dir.pwd}"
  puts "ENV['LKP_SRC'] = #{ENV.fetch('LKP_SRC', nil)}"

  spec = ENV['spec'] || '*'
  spec = spec.sub(/_spec$/, '')
  t.pattern = "spec/**{,/*/**}/#{spec}_spec.rb"
  t.rspec_opts = "--example '#{ENV['example']}'" if ENV['example']
end

if ENV['GENERATE_REPORTS'] == 'true'
  require 'ci/reporter/rake/rspec'
  task spec: 'ci:setup:rspec'
end

RuboCop::RakeTask.new(:rubocop) do |t|
  ruby_version = `ruby --version | grep -oE "[0-9]+\\.[0-9]+"`.chomp

  rubocop_config_file = ".rubocop.#{ruby_version}.yml"
  rubocop_config_file = '.rubocop.yml' unless File.size?(rubocop_config_file)

  t.options = ['-D', "-c#{rubocop_config_file}"]
  t.options.unshift('-a') if ENV['fix'] == '1'
  t.patterns = [ENV['file']] if ENV['file']

  puts "PWD = #{Dir.pwd}"
  puts "rubocop.patterns = #{t.patterns}"
  puts "rubocop.options = #{t.options}"
end

desc 'Run syntax check'
task :syntax do
  executables = `find -type f -executable ! -path "./.git*" ! -path "./vendor*" ! -size +100k`.split("\n").join(' ')

  sh "grep -s -l '^#!/.*ruby$' #{executables} | xargs -P$(nproc) -n1 ruby -c >/dev/null", verbose: false do |ok, res|
    exit res.exitstatus unless ok
  end

  sh "grep -s -l '^#!/.*bash$' #{executables} | xargs -P$(nproc) -n1 bash -n", verbose: false do |ok, res|
    exit res.exitstatus unless ok
  end

  sh "grep -s -l '^#!/bin/sh$' #{executables} | xargs -P$(nproc) -n1 dash -n", verbose: false do |ok, res|
    exit res.exitstatus unless ok
  end

  puts 'syntax OK'
end

desc 'Run shfmt'
task :shfmt do
  unless tool_available?('shfmt')
    puts 'shfmt not installed, skipping'.yellow
    next
  end

  executables = if ENV['file']
                  ENV['file']
                else
                  dir = ENV['dir'] || '.'
                  `find #{dir} -type f -executable ! -path "./.git*" ! -path "./vendor*" ! -path "*/sbin/makepkg" ! -path "*/sbin/pacman-LKP" ! -size +100k | xargs -P$(nproc) grep -s -l -e '^#!/.*bash$' -e '^#!/bin/sh$'`.split("\n").join(' ')
                end

  sh "shfmt -w -ln bash -i 0 -fn #{executables}", verbose: false do |ok, res|
    if ok
      puts 'shfmt OK'.green
    else
      exit res.exitstatus
    end
  end
end

desc 'Run shellcode (shellcheck and shfmt)'
task shellcode: %i[shellcheck shfmt]

desc 'Run shellcheck'
task :shellcheck do
  unless tool_available?('shellcheck')
    puts 'shellcheck not installed, skipping'.yellow
    next
  end

  executables = ENV['file'] || `find -type f -executable ! -path "./.git*"  ! -path "./vendor*" ! -size +100k | xargs -P$(nproc) grep -s -l -e '^#!/.*bash$' -e '^#!/bin/sh$'`.split("\n").join(' ')

  format = ENV['format'] || 'tty'

  base_cmd = "shellcheck -S warning -f #{format}"
  base_cmd += " -i #{ENV['code']}" if ENV['code']

  sh "#{base_cmd} #{executables}", verbose: false do |ok, res|
    if ok
      puts 'shellcheck OK'
    else
      exit res.exitstatus
    end
  end
end

desc 'Run yamllint'
task :yamllint do
  unless tool_available?('yamllint')
    puts 'yamllint not installed, skipping'.yellow
    next
  end

  sh 'yamllint', '--strict', '--format=auto', '.', verbose: false do |ok, res|
    if ok
      puts 'yamllint OK'.green
    else
      exit res.exitstatus
    end
  end
end

desc 'Run code check'
task code: %i[syntax yamllint shellcode rubocop]

namespace :docker do
  desc 'Build docker image'
  task :build do
    # image is in the form of debian/buster
    raise "ENV['image'] can't be #{ENV['image'].inspect}" unless ENV['image']

    sh "docker build . -f docker/#{ENV['image'].split('/').first}/Dockerfile -t lkp-tests/#{ENV.fetch('image', nil)} --build-arg base_image=#{ENV['image'].sub('/', ':')}"
  end
end
