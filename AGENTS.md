# AGENTS.md — browser:e8y6 project guide

This file is the durable context for any coding assistant working in this repository. **Read it before proposing commands or editing code.** The current repository and its files are the source of truth; this document records conventions and decisions, not a substitute for inspection. If this document conflicts with the code, report the difference and ask before making broad changes.

## Project identity and intent

- **Product:** `browser:e8y6`, a Qt 6 / Qt WebEngine browser forked from KDE Falkon, developed for `os:e8y6` (an experimental Linux OS designed to bring modern Linux to older hardware).
- **Repository:** `https://github.com/jpeevi/browser-e8y6`.
- **Working directory on the user's machines:** `~/browser-e8y6`.
- **Current release preparation:** application `0.1.3`, Debian revision `2` (package version `0.1.3-2`), Git commit `575f8f3fa` on `master`. These are a *checkpoint*, not hard-coded permanent values: always read `VERSION`, `DEB_REVISION`, `git log -1`, and `git status` before acting.
- The CMake project name remains `Falkon` internally for compatibility. Do not rename internal symbols, project structure, plugins, or profile formats casually.
- Falkon's original logo on the About and Configuration pages is **intentional attribution**. Do not remove it unless requested.

## Non-negotiable established decisions

1. **Canonical browser-internal scheme:** `e8y6:`; particularly `e8y6:start`, `e8y6:about`, `e8y6:config`. Legacy `falkon:` and `browser-e8y6:` schemes remain recognized for compatibility. Don't generate legacy addresses as new defaults.
2. **Current browser logo:** `branding/browser-e8y6-home.svg`. The obsolete `branding/browser-e8y6.png` was deliberately removed; never restore it as a fallback or reintroduce its `b:86` artwork.
3. The homepage, About, and Configuration pages must **show the actual SVG logo**, not temporary text or an empty placeholder. The Qt resource is declared in `src/lib/data/html.qrc` with alias `browser-e8y6-home.svg`. `src/lib/network/schemehandlers/falkonschemehandler.cpp` injects the image into HTML. Preserve `%BROWSER-LOGO%` image placeholders; check MIME types (SVG, not PNG).
4. The installed desktop application icon is `browser-e8y6.svg`, sourced from the SVG above and installed to `${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps`. See root `CMakeLists.txt`. `src/lib/app/mainapplication.cpp` references `../share/icons/hicolor/scalable/apps/browser-e8y6.svg`; maintain consistency. Desktop entries use `Icon=browser-e8y6`. Previously installed old PNG icon files can linger in a development install; do not confuse those with files included in a fresh `.deb`.
5. Preserve browser profile data, cookies, bookmarks, history, sessions, settings, and current browsing state. Never delete, reset, or migrate user data without explicit approval. Do not resurrect the abandoned Ctrl+B bookmarks feature.
6. Keep the custom new-tab `+` icon, single-tab minimum, Start replacement for old Speed Dial, and existing UI behavior unless changing them is explicitly requested. Old Speed Dial data should not be deleted.
7. Avoid sweeping search-and-replace patches. In particular, source changes to Qt/C++/CMake must be checked for syntax, resource paths, and behavior before presenting them as tested.

## Important source locations

| Purpose | File / directory |
| --- | --- |
| Main Qt application, icon and theme loading, scheme initialization | `src/lib/app/mainapplication.cpp` |
| Internal scheme registration | `src/lib/network/networkmanager.cpp` |
| Internal HTML page renderer and logo substitutions | `src/lib/network/schemehandlers/falkonschemehandler.cpp` |
| Embedded HTML/SVG resources | `src/lib/data/html.qrc` |
| Homepage | `src/lib/data/html/start.html` |
| About / Configuration | `src/lib/data/html/about.html`, `config.html` |
| Startup URL behavior | `src/lib/app/browserwindow.cpp` |
| New-tab behavior | `src/lib/tabwidget/tabwidget.cpp` |
| User-facing internal-page commands | `src/lib/app/mainmenu.cpp` |
| Browser preferences | `src/lib/preferences/preferences.cpp` |
| JS-facing internal URL compatibility | `src/lib/webengine/javascript/externaljsobject.cpp` |
| Canonical browser logo | `branding/browser-e8y6-home.svg` |
| Icon install rule, version reading and project setup | `CMakeLists.txt` |
| Application version | `VERSION` |
| Debian packaging revision | `DEB_REVISION` |
| Debian metadata and build rules | `debian/` |
| Existing Debian packaging script | `build-deb.sh` |
| Existing development helper | `dev.sh` |

## Development workflow (local machine)

- `./dev.sh build` configures with CMake/Ninja, builds with four parallel jobs, and installs into `local-install/`.
- `./dev.sh run` launches the already installed development build using profile **`browser-e8y6-dev`**.
- `./dev.sh all` builds, installs, reports version and launches; `./dev.sh version` shows the version; `./dev.sh help` shows supported commands.
- `./dev.sh` is **not** a `.deb` packager; do not invent packaging flags for it.
- Avoid `./dev.sh clean` unless needed and authorized; it removes generated build/install files.
- The user prefers **one step at a time**, a concise explanation and exact copy-pasteable terminal commands. Request the command's output before moving to the next release step. Don't repeatedly investigate facilities already visible in the repository.

## Debian packaging — established process

- **Build host:** Dell (shell prompt often `peevi@peevihsu`).
- **Install/test host:** Vivobook (shell prompt often `peevi@peevi-vivobook`).
- Existing packaging script: **`./build-deb.sh`** from the repository root. Do not create another packager without a clear need.
- `build-deb.sh` reads `VERSION` and `DEB_REVISION`, generates package version `<VERSION>-<DEB_REVISION>`, adds a Debian changelog entry if required, and runs `dpkg-buildpackage -us -uc -b -j2` with output logged under `build-logs/`. It prints `.deb` files found in the parent directory.
- `debian/rules` builds using CMake+Ninja with `build-debian/` and installs under `/usr`. Check packaging output before distribution.
- **Caution:** the script can modify `debian/changelog`. Inspect and decide whether to commit this generated change as part of packaging preparation.
- Current archive's `debian/changelog` begins at `0.1.2-1`; the existing script should add `0.1.3-2` when invoked, subject to current checkout state. Do not claim it already happened without checking.
- A successful development build is not proof that the Debian package is correct. Inspect the final `.deb` with `dpkg-deb -I` and `dpkg-deb -c`; verify the installed SVG icon, desktop file, executable, resources and dependencies. Use the **specific newly generated file**, not an old package matched by a wildcard.
- Transfer the verified package to Vivobook. Install with `sudo apt install ./<actual-package-file>.deb`. Test the **system-installed application**, not `local-install/` or `./dev.sh run`.
- Verify startup `e8y6:start`, new tabs, SVG logos on all three internal pages, legacy URL compatibility, window/app icons, normal HTTPS browsing, downloads, proper close/relaunch and preservation of existing user profiles/bookmarks.
- **Only after testing passes** create a Git tag for the exact tested source commit and publish the corresponding `.deb` in the GitHub release. Do not invent a version/tag or claim a release exists before it has been published.

## Current checkpoint — 2026-10-16

- On Vivobook the user reported the updated development browser looked good after fixing an accidental missing `));` in the app icon code.
- Commit `575f8f3fa` (`fix: finalize e8y6 internal pages and SVG branding for v0.1.3`) was created on Vivobook, and the user confirmed the push to `origin/master`.
- Dell checkout was shown at `575f8f3fa` with version `0.1.3` and Debian revision `2`.
- The user displayed the existing `build-deb.sh` and Debian files. **No successful 0.1.3-2 Debian build, Vivobook package install, or published release has yet been verified in the conversation.**
- **Next step:** on Dell run `./build-deb.sh`, capture the result, and then inspect the resulting `.deb` before any transfer or release. If package building was already performed, ask for the output/file and verify rather than rerun blindly.

## Working rules for assistants

- Begin by checking current state (`git status --short`, relevant file contents, version); never assume old conversation notes exactly describe the checkout today.
- Make the smallest targeted edit, and protect unrelated work and user data.
- Report uncertainty directly; avoid saying a change is working without an actual build/test result.
- If source or build logs are available, read them before guessing at the cause of a failure. A compiler error must be fixed at the actual location, not by rewriting large sections.
- Do not stage temporary backups, IDE files, build directories, logs or local install artifacts. `.e8y6-fix-backups/` is a local working directory that must **never** be committed.
- Before committing: review `git diff`, `git diff --check`, staged contents and the current branch. Before tagging/releasing: compare Git commit, Debian package version and installed package contents.
- Avoid needlessly changing website branding, os:e8y6 configuration, or other separate projects while modifying the browser.
- Treat Qt/KDE/Falkon attribution and license obligations as continuing requirements of this fork.

## If context is lost

Read `AGENTS.md`, `VERSION`, `DEB_REVISION`, `build-deb.sh`, `dev.sh`, `debian/rules`, and the relevant current source code. Check `git status` and the latest commit. **Do not ask the user to re-explain decisions documented here or start packaging from scratch.** State what is confirmed and continue from the last verifiable checkpoint.
