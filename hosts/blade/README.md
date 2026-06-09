# Blade System Configuration Guide (`~/nixos-config`)

This repository contains the complete NixOS system configuration for **Blade**, configured as a high-performance, low-latency, secure dual-boot system alongside Windows.

## Dual-Boot (DO NOT TOUCH)

Because Blade shares physical hardware and storage controllers with Windows, certain settings are strictly managed to prevent total data loss or filesystem corruption.

### 1. No Hibernation / No Resume Device

* **Status:** **Disabled**
* **Why:** Hibernating Linux and booting into Windows (or vice versa) leaves shared filesystems in an uncommitted, "frozen" state. If the other OS writes to the disk, it causes catastrophic filesystem corruption upon wake.
* **Action:** Never re-enable `boot.resumeDevice` or systemd hibernation targets.
* **Windows Requirement:** **Fast Startup MUST remain disabled in Windows Control Panel.** If left enabled, Windows locks the shared NTFS data drive on shutdown, causing NixOS boot failures.

### 2. Manual Drive Layout (No LVM)

* **Status:** Plain LUKS on raw partitions with Btrfs subvolumes (`@` and `@home`).
* **Why:** Blade does **not** use an LVM (Logical Volume Manager) layer. The hardware configuration relies directly on physical partition UUIDs mapping to plain dm-crypt containers.
* **Action:** Do not add `preLVM = true` or LVM kernel modules. It will break the initrd boot sequence.

---

## Performance & Security Optimizations

### Memory & Swap Tuning

* **Zram Swap (`configuration.nix`):** Enabled as a virtual, compressed RAM disk.
* **Physical Swap (`hardware-configuration.nix`):** Set to `priority = 0`. This guarantees that Linux always prioritizes the lightning-fast Zram disk first. Your physical NVMe swap partition is treated strictly as a secondary fallback, significantly extending your SSD's lifespan.

### Storage Optimizations (`hardware-configuration.nix`)

* **`allowDiscards = true;`**: Permits standard TRIM operations to pass directly through the LUKS encryption layer down to the bare NVMe cells, preventing write-speed degradation over time.
* **`bypassWorkqueues = true;`**: Forces cryptographic requests to bypass standard kernel queues, submitting I/O requests straight to the NVMe driver for a massive drop in latency.
* **`compress=zstd` & `noatime**`: Applied to all Btrfs subvolumes to transparently compress data on-the-fly (saving space/increasing read speeds) and stop unnecessary file write-timestamp wear.

### System Resiliency (`configuration.nix`)

* **Hardened Kernel (`pkgs.linuxPackages_hardened`):** Enforces strict security configurations and exploit mitigations at the kernel level.
* *Note:* If third-party modules (like specific Wi-Fi drivers or gaming anti-cheats) fail to compile, this can be safely reverted to `_zen` or `_latest`.

---

##  Operational Workflow

When updating or altering this configuration, always use safety protocols to protect your working system state:

1. **Test changes without writing to bootloader:**
```bash
sudo nixos-rebuild test
```


2. **Safely test a full reboot cycle (Recommended):**
```bash
sudo nixos-rebuild boot
```


*If the system crashes or fails to mount devices, physically reboot the machine, open the **NixOS Generations** menu at startup, and boot cleanly into your previous working state.*
3. **Commit changes permanently:**

```bash
   sudo nixos-rebuild switch
```
