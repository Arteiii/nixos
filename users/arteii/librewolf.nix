{ ... }:

{

  programs.librewolf = {
    enable = true;

    settings = {
      "privacy.clearOnShutdown.history" = true;
      "privacy.clearOnShutdown.downloads" = true;
      "privacy.clearOnShutdown.cookies" = true;
      "privacy.clearOnShutdown.cache" = true;
      "privacy.clearOnShutdown.sessions" = true;
      "privacy.clearOnShutdown.offlineApps" = true;

      "webgl.disabled" = false;
      "webgl.min_capability_mode" = true;

      "general.useragent.override" =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0";

      "privacy.resistFingerprinting.autoDeclineNoUserInput" = false;
      "privacy.resistFingerprinting.letterboxing" = false;
      "privacy.resistFingerprinting.breakage_mode" = true;

      "browser.webcompat.enabled" = true;

      "network.http.referer.trimPolicy" = 0;
      "network.http.referer.XOriginPolicy" = 1;
      "network.captive-portal-service.enabled" = false;
      "extensions.update.enabled" = false;

      "media.peerconnection.enabled" = false;

      "browser.display.use_document_fonts" = 0;
      "dom.battery.enabled" = false;

      "network.trr.mode" = 3;
      "network.trr.uri" = "https://dns.quad9.net/dns-query";

      "network.dns.echconfig.enabled" = true;
      "network.dns.http3_echconfig.enabled" = true;
      "network.dns.use_https_rr_as_altsvc" = true;
    };

    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
