{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "NIXOS";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tom = {
    isNormalUser = true;
    description = "Tom Purcell";
    extraGroups = ["networkmanager" "wheel"];
    hashedPasswordFile = "/etc/nixos/tom.passwd";
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vscode
    git
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Vscode server
  services.vscode-server.enable = true;

  #FIX ME
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    80 # HTTP
    443 # HTTPs
    139 # Samba
    445 # Samba
  ];
  networking.firewall.allowedUDPPorts = [22 137 138];
  networking.networkmanager.dns = "none";
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  # Mount external storage drive
  fileSystems."/mnt/storage" = {
    device = "UUID=89a162db-04b3-4f60-9327-c43096f27da5";
    fsType = "ext4";
  };

  # Enable Samba
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        mapToGuest = "bad user";
        "server string" = "Belmar Server";
        "netbios name" = "BELMAR-SERVER";
        "guest account" = "nobody";
        "server min protocol" = "SMB2";
        "server max protocol" = "SMB3";
        security = "user";
        "wins support" = "yes";
      };

      storage = {
        path = "/mnt/storage";
        browseable = true;
        readOnly = false;
        guestOk = true; # allow anyone on the network to access
        forceUser = "tom";
        forceGroup = "users";
      };
    };
  };

  system.stateVersion = "25.05";
}
