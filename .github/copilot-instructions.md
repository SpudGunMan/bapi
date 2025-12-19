# Copilot Instructions for bAPi (Build-A-Pi Mark II)

## Project Overview
- **bAPi** is a Bash/YAD-based package manager and installer for ham radio applications, inspired by KM4ACK's Build-a-Pi.
- The core logic is driven by `.bapp` files (per-app install scripts with metadata and functions) and a menu system built with YAD.
- The project targets Debian-based systems (Raspberry Pi and x86_64), with special handling for ARM and Pi hardware.

## Key Components & Structure
- **bin/**: Core scripts (menu, runner, app-check, template-maker, etc.)
  - `menu.sh`: Main YAD menu, loads `.bapp` files, presents install options.
  - `bap-runner.sh`: Executes selected `.bapp` install jobs, manages build process.
  - `app-check.sh`: Updates `.bapp` metadata, checks installed versions.
  - `template-maker.sh`: Generates new `.bapp` files from templates.
- **data/app_db/**: Application database
  - `stable/` and `experimental/`: App categories, each app has a `.bapp` file.
  - `README.md`: Documents `.bapp` format, dev tools, and conventions.
- **.bapp files**: Bash scripts with required headers and functions (`INSTALL`, `VERSION`, `DEPENDS`).

## Developer Workflows
- **Install/Run**: Clone repo, run `bapi.sh` from a graphical terminal. The menu will guide app selection and installation.
- **Debugging**: `touch .debug` in the project root for verbose output. Logs/errors go to `errors/`.
- **App Development**:
  - Use `bin/template-maker.sh build` to scaffold new `.bapp` files.
  - Test `.bapp` files with `bin/dev-runner.sh <file.bapp>`.
  - Use `bin/app-check.sh` to update/check app metadata.
- **Reset/Cache**:
  - `bin/set-enviroment.sh reset` to reset user data.
  - `bin/set-enviroment.sh clean` to clear source cache.
  - Source/build files are in `~/.bap-source-files` (symlinked as `src/`).

## Project-Specific Conventions
- **.bapp file format**: Strict header/metadata, required functions (`INSTALL`, `VERSION`, `DEPENDS`).
- **Branching**: `stable/` for core/maintained apps, `experimental/` for community or less-tested apps.
- **Variables**: Many global env vars (e.g., `BAPARCH`, `BAPCPU`, `BAPCALL`) are set at runtime and used in `.bapp` scripts.
- **No automatic OS upgrades**: Users are advised to upgrade their OS before running bAPi.
- **YAD**: All UI is via YAD forms/dialogs; ensure YAD is installed.

## Integration & Extensibility
- **Adding new apps**: Follow `.bapp` template and place in the appropriate `stable/` or `experimental/` directory.
- **External dependencies**: Most apps are built from source; ensure required dev tools are present (see README for details).
- **Menu system**: Only apps with valid `.bapp` files and headers are shown in the menu.

## References
- See `README.md` and `data/app_db/README.md` for more details on architecture, workflows, and `.bapp` conventions.
- For contributing, see `CONTRIBUTING.md`.

---

**Example: Minimal .bapp file**
```bash
BAPP=4.0
ID=EXAMPLE
Name='Example'
Comment='Example Ham App'
VerLocal=0 #runtime set
VerRemote=0 #runtime set
W3='http://appweb.local'
Author='spud'
NOTE='any notes for double click in menu'

INSTALL(){
  # build/install steps
}
VERSION(){
  # version detection logic
}
DEPENDS(){
  # dependency logic
}
```
