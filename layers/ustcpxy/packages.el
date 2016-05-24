;;; packages.el --- ustcpxy layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Derek Pan <derek@SZX-W-DEREKP.advaoptical.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `ustcpxy-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `ustcpxy/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `ustcpxy/pre-init-PACKAGE' and/or
;;   `ustcpxy/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:

(defconst ustcpxy-packages
  '(
    company
    helm
    (org :location built-in)
    )
  "The list of Lisp packages required by the ustcpxy layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun ustcpxy/post-init-company ()
  (use-package company
    :init
    (progn
      (setq company-show-numbers t)
      )))

(defun ustcpxy/post-init-helm ()
  (use-package helm
    :init
    (progn
      (spacemacs/set-leader-keys
        "ff"  'helm-for-files)
      )))

(defun ustcpxy/post-init-org ()
  (with-eval-after-load 'org
    (progn
      ;; refer to http://doc.norang.ca/org-mode.html
      (setq org-todo-keywords
            (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                    (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

      (setq org-use-fast-todo-selection t)
      (setq org-treat-S-cursor-todo-selection-as-state-change nil)

      (setq org-todo-state-tags-triggers
            (quote (("CANCELLED" ("CANCELLED" . t))
                    ("WAITING" ("WAITING" . t))
                    ("HOLD" ("WAITING") ("HOLD" . t))
                    (done ("WAITING") ("HOLD"))
                    ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
                    ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
                    ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

      (add-to-list 'org-modules 'org-habit)

      ;; Capture and Agenda
      (setq org-directory "~/gtd/")
      (setq org-capture-templates
            (quote (("t" "Todo" entry (file+headline (concat org-directory "gtd.org") "Tasks")
                    "* TODO %?\n%U\n%i\n"
                    :empty-lines 1)
                    ("n" "Notes" entry (file+headline org-default-notes-file "Quick notes")
                     "* %?\n  %i\n %U"
                     :empty-lines 1)
                    ("b" "Blog Ideas" entry (file+headline org-default-notes-file "Blog Ideas")
                     "* TODO %?\n  %i\n %U"
                     :empty-lines 1)
                    ("s" "Code Snippet" entry (file (concat org-directory "snippets.org"))
                     "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC")
                    ("w" "work" entry (file+headline (concat org-directory "gtd.org") "GE11X")
                     "* TODO %?\n  %i\n %U"
                     :empty-lines 1)
                    ("l" "org-protocol" entry (file (concat org-directory "notes.org"))
                     "* TODO Review %c\n%U\n" :immediate-finish t)
                    ("j" "Journal Entry" entry (file+datetree (concat org-directory "journal.org"))
                     "* %?"
                     :empty-lines 1)
                    ("h" "Habit" entry (file (concat org-directory "gtd.org"))
                     "* NEXT %?\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n%U\n%a\n"))))

      (setq org-agenda-files (quote ("~/gtd")))
      ;; refile target
      (setq personal-note-files (quote ("~/notebook")))
      (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                       (personal-note-files :maxlevel . 9)
                                       ("~/notebook/adva.org" :maxlevel . 9)
                                       (org-agenda-files :maxlevel . 9))))

      ;; Use full outline paths for refile targets - we file directly with IDO
      (setq org-refile-use-outline-path t)

      ;; Targets complete directly with IDO
      (setq org-outline-path-complete-in-steps nil)

      ;; Allow refile to create parent tasks with confirmation
      (setq org-refile-allow-creating-parent-nodes (quote confirm))

      ;; Use IDO for both buffer and file completion and ido-everywhere to t
      (setq org-completion-use-ido t)
      (setq ido-everywhere t)
      (setq ido-max-directory-size 100000)
      (ido-mode (quote both))
      ;; Use the current window when visiting files and buffers with ido
      (setq ido-default-file-method 'selected-window)
      (setq ido-default-buffer-method 'selected-window)
      ;; Use the current window for indirect buffer display
      (setq org-indirect-buffer-display 'current-window)

      ;; Exclude DONE state tasks from refile targets
      (defun bh/verify-refile-target ()
        "Exclude todo keywords with a done state from refile targets"
        (not (member (nth 2 (org-heading-components)) org-done-keywords)))

      (setq org-refile-target-verify-function 'bh/verify-refile-target)
      )))


;;; packages.el ends here
