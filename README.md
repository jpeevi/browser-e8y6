# browser:e8y6

A web browser developed for **[os:e8y6](https://github.com/jpeevi/os-e8y6)**.


## Features

- Minimal, dark-themed interface
- Custom Start, About, and Configuration pages
- Simplified navigation and tab management
- Lightweight build configuration
- Dedicated browser profile with persistent data
- Compatibility with existing Falkon internal URLs

## Technology

- **Foundation:** KDE Falkon
- **Browser engine:** Qt WebEngine (Chromium-based)
- **Framework:** Qt 6 / KDE Frameworks 6
- **Platform:** Linux

## Build Prerequisites

Requires Linux (Ubuntu/Xubuntu recommended), a C++17 compiler, CMake, Ninja, Qt 6 with WebEngine, KDE Frameworks 6, and the required development libraries.

Optional integrations may require additional dependencies. A reduced-dependency Lite mode is supported.

## Development

Build and launch locally:

```bash
./dev.sh
```

Development profile: `browser-e8y6-dev`

## Updates

- **os:e8y6** manages Qt WebEngine and its security updates.
- **browser:e8y6** manages browser features, interface, and Falkon integration.
- Upstream Falkon changes are reviewed and integrated selectively.

## License

Based on [KDE Falkon](https://www.falkon.org/). Original Falkon copyright notices and applicable open-source licenses are retained.