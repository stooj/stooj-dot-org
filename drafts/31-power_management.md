Title: Power Management and Hardware support
Date: 2025-03-24T22:14:10
Category: NixOS

This laptop is still woefully underconfigured and it's not that nice to use, but there are still "urgent" things to configure before I get down to making it sleek and cool.

During the last blog post, drummer ran out of battery. I didn't notice until the machine just flicked off; no warning, no shutdown... Just cut the power.

When I charged it and turned it back on, there were orphaned fs nodes and my nix config git repo was _borked_. I've never seen that before, but I had to reclone the repo and recreate my commits. Luckily I had this blog to follow what I'd already done.

Time for another todo list:

- [ ] Laptop power management
- [ ] Notifications for low battery warnings

## How to not make your laptop run the batteries down to the actual minumum and switch off

```bash
cd ~/code/nix/nix-config
git checkout -b power-management
```

I should install the updates first.

```bash
nix flake update
```

<!-- TODO Link to commit 1802076 -->

Now to find a place to put this configuration. Eventually this repo is going to have the configuration for **all** my laptops, servers, maybe phones (?), and anything else I can squeeze NixOS on, so I don't want the power management config to be in the main file where it (a) will apply to everything or (b) can't be shared with some things.

Stick it in a separate file in the root for now.

<!-- TODO Link to commit d26026f -->

Enabling suspend and resume is remarkably simple. It's this:

<!-- TODO Link to commit d3d49cc -->

Apply the change and test it out:

```bash
sudo nixos-rebuild switch --flake .
systemctl suspend
```

Screen went blank and cam back when I pressed a button. That's a win.

How about

```bash
systemctl hibernate
```

Huh, no. `drummer` maybe hibernated (journalctl says so) but the machine didn't recover when I pressed the power button again. It's almost certainly because of the encrypted swap partition inside an LVM.

Try setting the kernel parameter like the Arch docs say:

<!-- TODO Link to commit 4b7e910 -->

And since it's a kernel parameter, apply the config (`sudo nixos-rebuild etc etc`) and reboot the machine.

And see what happens now:

```bash
systemctl hibernate
```

Black screen. Laptop off.

Press the power button, decrypt the LVM...

WOAH! I'm back where I was. Honestly, I didn't expect that to work.

I'm going to hibernate the machine over night and see what the battery is like tomorrow. It's at 68.85% just now.

It's at 68.47% this morning. But drummer didn't resume, and according to `journalctl --boot=0` something went wrong:

```
Mar 25 08:56:42 drummer kernel: Hibernate inconsistent memory map detected!
Mar 25 08:56:42 drummer kernel: PM: hibernation: Image mismatch: architecture specific data
Mar 25 08:56:42 drummer kernel: PM: hibernation: Read 1324844 kbytes in 0.01 seconds (132484.40 MB/s)
Mar 25 08:56:42 drummer kernel: PM: Error -1 resuming
Mar 25 08:56:42 drummer kernel: PM: hibernation: Failed to load image, recovering.
Mar 25 08:56:42 drummer kernel: PM: hibernation: Basic memory bitmaps freed
Mar 25 08:56:42 drummer kernel: OOM killer enabled.
Mar 25 08:56:42 drummer kernel: Restarting tasks ... done.
Mar 25 08:56:42 drummer kernel: PM: hibernation: resume failed (-1
```

Hmm. Found plenty of unsolved bug reports suggesting it's a general hardware/firmware/bios/too-hard issue. So maybe I'll try and look at hardware configuration generally and get the [microcode](https://wiki.archlinux.org/title/Microcode) configured.

The first stop for drummer is this amazing repo: [NixOS/nixos-hardware: A collection of NixOS modules covering hardware quirks.](https://github.com/NixOS/nixos-hardware). There's even a `system76` section, but nothing for my Darter Pro 8 😢.

Added the input to flake.nix and ran `nix flake update` to update the lock file.

<!-- TODO Link to commit 23d8c7d -->

Then output the nixos-hardware input.

<!-- TODO Link to commit 640e593 -->

Finally add a bit of hardware configuration from the nixos-hardware repo. In this case it's the [system76 section](https://github.com/NixOS/nixos-hardware/blob/master/system76/default.nix), which enables [`hardware.system76.enableAll`](https://search.nixos.org/options?channel=unstable&show=hardware.system76.enableAll&from=0&size=50&sort=relevance&type=packages&query=hardware.system76.enableAll), the recommended configuration for system76 systems.

<!-- TODO Link to commit b5af069 -->

Reading through [the code](https://github.com/NixOS/nixpkgs/blob/1e5b653dff12029333a6546c11e108ede13052eb/nixos/modules/hardware/system-76.nix), the option turns on:

- The system76 firmware daemon (a systemd service that exposes a DBUS API for handling firmware updates, and there's also a CLI for applying them)
- Out-of-tree system76 kernel modules (adds system76 and system76-io modules to the boot kernel modules)
- The system76 power daemon (a utility for managing graphics and power levels)

Apply the changes and watch nothing change. Maybe the battery will last longer.

I wonder if the firmware tool will see anything:

```bash
sudo system76-firmware-cli
```

```
error: 'system76-firmware-cli' requires a subcommand but one was not provided

USAGE:
    system76-firmware-cli <SUBCOMMAND>

For more information try --help
```

OK.

```bash
sudo system76-firmware-cli --help
```

```
system76-firmware-cli 
Download and install updates of System76 firmware

USAGE:
    system76-firmware-cli <SUBCOMMAND>

OPTIONS:
    -h, --help    Print help information

SUBCOMMANDS:
    help          Print this message or the help of the given subcommand(s)
    schedule      Schedule installation of firmware for next boot
    thelio-io     Update Thelio IO firmware
    unschedule    Cancel scheduled firmware installation
```

Right. Seems straight-forward enough. Update the firmware.

```bash
sudo system76-firmware-cli schedule
```

```
Automatic transition: 76ec -> 76ec
creating cache directory /var/cache/system76-firmware-daemon
downloading tail
system76-firmware: failed to download: failed to remove tail cache
```

Boo. This bug has been reported: [gaze15 on NixOS 24.11: system76-firmware: failed to download: failed to remove tail cache · Issue #159 · pop-os/system76-firmware](https://github.com/pop-os/system76-firmware/issues/159). Although `76ec -> 76ec` suggests to me that I'm running the latest of everything.

I'll leave that for now and look at hardware instead. There's a specific nixos-hardware derivation for the [darter pro 6](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/system76/darp6/default.nix), but not for later ones, so I'm going to build my own.

I put the power management import inside `configuration.nix`, which was wrong. My plan is to get `configuration.nix` as small as possible. It's only going to have the unique configuration for `drummer` (so it's going to be `drummer/configuration.nix` or something).

Imports belong in the `flake.nix` outputs, and each host will have it's own set of imports (inside `nixosConfigurations.<hostname>`).

Drummer is a Darter Pro 8, so I'll make a file for darter-8-specific configuration.

<!-- TODO Link to commit babf9d6 -->

What's the CPU? Running `cpuinfo | grep name` gives me:

```
  Model name:             12th Gen Intel(R) Core(TM) i7-1260P
```

According to the [Intel® Product Specifications](https://www.intel.com/content/www/us/en/ark.html) page that's an [Alder Lake](https://www.intel.com/content/www/us/en/products/sku/226254/intel-core-i71260p-processor-18m-cache-up-to-4-70-ghz/specifications.html).

Hm, adding `nixos-hardware.nixosModules.common-cpu-intel-alder-lake` to my flake doesn't work:

<!-- TODO Link to commit d4d8547 -->

```
error:
       … while calling the 'seq' builtin
         at /nix/store/sr3gj4wcx3kwy0q5gcxl49ja733bqm7b-source/lib/modules.nix:334:18:
          333|         options = checked options;
          334|         config = checked (removeAttrs config [ "_module" ]);
             |                  ^
          335|         _module = checked (config._module);

       … while evaluating a branch condition
         at /nix/store/sr3gj4wcx3kwy0q5gcxl49ja733bqm7b-source/lib/modules.nix:273:9:
          272|       checkUnmatched =
          273|         if config._module.check && config._module.freeformType == null && merged.unmatchedDefns != [] then
             |         ^
          274|           let

       (stack trace truncated; use '--show-trace' to show the full, detailed trace)

       error: attribute 'common-cpu-intel-alder-lake' missing
       at /nix/store/1ppszkqns0kqxalsbx65r4xdv1yv7rji-source/flake.nix:36:9:
           35|         }
           36|         nixos-hardware.nixosModules.common-cpu-intel-alder-lake
             |         ^
           37|         nixos-hardware.nixosModules.system7
```

Hmm. That looks like the `nixos-hardware` flake doesn't output `common-cpu-intel-alder-lake`. Right enough, if you check the [flake.nix source](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/flake.nix#L342) the named cpus are all marked as deprecated, and alder-lake isn't listed.

Looking through the source for all the different intel codenames though ([Alder lake](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/cpu/intel/alder-lake/cpu-only.nix), [Coffee lake](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/cpu/intel/coffee-lake/cpu-only.nix), [Sandy bridge](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/cpu/intel/sandy-bridge/cpu-only.nix), etc.) they all just point to the [top-level intel cpu-only file](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/cpu/intel/cpu-only.nix) anyway. That enables the intel microcode, meaning my CPU will get patched with any fixes at boot time.

Setting `common-cpu-intel` will include the intel cpu and gpu configuration. The [gpu configuration](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/gpu/intel/default.nix) is a bit more complicated. If I'm reading this right, by default both [VAAPI](https://en.wikipedia.org/wiki/Video_Acceleration_API) drivers (`intel-vaapi-driver` and `intel-media-driver`) are enabled. OCL won't be enabled unless I've allowed `nonFree` stuff.

<!-- TODO Link to commit adaef1c -->

That'll do it though, I don't think I need that `darp8` file any more.

<!-- TODO Link to commit a57744d -->

Drummer is a laptop. I'll add that too:

<!-- TODO Link to commit 55c837a -->

That'll turn on [tlp](https://wiki.archlinux.org/title/TLP) and [fstrim](https://wiki.archlinux.org/title/Solid_state_drive#Periodic_TRIM). Nice.

That'll do for hardware tweaks just now. It's time to switch out xterm for alacritty and get a nicer shell prompt. 

```bash
cd ~/code/nix/nix-config
git checkout main
git merge power-management
```

# References

- [Laptop - NixOS Wiki](https://nixos.wiki/wiki/Laptop)
- [Power management/Suspend and hibernate - ArchWiki](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate)
- [Hibernation - NixOS Wiki](https://nixos.wiki/wiki/Hibernation)
- [dm-crypt/Swap encryption - ArchWiki](https://wiki.archlinux.org/title/Dm-crypt/Swap_encryption#With_suspend-to-disk_support)
- [NixOS/nixos-hardware: A collection of NixOS modules covering hardware quirks.](https://github.com/NixOS/nixos-hardware)
- [NixOS Search - Options - hardware.system76.enableAll](https://search.nixos.org/options?channel=unstable&show=hardware.system76.enableAll&from=0&size=50&sort=relevance&type=packages&query=hardware.system76.enableAll)
- [pop-os/system76-firmware: System76 Firmware Tool and Daemon](https://github.com/pop-os/system76-firmware)
- [pop-os/system76-power: Power profile management for Linux](https://github.com/pop-os/system76-power)
- [nixos-hardware/system76/darp6/default.nix at master · NixOS/nixos-hardware](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/system76/darp6/default.nix)
- [Intel® Product Specifications](https://www.intel.com/content/www/us/en/ark.html)
- [nixos-hardware/common/gpu/intel/default.nix at de6fc5551121c59c01e2a3d45b277a6d05077bc4 · NixOS/nixos-hardware](https://github.com/NixOS/nixos-hardware/blob/de6fc5551121c59c01e2a3d45b277a6d05077bc4/common/gpu/intel/default.nix)
- [Video Acceleration API - Wikipedia](https://en.wikipedia.org/wiki/Video_Acceleration_API)
- [TLP - ArchWiki](https://wiki.archlinux.org/title/TLP)
- [Solid state drive - ArchWiki](https://wiki.archlinux.org/title/Solid_state_drive#Periodic_TRIM)
