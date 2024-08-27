# Nix Config


> [!NOTE]
> Given the considerable time and energy required to use Nixos as a daily system, 
> I am unable to recommend it to anyone, at least until such time as one is prepared to forego the configuration of one's system in favour of undertaking productive activities. 
> However, I am aware that my opinion may be flawed. 
> NixOS can be of immense value to most users, 
> regardless of whether it is used as a development environment (e.g., Nix-Shell) and shared within a Git repository or if it is employed for setting up VMs or servers using NixOS or the Nix Home Manager. 
> 
> However, it is not a suitable daily system for me.


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

