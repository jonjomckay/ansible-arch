{ pkgs, ... }:

{
  enable = true;

  components = [ "pkcs11" "secrets" "ssh" ];
}
