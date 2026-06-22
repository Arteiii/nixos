# https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7
{ pkgs, ... }:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  home.file.".local/share/applications/firefox-privacy.desktop".text = ''
    [Desktop Entry]
    Name=Firefox Hardened (VPN Sandbox)
    Exec=firefox -P privacy %u
    Icon=firefox
    Terminal=false
    Type=Application
    Categories=Network;WebBrowser;
  '';

  programs = {
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisableTelemetry = true;
          # add policies here...

          # ---- PREFERENCES ----
          # Set preferences shared by all profiles.
          Preferences = {
            "browser.contentblocking.category" = {
              Value = "strict";
              Status = "locked";
            };
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            # add global preferences here...
          };
        };
      };

      # ---- PROFILES ----
      # Switch profiles via about:profiles page.
      # For options that are available in Home-Manager see
      # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.profiles
      profiles = {
        arteii = {
          # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
          id = 0; # 0 is the default profile; see also option "isDefault"
          name = "arteii"; # name as listed in about:profiles
          isDefault = true; # can be omitted; true if profile ID is 0
          settings = {
            # specify profile-specific preferences here; check about:config for options
            "browser.theme.dark-private-windows" = true;
            "extensions.formautofill.creditCards.enabled" = false; # Disable credit cards
            "dom.payments.defaults.saveAddress" = false; # Disable address save
            "ui.systemUsesDarkTheme" = 1;
            "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            "browser.startup.homepage" = "https://github.com";
            "browser.link.open_newwindow" = true;
            "browser.in-content.dark-mode" = true;
            "browser.newtabpage.pinned" = [
              {
                title = "NixOS";
                url = "https://nixos.org";
              }
              {
                title = "NixOS Search";
                url = "https://search.nixos.org/packages";
              }
              {
                title = "GitHub";
                url = "https://github.com";
              }
              {
                title = "Discord";
                url = "https://discord.com/app";
              }
            ];

            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;

            # disable pw manager as we use protonpass
            "signon.rememberSignons" = lock-false;
            "extensions.formautofill.addresses.enabled" = lock-false;

            # ram optimizations
            "browser.sessionhistory.max_entries" = 10;
            "browser.sessionhistory.max_total_viewers" = 2;

            "network.predictor.enabled" = false;
            "network.prefetch-next" = false;
            "network.dns.disablePrefetch" = true;

            "dom.ipc.processCount" = 4;
            "dom.ipc.processCount.webIsolated" = 4;

            "gfx.webrender.all" = true;
            "layers.acceleration.force-enabled" = true;

            "config.trim_on_minimize" = true;
            "browser.tabs.unloadOnLowMemory" = true;
          };

          extraOpts.ExtensionSettings = {
            # blocks and purges extensions not listed here
            # required to rmeove extensions that where lsited here before
            "*" = {
              installation_mode = "blocked";
            };

            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };

            # Darkreader
            "addon@darkreader.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };

            "endorse-all-skills-for-linkedin@eladmizrahi" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/endorse-all-skills-for-linkedin/latest.xpi";
              installation_mode = "force_installed";
            };

            # Proton Pass:
            "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
              installation_mode = "force_installed";
            };

            "languagetool-webextension@languagetool.org" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
              installation_mode = "force_installed";
            };
            # I Dont Care About Cookies
            "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
              installation_mode = "force_installed";
            };
            # Unpaywall
            "{f209234a-76f0-4735-9920-eb62507a54cd}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/unpaywall/latest.xpi";
              installation_mode = "force_installed";
            };
            # add extensions here...
          };
        };
        profiles.privacy = {
          id = 1;
          name = "Privacy";
          settings = {
            "browser.theme.dark-private-windows" = true;

            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.letterboxing" = true;

            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.clearOnShutdown.history" = true;
            "privacy.clearOnShutdown.cookies" = true;

            "media.peerconnection.enabled" = false; # WebRTC Leak Schutz
            "network.trr.mode" = 3; # Erzwinge DNS-over-HTTPS (Quad9)
            "network.trr.uri" = "https://dns.quad9.net/dns-query";

            "toolkit.telemetry.enabled" = false;
            "browser.send_pings" = false;
            "browser.safebrowsing.malware.enabled" = false;
            "browser.safebrowsing.phishing.enabled" = false;

            "network.predictor.enabled" = false;
            "network.prefetch-next" = false;
            "browser.places.speculativeConnect.enabled" = false;
            "geo.enabled" = false;
          };

          extraOpts.ExtensionSettings = {
            # blocks and purges extensions not listed here
            # required to rmeove extensions that where lsited here before
            "*" = {
              installation_mode = "blocked";
            };

            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };
    };
  };
}
