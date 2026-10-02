# Linux Doctor

! [Linux Doctor] ([https://raw.githubusercontent.com/oh-okay/Linux-Doctor/blob/main/assets/icon.png](https://github.com/oh-okay/Linux-Doctor/blob/main/assets/icon.png?raw=true))

A little Linux diagnostic tool for when something is broken and you don't feel like digging through ten different commands first.

Linux Doctor runs a handful of read-only checks and puts the useful bits in one terminal report. It looks at the system, hardware, storage, network, services, kernel, and running processes.

## Why it exists

Linux is great at telling you exactly what happened, once you know which command to run. Linux Doctor is a quick first pass: run one command, spot the warning, then dig deeper only when you need to.

## Installation

Linux Doctor does not need a package manager or third-party Python packages. Put the project directory wherever you keep local tools, then make the launcher executable:

```bash
cd linux-doctor
chmod +x linux-doctor checks/*.sh
```

You can also copy the directory anywhere and run the launcher directly.

## Usage

```bash
./linux-doctor
./linux-doctor --details
./linux-doctor --json
./linux-doctor --report report.md
./linux-doctor --version
./linux-doctor --help
```

Example output:

```text
linux-doctor

System
────────────────────────────
✓ Operating system: Fedora Linux 42
✓ Architecture: x86_64
✓ Kernel: 6.15.8

Storage
────────────────────────────
✓ /: 38% used
⚠ /home: 87% used

Network
────────────────────────────
✓ Network interface: enp6s0
✓ Default gateway: 192.168.1.1
✓ DNS lookup: Working

────────────────────────────
1 thing worth looking at.
```

The values above are only an example. The command reads the current machine each time it runs.

## What it checks

- **System:** OS, architecture, desktop session, and init system
- **Hardware:** processor, memory, graphics device, driver, and available temperature readings
- **Storage:** mounted filesystem usage
- **Network:** active interface, default gateway, DNS lookup, and a small HTTPS reachability check
- **Services:** systemd state and failed units when systemd is available
- **Kernel:** uptime, load average, and recent kernel errors when permitted
- **Processes:** process count and the top CPU process

The Bash scripts in `checks/` talk to Linux. `src/linux_doctor.py` parses their plain output, decides how to present severity, and handles terminal, JSON, and Markdown output.

## Supported systems

Linux distributions with a reasonably standard userspace should work, including Fedora, Ubuntu, Debian, Arch, openSUSE, and their derivatives. Some individual results depend on optional commands such as `lspci`, `sensors`, `curl`, or `systemctl` being installed.

## Privacy

Everything runs locally. Linux Doctor has no telemetry, external API calls, background service, or data upload. The network check makes one request to `https://example.com` only when `curl` is available; this can be skipped by removing that check from `checks/network.sh`.

## Limitations

- It is a first-pass diagnostic, not a repair tool.
- It never changes system configuration, restarts services, or deletes files.
- Some kernel, service, and hardware details are unavailable without permissions or optional utilities.
- Warnings are useful clues, not proof that a component is broken.
- The project currently targets a terminal workflow rather than a graphical interface.

## License

absolutely no license
