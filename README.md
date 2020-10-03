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

## Afterwards

* Register fingerprints with `fprintd`:

    ```
    $ fprintd-enroll
    ```

* Configure media session and MPRIS in Firefox:

    ```
    dom.media.mediasession.enabled = true
    media.mediasource.enabled = true
    ```
