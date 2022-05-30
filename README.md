# miamtf

Miam syntax for Terraform

## CAUTION

This is a currently released as a PoC and is **NOT** tested enough.

## Usage

```console
$ cat IAMfile
role "AwesomeRole" do
  policy "allow-something" do
    {
      Version: "2012-10-17",
      Statement: [
        # allow something
      ]
    }
  end
end
$ miamtf > iam.tf.json
```

## Acknowledgement

miamtf is highly inspired by [miam](https://github.com/codenize-tools/miam).

## TODO

- [ ] Tests
- [ ] Documents
- Resources
  - [x] Role
  - [x] Managed Policy
  - [x] Instance Profile
  - [ ] User
  - [ ] Group

## Contribution

日本語で OK
