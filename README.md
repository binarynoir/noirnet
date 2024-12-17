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

- Bash
- `curl` for network requests
- `ping` for network connectivity checks
- `nslookup` for DNS resolution checks
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
   ExecStart=/path/to/noirnet --start
   WorkingDirectory=/path/to
   StandardOutput=syslog
   StandardError=syslog
   Restart=always
   User=your-username

   [Install]
   WantedBy=multi-user.target
   ```

   Replace `/path/to/noirnet` with the actual path to the `noirnet` script and `your-username` with your actual username.

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

1. Create a launchd plist file:

   ```bash
   sudo nano /Library/LaunchDaemons/com.noirnet.plist
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
           <string>--start</string>
       </array>
       <key>WorkingDirectory</key>
       <string>/path/to</string>
       <key>RunAtLoad</key>
       <true/>
       <key>KeepAlive</key>
       <true/>
       <key>StandardOutPath</key>
       <string>/var/log/noirnet.log</string>
       <key>StandardErrorPath</key>
       <string>/var/log/noirnet.log</string>
   </dict>
   </plist>
   ```

   Replace `/path/to/noirnet` with the actual path to the `noirnet` script.

3. Load the plist file to start the service:

   ```bash
   sudo launchctl load /Library/LaunchDaemons/com.noirnet.plist
   ```

4. Check the status of the service:

   ```bash
   sudo launchctl list | grep com.noirnet
   ```

5. To unload the service:

   ```bash
   sudo launchctl unload /Library/LaunchDaemons/com.noirnet.plist
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
- `-t, --status`: Check the current status of the NoirNet service.

## Docker Deployment Instructions

This guide provides step-by-step instructions to deploy the noirnet service using Docker.

### Docker Prerequisites

Ensure you have the following installed on your system:

- Docker


### Using the Dockerfile

To download the `Dockerfile` from the GitHub repository, run the following command:

```sh
curl -O https://raw.githubusercontent.com/binarynoir/noirnet/main/Dockerfile
```

### Build and Deploy

Navigate to the directory containing the `Dockerfile` and run the following command to build and start the service:

```sh
docker build -t noirnet-image .
docker run -d --name noirnet noirnet-image
```

### Conclusion

You have successfully deployed the noirnet service using Docker. The service will automatically start when the container is created and will restart if it stops unexpectedly. For any further modifications or assistance, feel free to ask!

## Instructions for Running the Tests

This document provides instructions for running the quality assurance tests for the NoirNet script using the `test.sh` file.

### Prerequisites

Ensure you have the following installed on your system:

- Bash
- Git (for cloning the repository)

### Steps to Run the Tests

1. **Navigate to the Test Directory**:

   ```bash
   cd test
   ```

2. **Update the Test Configuration File**: Open the `test.json` file in your preferred text editor and ensure it contains the following configuration:

   ```json
    {
        "configuration": {
            "CACHE_DIR": "./test/cache/",
            "LOG_FILE": "./test/cache/test.log",
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

3. **Make the test script executable**:

   ```bash
   chmod +x test.sh
   ```

4. **Run the Test Script with Default Configuration**:

   ```bash
   ./test.sh
   ```

5. **Run the Test Script with a Custom Configuration File**:

   ```bash
   ./test.sh /path/to/custom_config_file
   ```

6. **Clean Up Test Files (optional)**:

   ```bash
   rm -rf ./test_cache
   rm -f ./test.log
   ```

### Summary

The `test.sh` script will:

1. Create a test configuration file (default or custom).
2. Run various tests to check the functionality of NoirNet, including configuration initialization, cache directory creation, log file creation, and network monitoring.
3. Clean up the test files and directories after the tests are completed, except for the custom configuration file if it was passed in.

Follow these instructions to ensure that NoirNet is functioning correctly. If you encounter any issues, please open an issue or submit a pull request on the GitHub repository.

## Releases

### Releasing New Versions

- Update the changelog with new features and fixes.
- Commit all changed files and create a pull request.
- Run the release script from the project repo's root directory:

  ```bash
  ./scripts/publish-release.md
  ```

### Manually Releasing New Versions

- Create a new GitHub release using the new version number as the "Tag version". Use the exact version number and include a prefix `v`.
- Publish the release.

  ```bash
  git checkout main
  git pull
  git tag -a v1.y.z -m "v1.y.z"
  git push --tags
  ```

Run `shasum` on the release for homebrew distribution.

```bash
shasum -a 256 noirnet-1.x.x.tar.gz
```

The release will automatically be drafted.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Author

John Smith III

## Acknowledgments

Thanks to all contributors and users for their support and feedback.
