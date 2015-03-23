module RdsServiceBroker
  module PlanOptions
    DATA = YAML.load_file('plans.yml')
    DATA.each do |plan, opts|
      opts.symbolize_keys!
    end

    def by_size(size)
      DATA[size] || raise("unknown plan size #{size.inspect}")
    end
    module_function :by_size
  end
end
