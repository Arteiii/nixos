{ pkgs, ... }:
{
  programs.thunderbird = {
    enable = true;

    package = pkgs.thunderbird.override {
      extraPolicies = {
        ExtensionSettings = {
          # 1. Thunderbird Conversations
          "gcontactsync@pirules.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/thunderbird-conversations/addon-438644-latest.xpi";
          };

          # 2. DKIM Verifier
          "dkim_verifier@schondorf.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dkim-verifier/addon-324497-latest.xpi";
          };

          # 3. BorderColors D
          "bordercolorsd@fastmail.fm" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/bordercolors-d/addon-987971-latest.xpi";
          };

          # 4. Quicktext
          "quicktext@martinwendt.de" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/quicktext/addon-987934-latest.xpi";
          };

          # 5. FiltaQuilla
          "filtaquilla@realussr.github.com" = {
            installation_mode = "force_installed";
            install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/filtaquilla/addon-987747-latest.xpi";
          };
        };
      };
    };

    policies = {
      DisableTelemetry = true;
      BlockAboutConfig = true;

      Preferences = {
        # --- TELEMETRY & PRIVACY  ---
        "datareporting.policy.dataSubmissionEnabled" = {
          Value = false;
          Status = "locked";
        };
        "mailnews.message_display.disable_remote_image" = {
          Value = true;
          Status = "locked";
        };

        # --- ANTI-SPOOFING & SECURITY ---
        "mail.identity.default.compose_html" = {
          Value = false;
          Status = "locked";
        };
        "mail.showCondensedAddresses" = {
          Value = false;
          Status = "locked";
        };
        "mailnews.headers.showSender" = {
          Value = true;
          Status = "locked";
        };
        "network.IDN_show_punycode" = {
          Value = true;
          Status = "locked";
        };

        # --- METADATA-PROTECTION ---
        "mailnews.headers.sendUserAgent" = {
          Value = false;
          Status = "locked";
        };
        "mail.inline_attachments" = {
          Value = false;
          Status = "locked";
        };
        "mailnews.auto_config.fetchFromISP.sendEmailAddress" = {
          Value = false;
          Status = "locked";
        };
        "mailnews.start_page.enabled" = {
          Value = false;
          Status = "locked";
        };

        # --- HARDENING ---
        "network.dns.disablePrefetch" = {
          Value = true;
          Status = "locked";
        };
        "network.prefetch-next" = {
          Value = false;
          Status = "locked";
        };
        "network.cookie.cookieBehavior" = {
          Value = 2;
          Status = "locked";
        };
        "network.http.sendRefererHeader" = {
          Value = 0;
          Status = "locked";
        };
        "media.peerconnection.enabled" = {
          Value = false;
          Status = "locked";
        };
        "pdfjs.disabled" = {
          Value = true;
          Status = "locked";
        };
        "pdfjs.enableScripting" = {
          Value = false;
          Status = "locked";
        };
        "browser.safebrowsing.phishing.enabled" = {
          Value = false;
          Status = "locked";
        };
        "browser.safebrowsing.malware.enabled" = {
          Value = false;
          Status = "locked";
        };
        "network.proxy.allow_hijacking_localhost" = {
          Value = true;
          Status = "locked";
        };
      };
    };
  };

  environment.etc."thunderbird/pref/sys-hardening.js".text = ''
    // Crash Reporter und künstliche Einschränkungen umgehen
    lockPref("toolkit.crashreporter.enabled", false);
    lockPref("app.shield.optoutstudies.enabled", false);

    // Von Policies blockierte Stabilitäts- & Sicherheits-Optionen hart sperren
    lockPref("javascript.enabled", false);
    lockPref("datareporting.healthreport.uploadEnabled", false);
    lockPref("privacy.donottrackheader.enabled", true);
    lockPref("privacy.trackingprotection.enabled", true);
    lockPref("toolkit.telemetry.unified", false);
  '';
}
