require 'spec_helper'
require "#{LKP_SRC}/lib/spec/test_helper"

TEST_CASE = 'stress-ng'.freeze

describe TEST_CASE do
  Dir[LKP::Path.src('jobs', "#{TEST_CASE}*.yaml")].each do |job_yaml|
    it "has sorted test names in #{job_yaml}" do
      load_values_from_job_yamls(File.basename(job_yaml, '.yaml'), include_comment: false) do |document|
        expect(document[TEST_CASE]['test']).to be_sorted
      end
    end
  end
end
