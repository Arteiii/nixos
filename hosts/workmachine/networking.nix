{
  networking = {
    hostName= "nixos";

    networkmanager = {
      enable = false;
    };
    useDHCP= true;
    useNetworkd = false;
    wireless = {
      enable = true;	
    };
  };
}
