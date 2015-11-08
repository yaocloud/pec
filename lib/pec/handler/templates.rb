module Pec::Handler
  class Templates
    extend Pec::Core
    self.kind = 'templates'
    class << self
      def build(host)
        { user_data: load_template(host) }
      end

      def load_template(host)
        host.templates.inject({}) do |merge_template, template|
          template.to_s.concat('.yaml') unless template.to_s.match(/.*\.yaml/)
          Pec::Logger.notice "load template #{template}"

          raise "#{template} not fond!" unless FileTest.exist?("user_data/#{template}")
          merge_template.deep_merge!(YAML.load_file("user_data/#{template}").to_hash)
        end if host.templates
      end 
    end
  end
end
