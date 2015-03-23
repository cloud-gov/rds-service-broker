module RdsServiceBroker
  module OrgOptions
    DATA = YAML.load_file('config/orgs.yml')
    DATA.each do |plan, opts|
      opts.symbolize_keys!
    end

    def by_name(name)
      DATA[name] || raise("unknown organization #{name.inspect}")
    end
    module_function :by_name
  end
end
