module Pec::Handler
  class Templates
    extend Pec::Core
    self.kind = 'templates'
    class << self
      def build(config)
        { user_data: load_template(config) }
      end

      def load_template(config)
        config.templates.inject({}) do |merge_template, template|
          template.to_s.concat('.yaml') unless template.to_s.match(/.*\.yaml/)
          Pec::Logger.notice "load template #{template}"

          raise "#{template} not fond!" unless FileTest.exist?("user_data/#{template}")
          merge_template.deep_merge!(YAML.load_file("user_data/#{template}").to_hash)
        end if config.templates
      end
    end
  end
end
