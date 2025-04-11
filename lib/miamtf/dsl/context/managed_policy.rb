class Miamtf::DSL::Context::ManagedPolicy
  def initialize(&block)
    @policy = instance_eval(&block)
  end

  def to_h
    {
      policy_document: @policy,
    }
  end
end
