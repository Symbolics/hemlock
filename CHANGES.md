# Hemlock Changes Log

This document tracks major changes to the Hemlock editor codebase.

## Terminfo System Refactoring (2025)

### Overview
Migrated Hemlock's terminal capability handling from internal terminfo/termcap implementation to external [terminfo library by Paul Foley](https://github.com/npatrick04/terminfo) for improved compatibility and maintainability.

### Changes Made
- **Removed local terminfo implementation**: Deleted internal `src/terminfo.lisp` file
- **Removed local termcap compatibility layer**: Deleted `src/termcap.lisp` file (no longer needed)
- **Created centralized terminal operations layer**: New `src/tty-terminal-ops.lisp` file provides unified interface for all terminal operations
- **Refactored capability access throughout codebase**: 
  - Updated `src/tty-screen.lisp` with 30+ capability replacements
  - Updated `src/tty-display.lisp` to use new centralized terminal operations
  - Updated `src/linedit.lisp` for terminal initialization
  - Verified `src/tty-input.lisp` already used correct external terminfo references
- **Added helper functions** to `src/tty-display.lisp`:
  - `valid-string-p` - checks for non-empty strings
  - `capability-or-default` - gets terminfo capability with fallback
- **Implemented automatic ANSI fallbacks**: All terminal operations now have built-in escape sequence fallbacks
- **Added terminal sequence caching**: Improves performance by caching resolved terminal sequences
- **Removed debugging statements**: Cleaned up debug output added during initial conversion

### Benefits
- **Better terminal compatibility**: External terminfo library handles more terminal types with comprehensive capability support (494+ capabilities vs Hemlock's limited subset)
- **Reduced code maintenance**: Eliminated 1200+ lines of internal terminfo code and simplified terminal operations throughout
- **Improved reliability**: Automatic ANSI fallbacks ensure basic functionality on all terminals
- **Standards compliance**: Uses system terminfo database instead of internal implementation
- **Modern implementation**: Paul Foley's library supports both 16-bit and 32-bit terminfo formats with proper padding/delay handling
- **Better performance**: Terminal sequence caching and direct capability symbol access reduce overhead
- **Cleaner code**: Replaced verbose capability checking patterns with simple function calls

### Files Modified
- `hemlock.asd` - Added `:terminfo` dependency and `tty-terminal-ops` component
- `src/tty-screen.lisp` - Capability access refactoring and cleanup
- `src/tty-display.lisp` - Added helper functions and refactored to use centralized operations
- `src/tty-terminal-ops.lisp` - New file for centralized terminal operations
- `src/linedit.lisp` - Terminal initialization updates
- `src/tty-input.lisp` - Verified external terminfo usage (no changes needed)

### Files Removed
- `src/terminfo.lisp` - Internal terminfo implementation (replaced by external library)
- `src/termcap.lisp` - Termcap compatibility layer (no longer needed)


---

## ASDF System Consolidation

This section documents the consolidation of separate ASDF system files into a single `hemlock.asd`.

## Files Modified

### 1. `/hemlock.asd` (New)
- **Created**: New consolidated ASDF system definition file
- **Contains**: All four system definitions (hemlock/base, hemlock/clx, hemlock/qt, hemlock/tty)
- **Replaced**: The four separate .asd files

### 2. `/build.sh`
- **Changed**: Updated backend system references from `:hemlock.X` to `:hemlock/X` format
- **Line 14**: `backends="$backends :hemlock/$1"` (was `:hemlock.$1`)
- **Default systems**: Already used correct `:hemlock/tty :hemlock/clx` format

### 3. `/ttyhemlock.sh`
- **Changed**: System loading reference
- **Line 3**: `(asdf:operate 'asdf:load-op :hemlock/tty)` (was `:ttyhemlock`)

### 4. `/hemlock.qt.sh`
- **Changed**: System loading reference  
- **Line 3**: `(asdf:operate 'asdf:load-op :hemlock/qt)` (was `:qthemlock`)

### 5. `/INSTALL`
- **Added**: Information about consolidated ASDF structure
- **Enhanced**: Loading instructions with comments for clarity
- **Lines 7-9**: Added note about consolidated system definition

### 6. `/README.md` (New)
- **Created**: Comprehensive documentation of the new structure
- **Contains**: Installation instructions, system descriptions, dependencies

### 7. `/CONSOLIDATION-README.md`
- **Enhanced**: Added section documenting all updated files
- **Added**: Complete change log

## Files Removed
- `hemlock.base.asd`
- `hemlock.clx.asd`
- `hemlock.qt.asd`
- `hemlock.tty.asd`

## Files Not Changed
- Source code files (.lisp) - Package names remain unchanged (e.g., `:hemlock.qt`)
- Documentation files in `/doc/` - No system references found
- `/c/Makefile` - No Lisp system references
- `/dist.sh` - Binary packaging script, no system name dependencies

## System Name Changes Summary

| Old System Name | New System Name | Usage Context |
|----------------|-----------------|---------------|
| `hemlock.base` | `:hemlock/base` | ASDF system |
| `hemlock.clx`  | `:hemlock/clx`  | ASDF system |
| `hemlock.qt`   | `:hemlock/qt`   | ASDF system |
| `hemlock.tty`  | `:hemlock/tty`  | ASDF system |
| `ttyhemlock`   | `:hemlock/tty`  | Legacy alias |
| `qthemlock`    | `:hemlock/qt`   | Legacy alias |

Note: Package names (like `:hemlock.qt`) remain unchanged as they follow different naming conventions.

## Verification

All changes have been tested to ensure:
1. The consolidated `hemlock.asd` loads without errors
2. All four systems are properly defined and findable by ASDF
3. Build scripts use correct system names
4. Loading scripts reference correct systems

## Backward Compatibility

The new structure maintains full functional compatibility. Users need only:
1. Use the new `hemlock.asd` file instead of separate .asd files
2. Reference systems with `/` instead of `.` (e.g., `:hemlock/base` not `hemlock.base`)
3. Update any custom scripts to use the new system names
