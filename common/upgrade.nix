{ lib, config, ... }:

{
  # =========================================================================
  # AUTOMATED SYSTEM UPGRADES & NOTIFICATIONS
  # =========================================================================
  # Reference: github.com/arteiii/nixos

  # Background Auto-Upgrade Service
  # Ref: https://nixos.org/manual/nixos/stable/options#opt-system.autoUpgrade.enable
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    dates = "00:00";

    # Crucial Fix: Point this directly to your local configuration folder!
    # Disables old style channel logic and locks the update task directly to your Flake.
    # Ref: https://search.nixos.org/options?channel=25.11&query=system.autoUpgrade.flake#show=option%253Asystem.autoUpgrade.flake
    flake = "path:/etc/nixos#${config.networking.hostName}";

    flags = [
      "--commit-lock-file" # Automatically tracks version history in local Git
      "--show-trace"
    ];
    operation = "switch"; # automatically applies the update
    persistent = true;
  };

  # Terminal Notification
  # Ref: https://nixos.org/manual/nixos/stable/options#opt-environment.loginShellInit
  environment.loginShellInit = ''
    # only run if interacted session attached (prevents breaking SFTP/SCP)
    if [ -t 1 ]; then
      if [ "$(readlink /run/current-system)" != "$(readlink /nix/var/nix/profiles/system)" ]; then
        echo -e "\n\e[1;33m[!] SECURITY NOTICE:\e[0m Staged kernel upgrades are waiting on disk."
        echo -e "\e[1;30m\"It's just one story. The oldest. Light versus dark.\"\e[0m"
        echo -e "Looking up at the unpatched system sky, it looks like the dark has all the territory..."
        echo -ne "Press [\e[1;31mEnter\e[0m] to let the dark win, or type '\e[1;32mwinning\e[0m' to declare the light is winning and reboot: "
        
        # read full lie with 15 secs buffer
        read -t 15 choice
        echo ""

        if [[ "$choice" == "winning" || "$choice" == "WINNING" ]]; then
          echo -e "\e[1;32m[+]\e[0m \"Well, once there was only dark. You ask me, the light's winning.\""
          echo -e "Initializing reboot sequence now..."
          sudo reboot
        else
          echo -e "\e[1;30m[-] Postponed. \"Right now, the dark has all the territory.\"\e[0m\n"
        fi
      fi
    fi
  '';

}
