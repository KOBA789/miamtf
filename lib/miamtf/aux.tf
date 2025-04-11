# This file is to be converted into JSON with hcl2json
# hcl2json: https://github.com/tmccombs/hcl2json

resource "aws_iam_role" "miamtf" {
  for_each = local.miamtf.roles

  # implicit
  name = each.key

  # required
  assume_role_policy = jsonencode(each.value.assume_role_policy)

  # optional
  description           = each.value.description
  force_detach_policies = each.value.force_detach_policies
  max_session_duration  = each.value.max_session_duration
  path                  = each.value.path
  permissions_boundary  = each.value.permissions_boundary
  tags                  = each.value.tags
}

resource "aws_iam_role_policy" "miamtf" {
  for_each = {
    for v in flatten([
      for role_name, role in local.miamtf.roles : [
        for policy_name, policy_document in role.inline_policies : {
          role_name       = role_name
          policy_name     = policy_name
          policy_document = policy_document
        }
      ]
    ]) : "${v.role_name}|${v.policy_name}" => v
  }

  # implicit
  name = each.value.policy_name
  role = each.value.role_name

  # required
  policy = jsonencode(each.value.policy_document)
}

resource "aws_iam_role_policies_exclusive" "miamtf" {
  for_each = local.miamtf.roles

  # implicit
  role_name = each.key

  # required
  policy_names = keys(each.value.inline_policies)
}

resource "aws_iam_role_policy_attachment" "miamtf" {
  for_each = {
    for v in flatten([
      for role_name, role in local.miamtf.roles : [
        for policy_arn in role.managed_policy_arns : {
          role_name  = role_name
          policy_arn = policy_arn
        }
      ]
    ]) : "${v.role_name}|${v.policy_arn}" => v
  }

  # implicit
  role = each.value.role_name

  # required
  policy_arn = each.value.policy_arn
}

resource "aws_iam_role_policy_attachments_exclusive" "miamtf" {
  for_each = local.miamtf.roles

  # implicit
  role_name = each.key

  # required
  policy_arns = each.value.managed_policy_arns
}

resource "aws_iam_policy" "miamtf" {
  for_each = local.miamtf.managed_policies

  # implicit
  name = each.key

  # required
  policy = jsonencode(each.value.policy_document)

  # optional
  description = each.value.description
  path        = each.value.path
  tags        = each.value.tags
}

resource "aws_iam_instance_profile" "miamtf" {
  for_each = local.miamtf.instance_profiles

  # implicit
  name = each.key
  role = each.key

  # optional
  path = each.value.path
  tags = each.value.tags
}
