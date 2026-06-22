{
  pkgs,
  config,
  lib,
  ...
}:

{
  environment.systemPackages = [
    (
      let
        packages = with pkgs; [
          firefox
        ];
      in
      pkgs.runCommand "firejail-icons"
        {
          preferLocalBuild = true;
          allowSubstitutes = false;
          meta.priority = -1;
        }
        ''
          mkdir -p "$out/share/icons"
          ${lib.concatLines (
            map (pkg: ''
              tar -C "${pkg}" -c share/icons -h --mode 0755 -f - | tar -C "$out" -xf -
            '') packages
          )}
          find "$out/" -type f -print0 | xargs -0 chmod 0444
          find "$out/" -type d -print0 | xargs -0 chmod 0555
        ''
    )
  ];

  systemd.tmpfiles.rules = [
    "z /etc/apparmor.d 0755 root root -"
  ];

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      librewolf = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        extraArgs = [
          "--netns=protonvpn"
          "--dns=9.9.9.9"

          "--private-tmp"
          "--private-dev"
          "--private-bin=firefox"
          "--profile-name=privacy"
          "--whitelist=${config.home.homeDirectory}/.mozilla/firefox/*.privacy"
          "--whitelist=${config.home.homeDirectory}/Downloads"

          "--caps.drop=all"
          "--nonewprivs"
          "--noroot"
          "--no-remote"
          "--seccomp"
          "--nogroups"
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };
    };
  };
}
