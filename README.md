<p align="center"><img src="https://i.imgur.com/X5zKxvp.png" width=300px></p>

<p align="center">
<a href="https://nixos.org/"><img src="https://img.shields.io/badge/NixOS-unstable-informational.svg?style=flat&logo=nixos&logoColor=CAD3F5&colorA=24273A&colorB=8AADF4"></a> 

<p align="center"><img src="https://i.imgur.com/NbxQ8MY.png" width=600px></p>

---

- **Window Manager** • [Hyprland](https://github.com/hyprwm/Hyprland)🎨 
- **Shell** • [Zsh](https://www.zsh.org) 🐚 with
  [starship](https://github.com/starship/starship)
- **Terminal** • [Kitty](https://sw.kovidgoyal.net/kitty/) 💻
- **Panel** • [AGS](https://github.com/Aylur/ags)🍧
- **Launcher** • [AnyRun](https://github.com/Kirottu/anyrun) 🚀
- **File Manager** • [yazi](https://yazi-rs.github.io)🔖
- **Neovim** • [Akari](https://github.com/spector700/Akari)


## 🌼 <samp>INSTALLATION (NixOS)</samp>

- Download ISO.
```bash
wget -O https://channels.nixos.org/nixos-23.05/latest-nixos-minimal-x86_64-linux.iso
```

- Boot Into the Installer.

- Switch to Root: `sudo -i`

- Partitions:

*I prefer to use 1GB on the EFI partition. Specifically because the 'generations' list may become very long, and to avoid overloading the partition.*

```bash
# Replace nvme with your disk partition
gdisk /dev/nvme0n1
```
	- `o` (create new partition table)
	- `n` (add partition, 512M, type ef00 EFI)
	- `n` (add partition, remaining space, type 8300 Linux)
	`w` (write partition table and exit)

- Format Partitions:

```bash
mkfs.fat -F 32 -n EFI /dev/nvme0n1p1
mkfs.xfs -L NIXOS /dev/nvme0n1p2
```

- Mount Partitions:

```bash
mount /dev/disk/by-label/NIXOS /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/EFI /mnt/boot
```

- Enable nixFlakes

```bash
nix-shell -p nixFlakes git
```

- Clone my Dotfiles 

```bash 
git clone --depth 1 https://github.com/spector700/nixos-config /mnt/etc/nixos
```

- Generate your Own Nix Hardware Settings:
### ⚠ <sup><sub><samp>DON'T FORGET IT</samp></sub></sup>

```bash
sudo nixos-generate-config --dir --force /mnt/etc/nixos/hosts/desktop

# Remove configuration.nix 
rm -rf /mnt/etc/nixos/hosts/desktop/configuration.nix
```

- Install Dotfiles Using Flake

```bash
# Move to folder
cd mnt/etc/nixos/

# Install
nixos-install --flake .#desktop
```

- Reboot

### 🐙  <sup><sub><samp>Remember <strong>Default</strong> User & password are: nixos</samp></sub></sup>

- Change Default password for User.

# 💾 Inspiration

- [fufexan/dotfiles](https://github.com/fufexan/dotfiles)
- [linuxmobile/kaku](https://github.com/linuxmobile/kaku)
- [Gerg-L/nixos](https://github.com/Gerg-L/nixos)
- [Misterio77/nix-config](https://github.com/Misterio77/nix-config)

---
<small align="center" >Intro Stolen from @linuxmobile</small>
