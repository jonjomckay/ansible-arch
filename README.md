Arch Setup
==========

## Usage

```
git submodule update --init
make laptop
```

### Vault

To encrypt new vault content, use this command:

```
echo "secret-content" | .venv/bin/ansible-vault encrypt_string --ask-vault-password --name=variable_name
```