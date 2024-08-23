

# https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/7
{ config, pkgs, ... }:

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
  programs = {
    firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
        extraPolicies = {
          DisableTelemetry = true;
          # add policies here...

          /* ---- EXTENSIONS ---- */
          ExtensionSettings = {
            # uBlock Origin:
            "uBlock0@raymondhill.net" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
	    
	    "languagetool-webextension@languagetool.org" = {
	      install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
	      installation_mode = "force_installed";
            };
	    # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };
	    # Disconnect
            "2.0@disconnect.me" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/disconnect/latest.xpi";
              installation_mode = "force_installed";
            };
	    # I Dont Care About Cookies
	    "jid1-KKzOGWgsW3Ao4Q@jetpack" = {
	      install_url = "https://addons.mozilla.org/firefox/downloads/latest/i-dont-care-about-cookies/latest.xpi";
	      installation_mode = "force_install";
	    };
            # Ghostery
	    "firefox@ghostery.com" = {
	      install_url = "https://addons.mozilla.org/firefox/downloads/latest/ghostery/latest.xpi";
	      installation_mode = "force_install";
	    };
	    # Unpaywall
	    "{f209234a-76f0-4735-9920-eb62507a54cd}" = {
	      install_url = "https://addons.mozilla.org/firefox/downloads/latest/unpaywall/latest.xpi";
	      installation_mode = "force_install";
	    };
            # add extensions here...
          };
  
          /* ---- PREFERENCES ---- */
          # Set preferences shared by all profiles.
          Preferences = { 
            "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
            "extensions.pocket.enabled" = lock-false;
            "extensions.screenshots.disabled" = lock-true;
            # add global preferences here...
          };
        };
      };

      /* ---- PROFILES ---- */
      # Switch profiles via about:profiles page.
      # For options that are available in Home-Manager see
      # https://nix-community.github.io/home-manager/options.html#opt-programs.firefox.profiles
      profiles ={
        arteii = {           # choose a profile name; directory is /home/<user>/.mozilla/firefox/profile_0
          id = 0;               # 0 is the default profile; see also option "isDefault"
          name = "arteii";   # name as listed in about:profiles
          isDefault = true;     # can be omitted; true if profile ID is 0
          settings = {          # specify profile-specific preferences here; check about:config for options
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
            # add preferences for profile_0 here...
          };
        };
      # add profiles here...
      };
    };
  };
}
