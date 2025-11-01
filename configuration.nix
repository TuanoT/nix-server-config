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

  # Netwoking
  networking.hostName = "NIXOS";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    80 # HTTP
    443 # HTTPs
  ];
  networking.firewall.allowedUDPPorts = [137 138];
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

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

  # Define a user account.
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

  # Mount storage drive
  fileSystems."/mnt/storage" = {
    device = "UUID=89a162db-04b3-4f60-9327-c43096f27da5";
    fsType = "ext4";
  };

  # Mount backup drive 1
  fileSystems."/mnt/backup" = {
    device = "UUID=6fefa947-96a8-49f8-9fe9-4275b4f4360a";
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

      # Share the main storage
      storage = {
        path = "/mnt/storage";
        browseable = true;
        readOnly = false;
        guestOk = true;
        forceUser = "tom";
        forceGroup = "users";
      };

      # Share the backup pool
      backup = {
        path = "/mnt/backup";
        browseable = true;
        readOnly = false;
        guestOk = true;
        forceUser = "tom";
        forceGroup = "users";
      };
    };
  };

  system.stateVersion = "25.05";
}