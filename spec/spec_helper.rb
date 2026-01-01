LKP_SRC ||= ENV['LKP_SRC']

require 'rspec'
require "#{LKP_SRC}/lib/lkp_tmpdir"

$LOAD_PATH.delete_if { |p| File.expand_path(p) == File.expand_path('./lib') }

if ENV['GENERATE_COVERAGE'] == 'true'
  require 'simplecov'
  require 'simplecov-rcov'
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

Dir[File.join(LKP_SRC, 'lib', 'spec', 'support', '**', '*.rb')].sort.each { |f| require f }
