class Miamtf::DSL::Context::Role
  def initialize(name, &block)
    @role_name = name
    @assume_role_policy_document = nil
    @max_session_duration = nil
    @attached_managed_policies = []
    @policies = {}
    @tags = {}
    instance_eval(&block)
  end

  def to_h
    inline_policy = @policies.map do |name, document|
      {
        name: name,
        policy: document.to_json,
      }
    end

    {
      name: @role_name,
      assume_role_policy: @assume_role_policy_document.to_json,
      inline_policy: inline_policy,
      managed_policy_arns: @attached_managed_policies,
      max_session_duration: @max_session_duration,
      tags: @tags,
    }
  end

  private
  def assume_role_policy_document
    @assume_role_policy_document = yield
  end

  def max_session_duration(duration)
    @max_session_duration = duration
  end

  def attached_managed_policies(*policies)
    @attached_managed_policies.concat(policies.map(&:to_s))
  end

  def policy(name)
    name = name.to_s

    @policies[name] = yield
  end

  def tags(tags)
    @tags = tags
  end
end
