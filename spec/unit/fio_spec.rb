require 'spec_helper'

describe 'fio' do
  Dir[LKP::Path.src('jobs', 'fio-*.yaml')].each do |job_yaml|
    it "has sorted ioengine list in #{File.basename(job_yaml)}" do
      load_values_from_job_yamls(File.basename(job_yaml, '.yaml'), include_comment: true) do |document|
        next unless document.is_a?(Hash)

        setup_key = document.keys.find { |k| k.to_s.start_with?('fio') && document[k].is_a?(Hash) }
        next unless setup_key

        ioengine = document[setup_key]['ioengine']
        next unless ioengine.is_a?(Array)

        expect(ioengine).to be_sorted
      end
    end

    it "has sorted fs list in #{File.basename(job_yaml)}" do
      load_values_from_job_yamls(File.basename(job_yaml, '.yaml'), include_comment: false) do |document|
        next unless document.is_a?(Hash)

        fs = document['fs']
        fs = fs['fs'] if fs.is_a?(Hash)
        next unless fs.is_a?(Array)

        expect(fs).to be_sorted
      end
    end
  end
end
