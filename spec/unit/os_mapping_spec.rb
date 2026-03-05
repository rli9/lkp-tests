require 'spec_helper'

LKP_SRC_PATH = "#{LKP_SRC}/distro/adaptation".freeze

def find_duplicated_lines(default_subdir, os_specific_subdir)
  default_mapping_lines = read_mappings(default_subdir)
  os_specific_mapping_lines = read_mappings(os_specific_subdir)

  default_mapping_lines & os_specific_mapping_lines
end

def read_mappings(file_path)
  File.readlines(file_path).map(&:strip).reject(&:empty?)
end

def generate_mappings(lkp_src)
  mappings = Hash.new { |h, k| h[k] = { default: nil, os_specific: [] } }

  # Iterate through each subdirectory in the lkp_src directory
  Dir.entries(lkp_src).each do |subdir|
    next if ['.', '..', 'README.md'].include?(subdir)

    subdir_path = File.join(lkp_src, subdir)
    next unless File.directory?(subdir_path)

    # Get a list of files in the subdirectory
    files = Dir.entries(subdir_path).select do |f|
      file_path = File.join(subdir_path, f)
      File.file?(file_path) && !File.symlink?(file_path)
    end

    # Populate the mappings hash with files from the subdirectory
    files.each do |file|
      base_name = subdir
      if file.include?('default')
        mappings[base_name][:default] = File.join(subdir_path, file)
      else
        mappings[base_name][:os_specific] << File.join(subdir_path, file)
      end
    end
  end

  mappings
end

describe 'package mapping uniqueness' do
  grouped_files = generate_mappings(LKP_SRC_PATH)

  grouped_files.each_value do |files|
    default_file = files[:default]
    os_specific_files = files[:os_specific]

    it "does not have duplicated lines between #{default_file} and any OS-specific files" do
      skip 'No default file found for this group.' if default_file.nil?
      skip "No OS-specific files to compare with default file: #{default_file}." if os_specific_files.nil? || os_specific_files.empty?

      os_specific_files.each do |os_specific_file|
        duplicated_lines = find_duplicated_lines(default_file, os_specific_file)
        expect(duplicated_lines).to be_empty, "Duplicated lines found between files:\nDefault: #{default_file}\nOS-specific: #{os_specific_file}\nDuplicated lines:\n#{duplicated_lines.join("\n")}"
      end
    end

    it 'does not have duplicated lines among all OS-specific files' do
      skip 'No OS-specific files to compare among themselves.' if os_specific_files.nil? || os_specific_files.empty? || os_specific_files.size < 2

      all_os_specific_lines = os_specific_files.map { |file| read_mappings(file) }
      duplicated_lines = all_os_specific_lines.reduce(&:&)
      expect(duplicated_lines).to be_empty, "Duplicated lines found among OS-specific files in folder #{File.dirname(os_specific_files.first)}:\nDuplicated lines:\n#{duplicated_lines.join("\n")}"
    end
  end
end
