# Hemlock

Hemlock is an Emacs-style text editor written in Common Lisp. It provides three backends:

* TTY
* QT
* X11

The X11 backend is the most full-featured and is almost the same as the original CMUCL IDE.

<img width="935" height="992" alt="Screenshot 2025-07-28 143156" src="https://github.com/user-attachments/assets/ac91891e-2a48-4312-a5e0-64d26fbc85b6" />

## Status

Suitable for daily use.  Customisation is easy.  If you add a command, please open a pull request to
add it to the main system.

## Getting Started

This guide explains how to set up and start Hemlock from a Common Lisp REPL.  Also be sure to read the [wiki](https://github.com/Symbolics/hemlock/wiki) to understand where this version of Hemlock differs from the CMUCL documentation.

### Coming from Emacs

* M-x slime -> M-X 'Start Slave Thread'
* If you resize the terminal, use C-l to redisplay the content (we're working on this)
* The help system is pretty good in Hemlock.  Use C-h or the HOME key to invoke it, and key an 
eye on the mode line for more hints.
* Putty messes up the right Meta (alt) key.  Windows now includes SSH that handles this properly.

### Prerequisites

- A Common Lisp implementation (SBCL, CCL, etc.)
- [Quicklisp](https://www.quicklisp.org/)
- Linux with [libfixposix](https://github.com/sionescu/libfixposix) installed
- SBCL

The Linux dependency comes from [IOLIB](https://github.com/sionescu/iolib), which seems to suffer bitrot.  Long term this should be replaced with [UIOP](https://github.com/fare/asdf/tree/master/uiop) where possible (such as the completions and dired functionality).

SBCL is not a hard requirement, but is the only system tested.  If you try on another system and it doesn't work, please raise an issue.

First ensure that you have `libfixposix` installed.  If on a debian based system:

```
sudo apt-get update && sudo apt-get install -y libfixposix-dev
```

### Installation


You must clone the repository into a location known to Quicklisp so that the dependencies can be obtained.  `~/common-lisp` is preconfigured to be recognized and is a good choice to start with.

To clone the source:
   ```sh
   git clone https://github.com/Symbolics/hemlock.git
   ```
   _or_
   ```sh
   git clone https://github.com/bluelisp/hemlock
   ```

If the latter is active.  The upstream repository (from bluelisp) seems to have been dead since 2018.

### Get Dependencies

First, get all the dependencies using Quicklisp.  After this you can either load via Quicklisp or ASDF.

```
(ql:quickload :hemlock/tty)
```


### Loading Hemlock

To load with ASDF (after dependencies have been obtained with Quicklisp), start SBCL and:
```
(asdf:load-system :hemlock/tty)   ;; Terminal interface
(asdf:load-system :hemlock/clx)   ;; X11 interface
(asdf:load-system :hemlock/qt)    ;; Qt interface (experimental)
```

### Starting Hemlock
After loading, start Hemlock with:

`(hemlock:hemlock)`

or, on SBCL and CCL:

`(ed)`


## System Structure

This version uses a consolidated ASDF system definition (`hemlock.asd`) that defines all backend systems using the subsystem naming convention:

- `:hemlock` - Main umbrella system (loads `:hemlock/base` for compatibility)
- `:hemlock/base` - Core editor functionality
- `:hemlock/tty` - Terminal/console interface
- `:hemlock/clx` - X11/CLX graphical interface  
- `:hemlock/qt` - Qt-based graphical interface


## Backends

### TTY Backend
The TTY backend provides a terminal-based interface that works in any text terminal with terminfo support.

### CLX Backend  
The CLX backend provides an X11 graphical interface using the CLX library.

### Qt Backend (Experimental)
The Qt backend provides a graphical interface using CommonQt.

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

See the individual source files for license information; they vary, but are mostly in the public domain.
