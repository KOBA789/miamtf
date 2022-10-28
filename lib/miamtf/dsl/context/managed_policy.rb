class Miamtf::DSL::Context::ManagedPolicy
  def initialize(name, &block)
    @policy_name = name
    @policy = instance_eval(&block)
  end

  def to_h
    {
      name: @policy_name,
      policy: @policy.to_json,
    }
  end
end
