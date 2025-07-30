;;; -*- Mode: LISP; Syntax: ANSI-Common-Lisp; Package: HEMLOCK-INTERNALS -*-
;;; Copyright (c) 2025 Symbolics Pte. Ltd. All rights reserved.
;;; SPDX-License-identifier: Unlicense
;;;
;;; Terminal Operations Abstraction for Hemlock TTY Display
;;;
;;; This file provides a centralized, cached abstraction layer for terminal
;;; operations, eliminating repetitive terminfo capability checking patterns
;;; and providing automatic ANSI fallbacks.

(in-package :hemlock-internals)

;;; Terminal operation types
(deftype terminal-operation ()
  '(member :clear-screen :clear-to-eol :clear-to-eos
           :cursor-up :cursor-down :cursor-left :cursor-right
           :cursor-address :insert-line :delete-line
           :enter-standout :exit-standout
           :enter-bold :exit-bold
           :enter-underline :exit-underline
           :enter-italics :exit-italics
           :exit-attributes
           :set-foreground :set-background))

;;; Cache for resolved terminal operations
(defvar *terminal-ops-cache* (make-hash-table :test #'equal))

;;; ANSI escape sequence definitions
(defconstant +ansi-escape+ #\Escape)
(defparameter *ansi-sequences*
  '((:clear-screen . "[2J")
    (:clear-to-eol . "[K")
    (:clear-to-eos . "[J")
    (:cursor-up . "[A")
    (:cursor-down . "[B")
    (:cursor-right . "[C")
    (:cursor-left . "[D")
    (:cursor-address . "[~D;~DH")  ; row;col (1-based)
    (:insert-line . "[L")
    (:delete-line . "[M")
    (:enter-standout . "[7m")
    (:exit-standout . "[27m")
    (:enter-bold . "[1m")
    (:exit-bold . "[22m")
    (:enter-underline . "[4m")
    (:exit-underline . "[24m")
    (:enter-italics . "[3m")
    (:exit-italics . "[23m")
    (:exit-attributes . "[0m")
    (:set-foreground . "[38;5;~Dm")
    (:set-background . "[48;5;~Dm")))

;;; Terminfo capability mapping
(defparameter *terminfo-capability-map*
  '((:clear-screen . :clear-screen)
    (:clear-to-eol . :clr-eol)
    (:clear-to-eos . :clr-eos)
    (:cursor-up . :cursor-up)
    (:cursor-down . :cursor-down)
    (:cursor-right . :cursor-right)
    (:cursor-left . :cursor-left)
    (:cursor-address . :cursor-address)
    (:insert-line . :insert-line)
    (:delete-line . :delete-line)
    (:enter-standout . :enter-standout-mode)
    (:exit-standout . :exit-standout-mode)
    (:enter-bold . :enter-bold-mode)
    (:exit-bold . :exit-bold-mode)
    (:enter-underline . :enter-underline-mode)
    (:exit-underline . :exit-underline-mode)
    (:enter-italics . :enter-italics-mode)
    (:exit-italics . :exit-italics-mode)
    (:exit-attributes . :exit-attribute-mode)
    (:set-foreground . :set-a-foreground)
    (:set-background . :set-a-background)))

(defun make-ansi-sequence (operation &rest args)
  "Create an ANSI escape sequence for OPERATION with ARGS."
  (let ((template (cdr (assoc operation *ansi-sequences*))))
    (when template
      (format nil "~C~?" +ansi-escape+ template args))))

(defun get-terminal-sequence (operation &rest args)
  "Get terminal sequence for OPERATION, using terminfo with ANSI fallback.
   Results are cached for efficiency."
  (let ((cache-key (cons operation args)))
    (or (gethash cache-key *terminal-ops-cache*)
        (setf (gethash cache-key *terminal-ops-cache*)
              (or (terminfo-sequence operation args)
                  (apply #'make-ansi-sequence operation args))))))

(defun terminfo-sequence (operation args)
  "Get terminfo sequence for OPERATION with ARGS."
  (let ((cap-name (cdr (assoc operation *terminfo-capability-map*))))
    (when cap-name
      (let ((capability (terminfo:capability cap-name)))
        (when capability
          (if args
              (terminfo:tputs (apply #'terminfo:tparm capability args))
              (terminfo:tputs capability)))))))

(defun clear-terminal-cache ()
  "Clear the terminal operations cache."
  (clrhash *terminal-ops-cache*))

;;; Core terminal operation executor
(defun execute-terminal-op (operation &rest args)
  "Execute a terminal operation with given arguments."
  (let ((seq (apply #'get-terminal-sequence operation args)))
    (when seq
      (tty-write-cmd seq)
      (force-output)
      t)))

;;; High-level terminal operation functions
(defmacro define-terminal-op (name operation &key args-list parametric)
  "Define a terminal operation function."
  `(defun ,name (,@(when args-list args-list))
     ,(format nil "Execute terminal operation ~S" operation)
     ,(if parametric
          `(execute-terminal-op ,operation ,@args-list)
          `(execute-terminal-op ,operation))))

;; Define all simple terminal operations
(define-terminal-op term-clear-screen :clear-screen)
(define-terminal-op term-clear-to-eol :clear-to-eol)
(define-terminal-op term-clear-to-eos :clear-to-eos)
(define-terminal-op term-cursor-up :cursor-up)
(define-terminal-op term-cursor-down :cursor-down)
(define-terminal-op term-insert-line :insert-line)
(define-terminal-op term-delete-line :delete-line)
(define-terminal-op term-enter-standout :enter-standout)
(define-terminal-op term-exit-standout :exit-standout)
(define-terminal-op term-enter-bold :enter-bold)
(define-terminal-op term-exit-bold :exit-bold)
(define-terminal-op term-enter-underline :enter-underline)
(define-terminal-op term-exit-underline :exit-underline)
(define-terminal-op term-enter-italics :enter-italics)
(define-terminal-op term-exit-italics :exit-italics)
(define-terminal-op term-exit-attributes :exit-attributes)

;; Parametric operations
(define-terminal-op term-set-foreground :set-foreground 
  :args-list (color) :parametric t)
(define-terminal-op term-set-background :set-background 
  :args-list (color) :parametric t)
(define-terminal-op term-cursor-address :cursor-address 
  :args-list (row col) :parametric t)

;;; Attribute management
(defstruct terminal-attributes
  "Current terminal attribute state."
  (foreground nil)
  (background nil)
  (bold nil)
  (italic nil)
  (underline nil)
  (standout nil))

(defvar *current-attributes* (make-terminal-attributes))

(defmacro with-terminal-attributes ((&rest attributes) &body body)
  "Execute BODY with specified terminal attributes."
  `(let ((*current-attributes* (copy-terminal-attributes *current-attributes*)))
     (unwind-protect
         (progn
           (apply-terminal-attributes ,@attributes)
           ,@body)
       (term-exit-attributes))))

(defun apply-terminal-attributes (&key fg bg bold italic underline standout)
  "Apply terminal attributes efficiently."
  (when (and fg (not (eql fg (terminal-attributes-foreground *current-attributes*))))
    (term-set-foreground fg)
    (setf (terminal-attributes-foreground *current-attributes*) fg))
  (when (and bg (not (eql bg (terminal-attributes-background *current-attributes*))))
    (term-set-background bg)
    (setf (terminal-attributes-background *current-attributes*) bg))
  (when (and bold (not (terminal-attributes-bold *current-attributes*)))
    (term-enter-bold)
    (setf (terminal-attributes-bold *current-attributes*) bold))
  (when (and italic (not (terminal-attributes-italic *current-attributes*)))
    (term-enter-italics)
    (setf (terminal-attributes-italic *current-attributes*) italic))
  (when (and underline (not (terminal-attributes-underline *current-attributes*)))
    (term-enter-underline)
    (setf (terminal-attributes-underline *current-attributes*) underline))
  (when (and standout (not (terminal-attributes-standout *current-attributes*)))
    (term-enter-standout)
    (setf (terminal-attributes-standout *current-attributes*) standout)))

;;; Compatibility functions - these replace the existing functions in tty-display.lisp
(defun setaf (color)
  "Set foreground color (legacy compatibility function)."
  (term-set-foreground color))

(defun setab (color)
  "Set background color (legacy compatibility function)."
  (term-set-background color))

(defun enter-bold-mode ()
  "Enter bold mode (legacy compatibility function)."
  (term-enter-bold))

(defun enter-italics-mode ()
  "Enter italics mode (legacy compatibility function)."
  (term-enter-italics))

(defun enter-underline-mode ()
  "Enter underline mode (legacy compatibility function)."
  (term-enter-underline))

(defun exit-attribute-mode ()
  "Exit all attribute modes (legacy compatibility function)."
  (term-exit-attributes))
