# He## System Structure

This version uses a modern consolidated ASDF system definition (`hemlock.asd`) that defines all backend systems using the subsystem naming convention:

- `:hemlock` - Main umbrella system (loads `:hemlock/base` for compatibility)
- `:hemlock/base` - Core editor functionality
- `:hemlock/tty` - Terminal/console interface
- `:hemlock/clx` - X11/CLX graphical interface  
- `:hemlock/qt` - Qt-based graphical interfaceitor

Hemlock is an Emacs-style editor written in Common Lisp, originally developed as part of CMUCL and later ported to other Common Lisp implementations.

## System Structure

This version uses a consolidated ASDF system definition (`hemlock.asd`) that defines all backend systems using the subsystem naming convention:

- `:hemlock` - Main umbrella system (loads `:hemlock/base` for compatibility)
- `:hemlock/base` - Core editor functionality
- `:hemlock/tty` - Terminal/console interface
- `:hemlock/clx` - X11/CLX graphical interface  
- `:hemlock/qt` - Qt-based graphical interface

## Installation and Building

### Quick Start

```bash
./build.sh
./hemlock --help
```

### Building Specific Backends

```bash
./build.sh tty          # TTY backend only
./build.sh clx          # CLX backend only
./build.sh qt           # Qt backend only
./build.sh tty clx      # Multiple backends
```

### Loading from REPL

```lisp
;; Add to ASDF registry
;; This works, but is no longer recommended
(push #p"/path/to/hemlock/" asdf:*central-registry*)

;; Load the main system (includes core functionality)
(asdf:load-system :hemlock)

;; Or load specific backends
(asdf:load-system :hemlock/tty)   ; Terminal interface
(asdf:load-system :hemlock/clx)   ; X11 interface
(asdf:load-system :hemlock/qt)    ; Qt interface

;; Start Hemlock
(hemlock:hemlock)
;; or simply
(ed)  ; SBCL and CCL only
```

## Dependencies

### Core Dependencies (hemlock/base)
- alexandria
- bordeaux-threads  
- conium
- trivial-gray-streams
- iterate
- prepl
- osicat
- iolib
- cl-ppcre
- command-line-arguments

### Backend-Specific Dependencies
- **TTY backend**: No additional dependencies
- **CLX backend**: CLX library
- **Qt backend**: CommonQt, qt-repl

## Backends

### TTY Backend
The TTY backend provides a terminal-based interface that works in any text terminal with terminfo support.

### CLX Backend  
The CLX backend provides an X11 graphical interface using the CLX library.

### Qt Backend (Experimental)
The Qt backend provides a modern graphical interface using CommonQt.

## Legacy System Names

Prior to consolidation, the systems used different naming:
- `hemlock.base` → `:hemlock/base`
- `hemlock.clx` → `:hemlock/clx`
- `hemlock.qt` → `:hemlock/qt`
- `hemlock.tty` → `:hemlock/tty`

## Directory Structure

```
hemlock/
├── hemlock.asd           # Main ASDF system definition
├── build.sh             # Build script
├── INSTALL              # Installation instructions
├── src/                 # Source code
├── doc/                 # Documentation
├── resources/           # Resources (cursors, etc.)
├── c/                   # C utilities
└── backup-asd-files/    # Original .asd files (backup)
```

## License

See the individual source files for license information.
