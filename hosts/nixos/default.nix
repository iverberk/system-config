{ config, inputs, pkgs, ... }:

let
  user = "iverberk";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOk8iAnIaa1deoc7jw8YACPNVka1ZFJxhnU4G74TmS+p"
  ];
in {
  imports = [
    ../../modules/nixos/disk-config.nix
    ../../modules/shared
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 42;
        consoleMode = "0";
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    # Uncomment for AMD GPU
    # initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "uinput" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "dev"; # Define your hostname.
    useDHCP = false;
    interfaces.ens160.useDHCP = true;
  };

  virtualisation = {
    vmware.guest.enable = true;
    docker.enable = true;
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings = {
      allowed-users = [ "${user}" ];
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    zsh.enable = true;

    ssh = {
      startAgent = true;
    };
  };

  services = {
    # Fallback console on tty1: auto-login your user
    getty.autologinUser = user;
    getty.autologinOnce = false;

    # Display manager & X server
    displayManager.defaultSession = "none+i3";

    xserver = {
      enable = true;
      xkb = {
        layout = "nl";
        variant = "mac";
      };
      dpi = 220;

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };

      displayManager = {
        lightdm.enable = true;

        setupCommands = ''
          ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --auto
        '';

        sessionCommands = ''
          ${pkgs.xorg.xset}/bin/xset r rate 200 40
        '';
      };

      windowManager = {
        i3.enable = true;
      };
    };

    # Better support for general peripherals
    libinput.enable = true;

    # Let's be able to SSH into this machine
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
  };

  # Video support
  hardware = {
    graphics.enable = true;
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      home = "/home/iverberk";
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.zsh;
      hashedPassword = "$6$9C2p8Wlxq6KBZWyg$HnwZhzP4tfgsw/3/p.kd47A3bk09kU05.EYrwJBeW2923JaPjXHcEzBlpK.Qp38fXI9BS1idBxhjBaf9VZ0pT0";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFAy4KxFlFnpvVhGzr4U/2w30N/t6BErFu0P+Sb6ulav" ]; 
    };

    root = {
      openssh.authorizedKeys.keys = sshKeys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  fileSystems."/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "umask=22"
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.meslo-lg
      meslo-lgs-nf
    ];
  };

  environment = {
    localBinInPath = true;

    systemPackages = with pkgs; [
      cachix
      gnumake
      killall
      gtkmm3
      copyq
      xclip
      unzip
      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
    ];

    variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
    };

  };

  system.stateVersion = "21.05"; # Don't change this
}
