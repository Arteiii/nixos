{ ... }:

{
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-label/MediaData";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "noatime"
    ];
  };
}
