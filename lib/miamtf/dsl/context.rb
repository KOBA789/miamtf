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
    aux_tf = JSON.load_file(
      File.join(File.dirname(__FILE__), '../aux.tf.json')
    )

    model = Miamtf::Model::Root.new(
      roles: @roles,
      managed_policies: @policies,
      instance_profiles: @instance_profiles,
    )
    locals = {
      miamtf: model.to_h
    }

    aux_tf.merge(locals: locals)
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

    role = Role.new(&block)
    @roles[name] = Miamtf::Model::Role::new(
      role_options.merge(role.to_h)
    )
  end

  def instance_profile(name, **instance_profile_options)
    name = name.to_s

    @instance_profiles[name] = Miamtf::Model::InstanceProfile.new(
      instance_profile_options
    )
  end

  def managed_policy(name, **policy_options, &block)
    name = name.to_s

    managed_policy = ManagedPolicy.new(&block)
    @policies[name] = Miamtf::Model::ManagedPolicy.new(
      policy_options.merge(managed_policy.to_h)
    )
  end
end
