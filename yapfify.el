;;; yapfify.el --- (automatically) format python buffers using YAPF.

;; Copyright (C) 2016 Joris Engbers

;; Author: Joris Engbers <info@jorisengbers.nl>
;; Homepage: https://github.com/JorisE/yapfify
;; Version: 0.0.1
;; Package-Requires: ()

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Yapfify uses yapf to format a Python buffer. It can be called explicitly on a
;; certain buffer, but more conveniently it can be used to automatically format
;; a buffer before saving it.
;;
;; Because YAPF will sometimes do things to your code, you may not agree with, a
;; toggle is provided to easily turn it of.
;;
;; Installation:
;;
;; Add yapfify.el to your load-path.
;;
;; To automatically format all Python buffers before saving, add the function
;; yapfify-buffer to python-mode-hook:
;;
;; (add-hook 'python-mode-hook yapfify-format-buffer)
;;
;;; Code:

(defun call-yapf-bin (input-buffer output-buffer)
  "Call process yapf on INPUT-BUFFER saving the output to OUTPUT-BUFFER and
return the exit code."
  (with-current-buffer input-buffer
    (call-process-region (point-min) (point-max) "yapf" nil output-buffer)))

;;;###autoload
(defun yapfify-buffer ()
  "Try to yapfify the current buffer. If yapf exits with an error, the output
will be shown in a help-window."
  (interactive)
  (let* ((file (buffer-file-name))
         (original-buffer (current-buffer))
         (original-point (point))  ; Because we are replacing text, save-excursion does not always work.
         (tmpbuf (get-buffer-create "Yapf output"))
         (exit-code (call-yapf-bin original-buffer tmpbuf)))

    ;; There are three exit-codes defined for yapf:
    ;; 0: Exit with no change
    ;; 1: Exit with error
    ;; 2: Exit with changes to files
    ;; anything else would be very unexpected.
    (cond ((eq exit-code 0))

          ((eq exit-code 2)
             (with-current-buffer tmpbuf
               (copy-to-buffer original-buffer (point-min) (point-max)))
             (goto-char original-point))

          ((eq exit-code 1)
           (with-help-window "*Yapf errors*"
             ;; Wow, isn't this weird. There is apparently no function that
             ;; evauates body in the freshly created buffer, so you always
             ;; have to do `with-current-buffer` on the buffer you just
             ;; created.
             (with-current-buffer "*Yapf errors*"
               (insert
                (format "Yapf failed with the following error(s): \n\n%s"
                        (with-current-buffer tmpbuf
                          (buffer-string))))))))

                                        ; Clean up tmpbuf
    (kill-buffer tmpbuf)))

(defun yapfify-enable-on-save ()
  "Add this hook to python-mode to enable yapfifying before saving."
  (add-hook 'before-save-hook 'yapfify-buffer nil t))

(defun toggle-yapfify-enable-on-save ()
  "If yapfify-enable-on-save is currently one of the before-save-hooks disable
it and vice versa."
  (interactive)

  (if (member 'yapfify-enable-on-save python-mode-hook)
      (progn (remove-hook 'python-mode-hook 'yapfify-enable-on-save)
             (remove-hook 'before-save-hook 'yapfify-buffer t)
             (message "yapfify-buffer on save disabled."))
    (progn
      (add-hook 'python-mode-hook 'yapfify-enable-on-save)
      (add-hook 'before-save-hook 'yapfify-buffer nil t)
      (message "yapfify-buffer on save enabled."))))

(provide 'yapfify)

;;; yapfify.el ends here
