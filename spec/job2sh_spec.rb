require 'spec_helper'
require "#{LKP_SRC}/lib/job2sh"

describe Job2sh do
  describe '#to_shell' do
    artifacts_dir = File.join(LKP_SRC, 'spec', 'job2sh')

    yaml_files = Dir.glob File.join(artifacts_dir, '*.yaml')

    yaml_files.each do |yaml_file|
      it "convert #{yaml_file}" do
        job2sh = described_class.new
        job2sh.load(yaml_file)
        job2sh.expand_params

        # The expected sh is generated by sbin/job2sh, which use "puts job2sh.to_shell".
        # The output can be different than join("\n") regarding the empty line. Thus
        # we need slightly change expected sh to add extra empty line and remove final
        # new line.
        actual = job2sh.to_shell
                       .join("\n")

        expect(actual).to eq File.read(yaml_file.sub(/\.yaml$/, '.sh'))
      end
    end
  end
end
