(ert-deftest test-yapfify-buffers ()
  "Test that yapfiffy reformats a buffer using the settings in .style.yapf"
  (let* ((datadir (getenv "DATA_DIR"))
         (unformatted (f-join datadir "unformatted.py"))
         (formatted (f-join datadir "formatted.py")))
    (find-file unformatted)
    ;; When yapf is called on the unformatted buffer, yapf should exit with status code 1.
    (should (eq (call-process-region (point-min) (point-max) "diff"  nil nil nil formatted "-") 1))
    (yapfify-buffer)
    ;; After yapfify-buffer is used, yapf should exit with exit code 0.
    (should (eq (call-process-region (point-min) (point-max) "diff"  nil nil nil formatted "-") 0))
    )
  )
