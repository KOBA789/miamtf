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
