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

    # The inline_policy and managed_policy_arns have been deprecated
    # Instead, we use aws_iam_role_policy_attachments_exclusive and aws_iam_role_policy
    {
      name: @role_name,
      assume_role_policy: @assume_role_policy_document.to_json,
      max_session_duration: @max_session_duration,
      tags: @tags,
    }
  end

  def name
    @role_name
  end

  def role_policy_attachment_resources
    @attached_managed_policies.each_with_object({}) do |policy_arn, acc|
      policy_name = policy_arn.sub("arn:aws:iam::aws:policy/", '').tr("/", "_") 
      resource_name = "#{@role_name}_#{policy_name}"
      acc[resource_name] = {
        role: "aws_iam_role.#{@role_name}.name",
        policy_arn: policy_arn,
      }
    end
  end

  def attached_managed_policy_arns
    @attached_managed_policies
  end

  def role_policy_resources
    @policies.each_with_object({}) do |(policy_name, document), acc|
      resource_name = "#{@role_name}_#{policy_name}"
      acc[resource_name] = {
        role: "aws_iam_role.#{@role_name}.name",
        name: policy_name,
        policy: document.to_json,
      }
    end
  end

  def inline_policy_names
    @policies.map do |name, _| name end
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
