# Compatibility shim: require this file instead of active_support/time directly.
#
# activesupport-7.2 has two top-level requirements that fail on Ruby 3.3+:
#   - time_with_zone.rb calls YAML.load_tags  (psych no longer auto-required)
#   - conversions.rb does alias_method :rfc3339, :xmlschema  (xmlschema removed)
require 'time'
require 'psych'
require 'yaml'
YAML = Psych unless defined?(YAML) # guard against partial yaml load leaving YAML undefined

class Time
  unless method_defined?(:xmlschema)
    if method_defined?(:iso8601)
      alias xmlschema iso8601
    else
      # Ruby 3.3+ with time gem >= 0.4.0: provide a minimal stand-in until
      # active_support/time loads and re-opens Time with the full implementation.
      def xmlschema(fraction_digits = 0)
        s = strftime('%Y-%m-%dT%H:%M:%S')
        s += format('.%0*d', fraction_digits, (usec.to_r / (10**(6 - fraction_digits))).round) if fraction_digits.positive?
        s + (utc? ? 'Z' : strftime('%:z'))
      end
    end
  end
end

require 'active_support/time'
