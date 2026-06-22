{ pkgs, lib, ... }:

{
  environment.systemPackages = [
    (
      let
        packages = with pkgs; [
          librewolf
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
        executable = "${pkgs.librewolf}/bin/librewolf";
        profile = "${pkgs.firejail}/etc/firejail/librewolf.profile";
        extraArgs = [
          "--netns=protonvpn"
          "--dns=9.9.9.9"

          "--private-tmp"
          "--private-dev"
          "--private-bin=librewolf"

          "--whitelist=\${HOME}/.librewolf"
          "--whitelist=\${HOME}/Downloads"
          "--tmpfs=\${HOME}/.cache/librewolf"

          "--caps.drop=all"
          "--nonewprivs"
          "--noroot"
          "--seccomp"
          "--nogroups"
          "--dbus-user.talk=org.freedesktop.Notifications"
        ];
      };
    };
  };
}
