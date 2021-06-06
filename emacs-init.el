(setq gc-cons-threshold (* 50 1000 1000)) ;; Measured in bytes. The default is 800 kilobytes.

;;(debug-on-entry 'quelpa-build-checkout)

;; ;; Turn on automatically for text-mode.
;; (defun bidi-display-reordering-on ()
;;   "Sets bidi-display-reordering-on"
;;   (setq-local bidi-display-reordering t))

;; (add-hook 'text-mode-hook 'bidi-display-reordering-on)

;; ;; Toggle paragraph direction
;; (setq-default bidi-paragraph-direction 'left-to-right)

;; (defun bidi-direction-toggle ()
;;   "Will switch the explicit direction of text for current
;;    buffer. This will set BIDI-DISPLAY-REORDERING to T"
;;   (interactive "")
;;   (setq bidi-display-reordering t)
;;   (if (equal bidi-paragraph-direction 'right-to-left)
;;     (setq bidi-paragraph-direction 'left-to-right)
;;     (setq bidi-paragraph-direction 'right-to-left))
;;   (message "%s" bidi-paragraph-direction))

(defun me/install-if-not-installed (package-name)
  "Installs a package unless it's installed"
  (unless (package-installed-p package-name)
    (package-install package-name)))

(defun me/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun me/exwm-update-title ()
  (pcase exwm-class-name
    ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))
    ("Chromium" (exwm-workspace-rename-buffer (format "Chromium: %s" exwm-title)))))

(require 'package)
(setq package-archives '(("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")
			 ("melpa" . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; installing use-package
(me/install-if-not-installed 'use-package)
(require 'use-package)

(defun me/org-mode-setup ()
  (org-indent-mode))

;; org
(use-package org
  :hook (org-mode . me/org-mode-setup)
  :config
  (setq org-ellipsis " ▼")
  
  ;; Indent headings and text
  (require 'org-indent)
  (setq org-startup-indented t)

  ;; Colors for todo states
  (setq org-todo-keyword-faces '(("TODO" . "orange") ("DONE" . "olive")))

  ;; Priority faces
  (setq org-priority-faces
	'((65 . "red")
        (66 . "orange")
        (67 . "yellow"))))

;; org-bullets
(me/install-if-not-installed 'org-bullets)
(use-package org-bullets
  :ensure t
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom (org-bullets-bullet-list '("◉" "○" "●" "○" "●")))
  
;; Activate agenda
(global-set-key (kbd "C-c a") 'org-agenda)

;; Restore layout after exit from agenda view
(setq org-agenda-restore-windows-after-quit t)

;; Include these files and directories when creating the agenda
(setq org-agenda-files '("~/org"))

;; Don't show tasks in agenda if they are done
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)

;; Agenda starts on the current day
(setq org-agenda-start-on-weekday nil)

;; Start fullscreen
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

;; Remove startup screen
(setq inhibit-startup-message t)

;; Empty scratch
(setq initial-scratch-message nil)

;; S-C-Tab is not working by default
;; see "https://emacs.stackexchange.com/questions/53461/specifying-a-binding-for-control-shift-tab"
(define-key function-key-map [(control shift iso-lefttab)] [(control shift tab)])

;; Disabling menu-bar, tool-bar, tooltips and scroll-bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(scroll-bar-mode -1)

;; Zero left padding
(fringe-mode 1)

;; Ignore bell
(setq ring-bell-function 'ignore)

;; Set utf-8 encoding
(setq locale-coding-system 'utf-8)
(setq terminal-coding-system 'utf-8)
(setq keyboard-coding-system 'utf-8)
(setq selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; Disable backups and auto-saves
(setq make-backup-files nil)
(setq auto-save-default nil)

;; Change yes-or-no questions into y-or-n questions
(defalias 'yes-or-no-p 'y-or-n-p)

;; Load large files without asking. e.g. pdf files
(setq large-file-warning-threshold nil)

;; skipping first message about eshell
(setenv "PAGER" "cat")
(add-hook 'eshell-mode-hook
	  (lambda ()
          (setq unread-command-events (listify-key-sequence "\a")))) ;; \a is for alert, a non representable char
(add-hook 'eshell-load-hook
	  (lambda ()
          (setq unread-command-events (listify-key-sequence "\a")))) ;; \a is for alert, a non representable char

(me/install-if-not-installed 'exwm)
(use-package exwm
  :ensure t
  :config ;;    (exwm-debug)

  (add-hook 'exwm-update-class-hook #'me/exwm-update-class)
  (add-hook 'exwm-update-title-hook #'me/exwm-update-title)

  ;; Input methods
  (setq default-input-method "hebrew-full")
  (add-hook 'input-method-activate-hook '(lambda ()
                                           (interactive)
                                           (setq current-input-method-title "IL ")))

  ;; Highlight parenthesis
  (show-paren-mode)

  ;; Ctrl+Q will enable the next key to be sent directly
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; These keys should always pass through to Emacs
  (setq exwm-input-prefix-keys
        '(?\C-x
          ?\C-u
          ?\C-h
          ?\M-x
          ?\M-`
          ?\M-&
          ?\M-:
          ?\C-\\))

 (setq exwm-input-global-keys
       `(
         ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
         ([?\s-r] . exwm-reset)

          ;; Launch applications via shell commands
          ([?\s-&] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))

          ;; Move between windows
          ([s-left] . windmove-left)
          ([s-right] . windmove-right)
          ([s-up] . windmove-up)
          ([s-down] . windmove-down)))

  ;; Simulation keys to mimic the behavior of Emacs.
  (setq exwm-input-simulation-keys
        '(
          ;; movement
          ([?\C-b] . [left])
          ([?\C-f] . [right])
          ([?\M-b] . [C-left])
          ([?\M-f] . [C-right])
          ([?\C-p] . [up])
          ([?\C-n] . [down])
          ([?\C-a] . [home])
          ([?\C-e] . [end])
          ([?\M-v] . [prior])
          ([?\C-v] . [next])
          ([?\C-d] . [delete])
          ([?\C-k] . [S-end delete])
          ;; cut/paste
          ([?\C-w] . [?\C-x])
          ([?\M-w] . [?\C-c])
          ([?\C-y] . [?\C-v])
          ;; search
          ([?\C-s] . [?\C-f])))
  (require 'exwm-xim)
  (exwm-xim-enable)
  (exwm-enable))

(me/install-if-not-installed 'zenburn-theme)
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t))

;; Set scratch as new tab default
(setq tab-bar-new-tab-choice "*scratch*")
(set-face-attribute
  'tab-bar nil
  :background "gray30"
  ;;:foreground "purple"
  :underline nil
  :box '(:line-width 5 :color "gray30" :style nil))
(set-face-attribute
  'tab-bar-tab nil
  :background "gray30"
  :foreground "DeepPink3"
  :underline nil
  :box '(:line-width 5 :color "gray30" :style nil))
(set-face-attribute
  'tab-bar-tab-inactive nil
  :background "gray30"
  :foreground "purple"
  :underline nil
  :box '(:line-width 5 :color "gray30" :style nil))
;; (tab-bar-mode)

(setq-default custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

(defun my/org-babel-tangle ()
  (when (member
          (buffer-file-name)
          (list (expand-file-name "~/workspace/repos/misc/linear-algebra/summary.org") ;; TODO: Find a new place.
                (expand-file-name "~/.dotfiles/emacs-init.org")))
    ;; Dynamic scoping to the rescue
        (let ((org-confirm-babel-evaluate nil))
          (org-babel-tangle))
    ;; Update html buffer if exists for impatient-mode
          (when (string-equal (buffer-name) "summary.org")
            (let ((summary-html-buffer (get-buffer "summary.html")))
              (when summary-html-buffer
                (with-current-buffer summary-html-buffer
                  (revert-buffer t t t)))))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'my/org-babel-tangle)))

(me/install-if-not-installed 'auctex)
(use-package auctex
  :defer t
  :ensure t)

(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("org-plain-latex"
                 "\\documentclass{book} [NO-DEFAULT-PACKAGES] [PACKAGES] [EXTRA]"
                 ("\\chapter{%s}" . "\\chapter*{%s}")
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
(setq org-latex-with-hyperref nil)
