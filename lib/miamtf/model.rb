module Miamtf::Model
  Root = Struct.new(
    :roles, # map<string(role name), role: Role>
    :managed_policies, # map<string(policy name), ManagedPolicy>
    :instance_profiles, # map<string(profile name), InstanceProfile>

    keyword_init: true
  ) do
    def to_h
      {
        roles: roles.transform_values(&:to_h),
        managed_policies: managed_policies.transform_values(&:to_h),
        instance_profiles: instance_profiles.transform_values(&:to_h),
      }
    end
  end
  Role = Struct.new(
    # required
    :assume_role_policy, # object(policy document to be converted to JSON)
    # optional
    :description, # string
    :force_detach_policies, # boolean
    :max_session_duration, # integer
    :path, # string
    :permissions_boundary, # string(ARN)
    :tags, # map<string(name), string(value)>
    # virtual
    :inline_policies, # map<string(policy name), object(policy document to be converted to JSON)>
    :managed_policy_arns, # list<string(ARN)>

    keyword_init: true
  )
  ManagedPolicy = Struct.new(
    # required
    :policy_document, # object(policy document to be converted to JSON)
    # optional
    :description, # string
    :path, # string
    :tags, # map<string(name), string(value)>

    keyword_init: true
  )
  InstanceProfile = Struct.new(
    # optional
    :path, # string
    :tags, # map<string(name), string(value)>

    keyword_init: true
  )
end
