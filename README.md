# Nix Config

> [!NOTE]
>
> to use displaylink run first:
>
> ```shell
> nix-prefetch-url --name displaylink-620.zip https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip
> ```
>
> fuck that but there isnt an alternative at all...

clone with submodule:

```shell
git clone --recurse-submodules --shallow-submodules https://github.com/arteiii/nixos.git
```

```shell
# overwrite the default nixos folder
sudo rm -rf /etc/nixos
sudo mkdir -p /etc/nixos

# bind your repository dir. to the system root for example:
sudo mount --bind /home/arteii/nixos-config /etc/nixos
```

```shell
sudo nixos-rebuild boot --flake github:arteiii/nixos#wsl --refresh
```

update lock

```shell
nix flake update
```

## Deploy remote

```shell
users.users.media-manager.group = "media-manager";
```

## Operational Workflow

When updating or altering this configuration, always use safety protocols to protect your working system state:

1. **Test changes without writing to bootloader:**

```bash
sudo nixos-rebuild test --flake .#blade
```

NOTE: might not work because of security setting use `nixos-rebuild boot` instead

2. **Safely test a full reboot cycle (Recommended):**

```bash
sudo nixos-rebuild boot --flake .#blade
```

_If the system crashes or fails to mount devices, physically reboot the machine, open the **NixOS Generations** menu at startup, and boot cleanly into your previous working state._

3. **Commit changes permanently:**

```bash
sudo nixos-rebuild switch --flake .#blade
```

## Clear

```shell
nix-collect-garbage  --delete-old
# or
sudo nix-collect-garbage -d
```

```shell
sudo nixos-rebuild boot
```

build rbpi image:

```shell
nix build .#nixosConfigurations.argon-one.config.system.build.sdImage
```

write to sd:

```shell
zstdcat ./result/sd-image/*.img.zst | sudo dd of=/dev/sdb bs=4MiB oflag=direct status=progress conv=fsync && sudo eject /dev/sdb
```

## Custom kernel notes:

### submodules

as i tend to forget those:

update:

1. Pull the absolute newest commits from the upstream Zen repository

```shell
git submodule update --remote --merge kernels/zen/latest-stable
```

2. Rebuild your system with the updated source code

```shell
sudo nixos-rebuild boot --flake .#blade
```

## Mail

### Proton Bridge

```shell
# stop process first
killall protonmail-bridge

# restart with cli
protonmail-bridge --cli

# inside run:
>>> login

# wait for sync and run:
>>> info

# from there copy the password and set it in secret tool:
secret-tool store --label="Proton Bridge" service protonmail-bridge account local-pass
```

### NeoMutt

you might need to create the dir for the specific mailbox in my case proton:

```shell
mkdir -p ~/Maildir/proton/Inbox/{cur,new,tmp}
```
