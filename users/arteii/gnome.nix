{ pkgs, ... }:

{
  dconf = {
    enable = true;

    settings = {
      # Dark Mode Gnome
      "org/gnome/desktop/background" = {
        picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.src}";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      # Stop the Activities Overview from lagging when you tap the Super key
      # Disables external background indexing engines during standard shell search
      "org/gnome/desktop/search-providers" = {
        disable-external = true;
        disabled = [
          "org.gnome.Characters.desktop"
        ];
      };

      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
      };

      "org/gnome/desktop/session" = {
        idle-delay = 1200;
      };

      "org/gnome/desktop/screensaver" = {
        lock-enabled = false;
        clock-enabled = true;
        show-notifications = false;
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>s";
        command = "systemctl suspend";
        name = "Suspend System";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/desktop/break-reminders" = {
        selected-breaks = [
          "movement"
          "eyesight"
        ];
      };

      "org/gnome/desktop/break-reminders/movement" = {
        interval-seconds = 2400;
        duration-seconds = 300;
        play-sound = true;
      };

      "org/gnome/desktop/break-reminders/eyesight" = {
        interval-seconds = 2400;
        duration-seconds = 300;
        play-sound = true;
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          "Vitals@CoreCoding.com"
        ];
      };

      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = "['_processor_temperature_', '_fan_speed_']";

        show-fan-speed = true;
        show-processor = true;
        show-temperature = true;

        position-in-top-bar = 2;
      };
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
    };
  };
}
