class Miamtf::DSL::Context
  def self.eval(source, path)
    self.new(path) do
      eval(source, binding, path)
    end
  end

  def initialize(path, &block)
    @path = path
    @roles = {}
    @policies = {}
    @instance_profiles = {}
    @role_policy_attachments = {}
    @role_policy_attachments_exclusive = {}
    @role_inline_policies = {}
    @role_inline_policies_exclusive = {}

    instance_eval(&block)
  end

  def to_h
    resource = {}
    unless @roles.empty?
      resource[:aws_iam_role] = @roles
    end
    unless @policies.empty?
      resource[:aws_iam_policy] = @policies
    end
    unless @instance_profiles.empty?
      resource[:aws_iam_instance_profile] = @instance_profiles
    end
    unless @role_policy_attachments.empty?
      resource[:aws_iam_role_policy_attachment] = @role_policy_attachments
      resource[:aws_iam_role_policy_attachments_exclusive] = @role_policy_attachments_exclusive
    end
    unless @role_inline_policies.empty?
      resource[:aws_iam_role_policy] = @role_inline_policies
      resource[:aws_iam_role_policies_exclusive] = @role_inline_policies_exclusive
    end
      
    {
      resource: resource
    }
  end

  private

  def require(file)
    original_path = File.expand_path(file, File.dirname(@path))
    candidates = [
      original_path,
      original_path + ".rb",
    ]
    path = candidates.find {|path| File.exist?(path) }
    if path
      instance_eval(File.read(path), path)
    else
      Kernel.require(file)
    end
  end

  def role(name, **role_options, &block)
    name = name.to_s

    role = Role.new(name, &block)

    @roles[name] = role_options.merge(role.to_h)

    @role_policy_attachments.merge!(role.role_policy_attachment_resources)
    @role_policy_attachments_exclusive[name] = {
      role_name: "aws_iam_role.#{name}.name",
      policy_arns: role.attached_managed_policy_arns
        .map {|policy_arn| policy_arn.sub("arn:aws:iam::aws:policy/", '').tr("/", "_")}
        .map {|policy_name| "aws_iam_role_policy_attachment.#{name}_#{policy_name}.policy_arn"},
    }

    @role_inline_policies.merge!(role.role_policy_resources)
    @role_inline_policies_exclusive[name] = {
      role_name: "aws_iam_role.#{name}.name",
      policy_names: role.inline_policy_names.map {|policy_name| "aws_iam_role_policy.#{name}_#{policy_name}.name"},
    }
  end

  def instance_profile(name, **instance_profile_options)
    name = name.to_s

    @instance_profiles[name] = instance_profile_options
      .merge(name: name)
      .merge(instance_profile_options)
  end

  def managed_policy(name, **policy_options, &block)
    name = name.to_s

    managed_policy = ManagedPolicy.new(name, &block)
    @policies[name] = policy_options.merge(managed_policy.to_h)
  end
end
