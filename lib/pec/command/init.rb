module Pec::Command
  class Init < Base
    def self.run
      Pec::Init.show_env_setting
      Pec::Init.create_template_dir
      Pec::Init.create_sample_config
    end
  end
end
