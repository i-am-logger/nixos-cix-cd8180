# Orange Pi 6 Plus bootloader configuration
# Uses NixOS's boot.loader.external module with vendor GRUB EFI
# Updates boot menu on every nixos-rebuild with multi-generation support

{ config
, lib
, pkgs
, ...
}:

with lib;

let
  cfg = config.boot.loader.orangepi6plus;
in

{
  options.boot.loader.orangepi6plus = {
    configurationLimit = mkOption {
      type = types.int;
      description = ''
        Maximum number of latest generations in the boot menu.
        Limited by 200MB ESP partition (~50MB per generation).

        To support more generations, increase ESP partition size.
        See: https://github.com/i-am-logger/nixos-cix-cd8180/issues/15
      '';
    };
  };

  config = {
    # Default to 3 generations for 200MB ESP (mkDefault allows user override)
    boot.loader.orangepi6plus.configurationLimit = mkDefault 3;

    # Create the bootloader installation script that updates vendor GRUB config
    # This script is called by NixOS during activation (switch/boot actions)
    # Use buildPackages to ensure script runs on build architecture (for cross-compilation)
    boot.loader.external.installHook = pkgs.buildPackages.writeShellScript "install-orangepi6plus-bootloader.sh" ''
      set -e
      PATH=${pkgs.buildPackages.coreutils}/bin:${pkgs.buildPackages.util-linux}/bin:${pkgs.buildPackages.jq}/bin:${pkgs.buildPackages.findutils}/bin:${pkgs.buildPackages.gnused}/bin:${pkgs.buildPackages.gnugrep}/bin:$PATH

      defaultConfig="''${1:-}"
      bootDir="''${2:-/boot}"

      if [ -z "$defaultConfig" ]; then
        echo "Usage: $0 <default-config-path> [boot-directory]"
        exit 1
      fi

      echo "Updating Orange Pi 6 Plus boot menu (multi-generation support)..."
      echo "Default configuration: $defaultConfig"
      echo "Boot directory: $bootDir"

      # Ensure boot directory exists and is accessible
      if [ "$bootDir" = "/boot" ]; then
        # For live system, ensure /boot is mounted
        if ! mountpoint -q /boot 2>/dev/null; then
          echo "/boot not mounted, attempting to mount..."
          mkdir -p /boot
          if ! mount /dev/disk/by-label/ESP /boot 2>/dev/null; then
            echo "WARNING: Could not mount /boot, proceeding anyway..."
          fi
        fi
      fi

      # Ensure required boot subdirectories exist (fix #8)
      mkdir -p "$bootDir/grub" "$bootDir/dtbs/cix"

      # Write GRUB config to temporary file first for atomic replacement (fix #3)
      grubCfgTmp="$bootDir/grub/grub.cfg.tmp"
      {
        echo "set debug=loader,mm"
        echo "set term=vt100"
        echo "set default=0"
        echo "set timeout=${toString config.boot.loader.timeout}"
        echo ""
      } > "$grubCfgTmp"

      # Find all system generations and create menu entries
      genCount=0
      profilesDir="/nix/var/nix/profiles"

      # Get list of all system generations, sorted newest first (fix #1: specific pattern)
      for generation in $(find "$profilesDir" -name 'system-[0-9]*-link' -type l 2>/dev/null | sort -V -r); do
        genNum=$(basename "$generation" | sed 's/system-\([0-9]*\)-link/\1/')
        
        # Validate generation number is numeric (fix #4)
        if ! [ "$genNum" -eq "$genNum" ] 2>/dev/null; then
          continue
        fi
        
        genPath=$(readlink -f "$generation")
        
        # Skip if generation path doesn't exist
        [ -d "$genPath" ] || continue
        
        # Get kernel and initrd from boot.json or symlinks
        kernel=""
        initrd=""
        
        if [ -f "$genPath/boot.json" ]; then
          kernel=$(jq -r '.["org.nixos.bootspec.v1"].kernel // .kernel // empty' "$genPath/boot.json" 2>/dev/null)
          initrd=$(jq -r '.["org.nixos.bootspec.v1"].initrd // .initrd // empty' "$genPath/boot.json" 2>/dev/null)
        fi
        
        if [ -z "$kernel" ] && [ -L "$genPath/kernel" ]; then
          kernel=$(readlink -f "$genPath/kernel")
        fi
        
        if [ -z "$initrd" ] && [ -L "$genPath/initrd" ]; then
          initrd=$(readlink -f "$genPath/initrd")
        fi
        
        # Skip if kernel or initrd not found or don't exist
        [ -n "$kernel" ] && [ -f "$kernel" ] || continue
        [ -n "$initrd" ] && [ -f "$initrd" ] || continue
        
        # Get kernel parameters and label
        kernelParams=$(cat "$genPath/kernel-params" 2>/dev/null || echo "rootwait")
        label=$(cat "$genPath/nixos-version" 2>/dev/null || echo "Unknown")
        
        # Install kernel and initrd with generation-specific names
        echo "Installing generation $genNum ($label)..."
        cp -f "$kernel" "$bootDir/Image-gen$genNum"
        cp -f "$initrd" "$bootDir/initrd-gen$genNum"
        
        # Mark current generation
        marker=""
        if [ "$genPath" = "$defaultConfig" ]; then
          marker=" (current)"
        fi
        
        # Add menu entry to temporary grub.cfg
        {
          echo "menuentry 'NixOS - Gen $genNum - $label$marker' {"
          echo "    linux /Image-gen$genNum $kernelParams init=$genPath/init"
          echo "    initrd /initrd-gen$genNum"
          echo "}"
          echo ""
        } >> "$grubCfgTmp"
        
        genCount=$((genCount + 1))
        
        # Limit to configured number of generations (default: 3 for 200MB ESP)
        if [ "$genCount" -ge ${toString cfg.configurationLimit} ]; then
          echo "Limited to ${toString cfg.configurationLimit} most recent generations (configurationLimit)"
          break
        fi
      done

      # If no generations found, install just the current one
      if [ "$genCount" -eq 0 ]; then
        echo "No system generations found, installing current configuration only..."
        
        # Get kernel and initrd from current config
        kernel=""
        initrd=""
        
        if [ -f "$defaultConfig/boot.json" ]; then
          kernel=$(jq -r '.["org.nixos.bootspec.v1"].kernel // .kernel // empty' "$defaultConfig/boot.json" 2>/dev/null)
          initrd=$(jq -r '.["org.nixos.bootspec.v1"].initrd // .initrd // empty' "$defaultConfig/boot.json" 2>/dev/null)
        fi
        
        if [ -z "$kernel" ] && [ -L "$defaultConfig/kernel" ]; then
          kernel=$(readlink -f "$defaultConfig/kernel")
        fi
        
        if [ -z "$initrd" ] && [ -L "$defaultConfig/initrd" ]; then
          initrd=$(readlink -f "$defaultConfig/initrd")
        fi
        
        if [ -n "$kernel" ] && [ -f "$kernel" ] && [ -n "$initrd" ] && [ -f "$initrd" ]; then
          kernelParams=$(cat "$defaultConfig/kernel-params" 2>/dev/null || echo "rootwait")
          label=$(cat "$defaultConfig/nixos-version" 2>/dev/null || echo "NixOS")
          genPath="$defaultConfig"  # For consistency with generation-based entries (fix #10)
          
          cp -f "$kernel" "$bootDir/Image"
          cp -f "$initrd" "$bootDir/initrd"
          
          {
            echo "menuentry '$label' {"
            echo "    linux /Image $kernelParams init=$genPath/init"
            echo "    initrd /initrd"
            echo "}"
          } >> "$grubCfgTmp"
          
          genCount=1
        fi
      fi

      # Ensure we created at least one boot entry (fix #2)
      if [ "$genCount" -eq 0 ]; then
        echo "Error: No valid boot menu entries could be created (missing kernel and/or initrd)" >&2
        rm -f "$grubCfgTmp"
        exit 1
      fi

      # Atomically replace grub.cfg (fix #3)
      mv "$grubCfgTmp" "$bootDir/grub/grub.cfg"

      # Install device tree blobs from current kernel (fix #9: better path resolution)
      kernel=""
      if [ -f "$defaultConfig/boot.json" ]; then
        kernel=$(jq -r '.["org.nixos.bootspec.v1"].kernel // .kernel // empty' "$defaultConfig/boot.json" 2>/dev/null)
      fi
      if [ -z "$kernel" ] && [ -L "$defaultConfig/kernel" ]; then
        kernel=$(readlink -f "$defaultConfig/kernel")
      fi

      if [ -n "$kernel" ]; then
        # Resolve kernel path and find the Nix store package root
        kernelReal=$(readlink -f "$kernel" 2>/dev/null || echo "$kernel")
        kernelPkgRoot="$kernelReal"
        while [ "$kernelPkgRoot" != "/" ] && [ "$(dirname "$kernelPkgRoot")" != "/nix/store" ]; do
          kernelPkgRoot=$(dirname "$kernelPkgRoot")
        done
        
        if [ "$(dirname "$kernelPkgRoot")" = "/nix/store" ] && [ -d "$kernelPkgRoot/dtbs/cix" ]; then
          echo "Installing device tree blobs..."
          mkdir -p "$bootDir/dtbs/cix"
          cp -f "$kernelPkgRoot"/dtbs/cix/*.dtb "$bootDir/dtbs/cix/" 2>/dev/null || true
        fi
      fi

      echo "Boot menu update complete - installed $genCount generation(s)"
    '';
  };
}
