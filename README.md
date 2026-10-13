# NoirNet

NoirNet monitors internet and DNS access and sends notifications. It supports various notification methods including Pushover and native desktop notifications.

[![Support me on Buy Me a Coffee](https://img.shields.io/badge/Support%20me-Buy%20Me%20a%20Coffee-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/binarynoir)
[![Support me on Ko-fi](https://img.shields.io/badge/Support%20me-Ko--fi-blue?style=for-the-badge&logo=ko-fi)](https://ko-fi.com/binarynoir)
[![Visit my website](https://img.shields.io/badge/Website-binarynoir.tech-8c8c8c?style=for-the-badge)](https://binarynoir.tech)

## Features

- Monitor internet and DNS access
- Sends notifications via Pushover and native desktop notifications (macOS, Linux, Windows)
- Configurable check intervals
- Verbose logging with different log levels
- Background execution support
- Customizable configuration
- Detailed error reporting

## Feature Roadmap

- [x] Monitor internet and DNS access
- [x] Send notifications via Pushover
- [x] Send notifications via native desktop notifications (macOS, Linux, Windows)
- [x] Track downtime in CSV formatted files
- [ ] Output average downtime
- [ ] Add average downtime to notifications
- [ ] Full historical downtime report
- [ ] Allow heartbeat notifications every hour (fully configurable)

## Requirements

- Bash 4.3+ (macOS ships Bash 3.2; install a newer one with `brew install bash`)
- `curl` for Pushover notifications
- `jq` for reading the configuration file
- `ping` for network connectivity checks
- `nslookup` for DNS resolution checks (`dnsutils` or `bind-tools` on Linux)
- GNU `realpath` on Linux, or `grealpath` from `brew install coreutils` on macOS
- `powershell` for Windows desktop notifications
- `notify-send` for Linux desktop notifications

## Installation

### macOS Using Homebrew

1. Tap the repository (if not already tapped):

   ```bash
   brew tap binarynoir/noirnet
   ```

2. Install NoirNet:

   ```bash
   brew install noirnet
   ```

### Manual Installation (Linux/macOS Only)

1. Clone the repository:

   ```bash
   git clone https://github.com/binarynoir/noirnet.git
   cd noirnet
   ```

2. Make the script executable:

   ```bash
   chmod +x noirnet
   ```

3. Install `notify-send` for desktop notifications (if not already installed) on Linux:

   ```bash
   # On Debian/Ubuntu-based systems
   sudo apt install libnotify-bin

   # On Fedora-based systems
   sudo dnf install libnotify

   # On Arch-based systems
   sudo pacman -S libnotify
   ```

### Windows Installation

1. Install [Git for Windows](https://gitforwindows.org/) (includes Git Bash, if not installed).

2. Clone the repository:

   ```bash
   git clone https://github.com/binarynoir/noirnet.git
   cd noirnet
   ```

3. Make the script executable (in Git Bash or similar terminal):

   ```bash
   chmod +x noirnet
   ```

4. Ensure PowerShell is enabled in your Git Bash environment for notifications.

### Installing the Man Page (Linux/macOS Only)

1. Move the man file to the appropriate directory:

   ```bash
   sudo mv noirnet.1 /usr/local/share/man/man1/
   ```

2. Update the man database:

   ```bash
   sudo mandb
   ```

3. View the man page:

   ```bash
   man noirnet
   ```

## Setting Up as a Service

### Linux

1. Create a systemd service file:

   ```bash
   sudo nano /etc/systemd/system/noirnet.service
   ```

2. Add the following content to the service file:

   ```ini
   [Unit]
   Description=NoirNet Service
   After=network.target

   [Service]
   ExecStart=/path/to/noirnet
   WorkingDirectory=/path/to
   Restart=always
   User=your-username

   [Install]
   WantedBy=multi-user.target
   ```

   Replace `/path/to/noirnet` with the actual path to the `noirnet` script and `your-username` with your actual username.

   Do not add `--start` here. systemd runs NoirNet in the foreground and restarts it if it stops; `--start` would detach it from systemd. Logs go to the journal (`journalctl -u noirnet`) as well as the NoirNet log file.

3. Reload systemd to apply the new service:

   ```bash
   sudo systemctl daemon-reload
   ```

4. Enable the service to start on boot:

   ```bash
   sudo systemctl enable noirnet
   ```

5. Start the service:

   ```bash
   sudo systemctl start noirnet
   ```

6. Check the status of the service:

   ```bash
   sudo systemctl status noirnet
   ```

### macOS

Run NoirNet as a LaunchAgent so it runs as you, reads your configuration file, and can show desktop notifications.

1. Create a launchd plist file:

   ```bash
   nano ~/Library/LaunchAgents/com.noirnet.plist
   ```

2. Add the following content to the plist file:

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.noirnet</string>
       <key>ProgramArguments</key>
       <array>
           <string>/path/to/noirnet</string>
       </array>
       <key>EnvironmentVariables</key>
       <dict>
           <key>PATH</key>
           <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
       </dict>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
       <key>StandardErrorPath</key>
       <string>/tmp/noirnet.launchd.log</string>
   </dict>
   </plist>
   ```

   Replace `/path/to/noirnet` with the actual path to the `noirnet` script. Do not add `--start`; launchd keeps NoirNet running in the foreground. The `PATH` entry lets launchd find Homebrew's Bash, because macOS's built-in Bash 3.2 cannot run NoirNet.

3. Load the plist file to start the service:

   ```bash
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.noirnet.plist
   ```

4. Check the status of the service:

   ```bash
   launchctl print gui/$(id -u)/com.noirnet | grep state
   ```

5. To unload the service:

   ```bash
   launchctl bootout gui/$(id -u)/com.noirnet
   ```

### Setting Up NoirNet as a Service on Windows

1. **Create a Task in Task Scheduler**:

   - Open Task Scheduler and select "Create Task".
   - In the "General" tab, name the task "NoirNet" and select "Run whether user is logged on or not".
   - In the "Triggers" tab, click "New" and set the trigger to "At startup".
   - In the "Actions" tab, click "New" and set the action to "Start a program".
     - In the "Program/script" field, enter the path to `bash.exe` (usually located in `C:\Program Files\Git\bin\bash.exe` if using Git Bash).
     - In the "Add arguments (optional)" field, enter the path to the `noirnet` script and the `--start` argument, e.g., `/path/to/noirnet --start`.
   - In the "Conditions" tab, uncheck "Start the task only if the computer is on AC power" to ensure it runs on battery power as well.
   - In the "Settings" tab, ensure "Allow task to be run on demand" is checked.

2. **Save and Test the Task**:

   - Click "OK" to save the task.
   - To test the task, right-click on the "NoirNet" task in Task Scheduler and select "Run".

3. **Verify the Task**:

   - Check the status of the task in Task Scheduler to ensure it is running.
   - Verify that NoirNet is running by checking the log file or the expected notifications.

## Usage

Run the script with the desired options. Below are some examples:

- Start monitoring with default settings:

  ```bash
  ./noirnet
  ```

- Specify a custom configuration file:

  ```bash
  ./noirnet --config /path/to/config
  ```

- Run the script in the background:

  ```bash
  ./noirnet --start
  ```

- Send Pushover notifications:

  ```bash
  ./noirnet --pushover --user-key YOUR_USER_KEY --api-token YOUR_API_TOKEN
  ```

## Configuration

NoirNet uses a configuration file to store default settings. The default location is `~/.config/noirnet.json`. You can initialize a configuration file with default settings using:

```bash
./noirnet --init
```

### Example Configuration File

```json
{
    "configuration": {
        "CACHE_DIR": "/tmp/noirnet_cache",
        "LOG_FILE": "/tmp/noirnet_cache/noirnet.log",
        "CHECK_INTERVAL": "60s",
        "TIMEOUT": "5s",
        "SYSTEM_NAME": "test system",
        "PUSHOVER_NOTIFICATION": "false",
        "PUSHOVER_USER_KEY": "",
        "PUSHOVER_API_TOKEN": "",
        "DESKTOP_NOTIFICATION": "true",
        "VERBOSE": "false",
        "LOG_LEVEL": "INFO",
        "PING_TARGET": "8.8.8.8",
        "DNS_TEST_DOMAIN: "example.com"
    }
}
```

### Configuration Notes

- `--init` creates the configuration file so only your user can read it, because it can hold your Pushover keys. Keep it out of version control.
- Settings given on the command line override the configuration file.
- Unknown keys in the `configuration` section are ignored with a warning, so a typo cannot change unrelated settings.
- `CHECK_INTERVAL` and `TIMEOUT` take a whole number with an optional `s`, `m`, `h` or `d` suffix, such as `30s` or `5m`.
- The cache directory must belong to your user. NoirNet refuses to use system directories, your home directory, or a directory owned by someone else.

## Options

### General Options

- `-h, --help`: Display the help message.
- `-V, --version`: Display the script version.

### Configuration and Initialization

- `-c, --config <config_file>`: Specify a custom configuration file.
- `-i, --init`: Initialize the configuration file.
- `-f, --force-init`: Force initialize the configuration file if one exists.
- `-S, --show-config`: Show the configuration settings.
- `-e, --show-config-file`: Show the configuration file.
- `-E, --edit-config`: Edit the configuration file.

### Cache Management

- `-x, --clean`: Delete all cached files.
- `-C, --cache-dir <path>`: Specify a custom cache directory.

### Notification Options

- `-n, --system-name <name>`: Name of the system running the script.
- `-p, --pushover`: Send Pushover notifications.
- `-u, --user-key <key>`: Specify the user key for Pushover notifications.
- `-a, --api-token <token>`: Specify the API token for Pushover notifications.
- `-d, --desktop`: Send desktop notifications using AppleScript.

### Logging and Output

- `-v, --verbose`: Enable verbose output.
- `-l, --log`: Log the log file to the screen.
- `-o, --output <file>`: Specify a custom log file location.
- `-L, --log-level <level>`: Set the log level (FATAL, ERROR, WARN, INFO, DEBUG).

### Remote Connection Configuration

- `-I, --interval <s,m,h,d>`: Set the interval between checks (default: 60 seconds).
- `-T, --timeout <s,m,h,d>`: Set the connection timeout for remote connections (default: 5 seconds).
- `-N, --repeat <number>`: Repeat the checks in interactive mode N number of times and exit (default: 0).
- `-P, --ping-target <IP>`: Set a custom ping target (default: 8.8.8.8).
- `-D, --dns-test-domain <domain>`: Set a custom DNS test domain (default: example.com).

### Process Management

- `-s, --start`: Start the NoirNet service in the background.
- `-k, --stop`: Stop the NoirNet service.
- `-r, --restart`: Restart the NoirNet service.
- `-t, --status`: Check the current status of the NoirNet service. Exits with code 0 when it is running and 3 when it is stopped.

## Docker Deployment Instructions

This guide provides step-by-step instructions to deploy the NoirNet service using Docker.

### Docker Prerequisites

Ensure you have the following installed on your system:

- Docker

### Build and Deploy

Clone the repository, then build the image from the repository root. The image contains the `noirnet` script from your checkout and runs it as an unprivileged user.

```sh
git clone https://github.com/binarynoir/noirnet.git
cd noirnet
docker build -t noirnet-image .
docker run -d --restart unless-stopped --name noirnet noirnet-image
```

The image creates a default configuration at `/app/noirnet.json`. To use your own, mount it over that file:

```sh
docker run -d --restart unless-stopped --name noirnet \
  -v "$PWD/noirnet.json:/app/noirnet.json:ro" noirnet-image
```

NoirNet runs in the foreground, so `docker logs noirnet` shows its output and `docker stop noirnet` shuts it down cleanly. Arguments after the image name are passed to NoirNet, for example `docker run --rm noirnet-image --show-config`.

## Instructions for Running the Tests

The tests run offline against local test servers, so they do not depend on outside websites.

### Prerequisites

- Bash 4.3+ and the dependencies listed under [Requirements](#requirements)
- `python3` for the local test web server
- `shellcheck` to lint the scripts (optional)

### Steps to Run the Tests

From the repository root:

```bash
./test/test.sh
```

The script prints `ok` or `FAIL` for each check and exits with a non-zero status if any check fails. It works in a temporary directory and removes everything it creates when it exits.

To lint the scripts:

```bash
shellcheck -s bash noirnet test/*.sh scripts/*.sh
```

GitHub Actions runs the linter and the tests on Linux and macOS for every push and pull request.

## Releases

### Releasing new releases

1. Update `VERSION` and `LAST_UPDATED` in the `noirnet` script.
2. Add an entry for the new version to `CHANGELOG.md`.
3. Commit the changes and merge them to `main`.
4. Run the release script from the repository root:

   ```bash
   ./scripts/publish-release.sh
   ```

The script checks that the working tree is clean, that you are on `main`, and that the changelog has an entry for the version. It then tags the version and pushes the tag. The tag starts the release workflow, which runs CI, checks that the tag matches `VERSION`, creates the GitHub release, and updates the Homebrew formula.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Author

John Smith III

## Acknowledgments

Thanks to all contributors and users for their support and feedback.
