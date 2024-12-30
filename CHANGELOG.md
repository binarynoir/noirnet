# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- none

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
