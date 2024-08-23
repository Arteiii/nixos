# Nix Config

1. Clone
2. `cd workdir`
3. `sudo nixos-rebuild switch --flake .`

## Clear:

```shell
nix-collect-garbage  --delete-old
# or
sudo nix-collect-garbage -d
```

```shell
sudo nixos-rebuild boot
```
