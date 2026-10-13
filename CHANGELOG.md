# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- none

## [1.5.0] - 2026-10-13

### Fixed

- On macOS the ping timeout was in milliseconds, so the default 5 second timeout became 5 milliseconds and the network could be reported down on a working connection
- `PING_TARGET` and `DNS_TEST_DOMAIN` were not checked, so a value that starts with `-` was read as an option by `ping` or `nslookup`
- `test/test.json` was not valid JSON
- Running with Bash 3.2, the macOS default, now prints a clear error instead of failing partway through
- `-v, --verbose` was rejected unless `-L, --log-level` was also given
- `--clean` deleted the default cache directory instead of the one set in the configuration file
- `--restart` did nothing when the service was stopped
- Stopping the service could take up to a full check interval; it now stops immediately
- Pushover notifications were built with `eval`, so text in a notification could run as shell code; desktop notifications on macOS and Windows broke on quotes
- The Windows desktop notification opened a dialog that paused checks until it was closed; it is now a notification balloon
- Invalid intervals and timeouts are rejected with a clear error instead of being misread
- `--init` built the configuration file by pasting values into JSON, so a quote in a value made the file invalid
- The Brewfile used commands Homebrew does not support; it now lists the development dependencies

### Changed

- `--status` exits with status 3 when the service is not running, so scripts can check it
- Configuration settings are no longer exported as environment variables to the commands NoirNet runs; commands still receive the settings as their argument
- Unknown keys in the configuration file are ignored with a warning
- The Dockerfile builds from the local checkout, runs as an unprivileged user, and runs NoirNet in the foreground so `docker logs` and `docker stop` work
- The systemd and launchd examples in the README run NoirNet in the foreground; with `--start` the service manager restarted it in a loop

### Security

- The configuration file, log file and cache directory are created readable only by you
- Pushover keys no longer appear in the process list or in debug logs
- The cache directory is refused if it belongs to another user, is a system directory, or is your home directory or one above it
- A stale PID file can no longer make `--stop` signal an unrelated process

### Added

- An offline test suite, `test/test.sh`
- A GitHub Actions workflow that runs ShellCheck and the tests on Linux and macOS
- The release workflow runs the tests first and checks that the tag matches `VERSION`; the release script checks for a clean `main` branch and a changelog entry

## [1.4.2] - 2025-01-01

### Fixed

- Issue where script wold not run

## [1.4.1] - 2024-12-30

### Fixed

- Minor variable protections

## [1.4.0] - 2024-12-17

### Added

- JSON based configuration files to support future functionality
- Edit to configuration file function
- Dockerfile to run as a service
- Repeat function N amount of times and exit

### Changed

- Reorganized functions
- Documentation reflects all new functionality
- Desktop notifications are defaulted to false

### Removed

- No longer supporting bash based config files

### Fixed

- Improper formatting to console in some cases
- Various issues running on linux

## [1.3.1] - 2024-11-29

### Fixed

- Configuration file failing to load

## [1.3.0] - 2024-11-29

### Added

- Restart service command line option

### Changed

- Updated single character command line options for consistency
- Documentation to reflect all changes in the latest release

### Fixed

- Failure to remove PID file on service stop

## [1.2.2] - 2024-11-27

### Fixed

- Initialization of config uses old config for new settings file

## [1.2.1] - 2024-11-26

### Changed

- Order of Pushover user key and api token

### Fixed

- Help output not displaying proper timeout defaults
- Missing details in man page

## [1.2.0] - 2024-11-26

### Added

- System name displayed in notifications using local host name
- System name configurable using `--system-name` `-n`

### Changed

- Cross platform CACHE_DIR path generation using system temporary path
- Cross platform CONFIG_FILE path generation using system configuration path
- Additional code reorganization

### Fixed

- Cross platform paths are normalization

## [1.1.0] - 2024-11-23

### Added

- Fatal error messages
- Default test configuration file

### Changed

- Default configuration file path to `$HOME/.config/noirnet.conf`
- Test script to the latest version of application and added additional testing
- README.md with latest information

## [1.0.4] - 2024-11-21

### Fixed

- Log file location option

## [1.0.3] - 2024-11-21

### Fixed

- Last updated information failure

## [1.0.2] - 2024-11-21

### Fixed

- Service failed to start

## [1.0.1] - 2024-11-21

### Changed

- Showing the version information now includes last updated date
- Reorganized functions for maintainability
- Updated cli help and man page for better grouping of topics

## [1.0.0] - 2024-11-21

### Added

- Initial release
