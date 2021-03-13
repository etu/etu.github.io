;;; publish.el --- Build and Org blog -*- lexical-binding: t -*-

;; Copyright (C) 2019 Elis Hirwing <elis@hirwing.se>

;; Author: Elis Hirwing <elis@hirwing.se>
;; Maintainer: Elis Hirwing <elis@hirwing.se>
;; URL: https://github.com/etu/etu.github.io
;; Version: 0.0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: hypermedia, blog, feed, rss

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Inspired by https://gitlab.com/ambrevar/ambrevar.gitlab.io/tree/master

;;; Code:

;; Org publish
(require 'ox-publish)

;; RSS feeds
(require 'webfeeder)

;; Highlighting of languages
(require 'htmlize)
(require 'go-mode)
(require 'nix-mode)
(require 'php-mode)



(defun etu/preamble (info)
  "Return preamble as a string.  Dunno what INFO does."
  "<nav>
     <ul>
       <li><a href=\"/\">~elis/</a></li>
       <li><a href=\"/about/\">./about/</a></li>
       <li><a href=\"/work/\">./work/</a></li>
       <li><a href=\"/talks/\">./talks/</a></li>
       <li><a href=\"/blog/\">./blog/</a></li>
     </ul>
   </nav>")

(defun etu/org-publish-blog-entry (entry style project)
  "Custom format for site map ENTRY, as a string.
See `org-publish-sitemap-default-entry'."
  (cond ((not (directory-name-p entry))
         (format "[[file:%s][%s]] (Date: %s)"
                 entry
                 (org-publish-find-title entry project)
                 (format-time-string "<%Y-%m-%d %a %H:%M>" (org-publish-find-date entry project))))
        ((eq style 'tree)
         ;; Return only last subdir.
         (capitalize (file-name-nondirectory (directory-file-name entry))))
        (t entry)))

(defun etu/org-publish-blog-index (title list)
  "My blog index generator, takes TITLE and LIST of files to make to a string."
  (let ((filtered-list '()))
    ;; Loop through all list items
    (dolist (item list)
      (unless (eq item 'unordered)
        (let ((file (car item)))
          ;; Remove index and non blog posts
          (unless (or (string-match "file:index.org" file)
                      (string-match "file:about/index.org" file)
                      (string-match "file:drafts/" file)
                      (string-match "file:talks/index.org" file)
                      (string-match "file:work/index.org" file))

            (let ((dir (replace-regexp-in-string "index.org" "" file)))
              ;; Rewrite file: to file:../
              (push (list (replace-regexp-in-string "file:" "file:../" dir))
                    filtered-list))))))

    ;; Fix up the list before sending it to `org-list-to-org'.
    (let ((fixed-list (cons 'unordered filtered-list)))
      ;; Build string
      (concat "#+SETUPFILE: ../../org-templates/level-1.org\n"
              "#+TITLE: ~elis/" title "/\n"
              "\n\n"
              (org-list-to-org fixed-list)))))

(defun etu/org-html-publish-to-html (plist filename pub-dir)
  "Same as `org-html-publish-to-html' but modifies html before finishing."
  ;; Publish using the original function
  (let ((file-path (org-html-publish-to-html plist filename pub-dir)))
    ;; Open the published file
    (with-current-buffer (find-file-noselect file-path)
      (goto-char (point-min))

      ;; Find contents of page
      (search-forward "<div id=\"content\">")

      ;; Replace away build environment path to have a web root relative path
      ;; Also store where the content div is so we can back up there easily.
      (let ((relative-path (replace-regexp-in-string ".+/public" "" default-directory))
            (content-point (point)))

        ;; Replace locally relative clickable links
        (while (search-forward "href=\"." nil t)
          (replace-match (concat "href=\"" relative-path ".")))

        ;; Go to content
        (goto-char content-point)

        ;; Replace locally relative image paths
        (while (search-forward "src=\"." nil t)
          (replace-match (concat "src=\"" relative-path ".")))

        ;; Go to content
        (goto-char content-point)

        ;; Replace anchor links
        (while (search-forward "href=\"#" nil t)
          (replace-match (concat "href=\"" relative-path "#"))))

      (save-buffer)
      (kill-buffer))

    ;; Return file path for publishing
    file-path))



;; Configure org to not put timestamps in the home directory since that breaks
;; nix-build of the project due to sandboxing.
(setq org-publish-timestamp-directory "./.org-timestamps/")

;; Disable the validation links in the footers.
(setq org-html-validation-link nil)

;; Don't inline the css for the color highlight in the output
(setq org-html-htmlize-output-type "css")

;; Use custom preamble to create my menu
(setq org-html-preamble #'etu/preamble)

;; Define org projects
(setq org-publish-project-alist
      '(("site-org"
         :base-directory "./src/"
         :base-extension "org"
         :publishing-directory "./public/"
         :recursive t
         :publishing-function etu/org-html-publish-to-html
         :headline-levels 4
         :auto-preamble t

         ;; Blog Index
         :auto-sitemap t
         :sitemap-format-entry etu/org-publish-blog-entry
         :sitemap-title "blog"
         :sitemap-filename "blog/index.org"
         :sitemap-file-entry-format "%d *%t*"
         :sitemap-style list
         :sitemap-function etu/org-publish-blog-index
         :sitemap-sort-files chronologically)

        ("site-static"
         :base-directory "./src/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|asc"
         :publishing-directory "./public/"
         :publishing-function org-publish-attachment
         :recursive t)

        ("site" :components ("site-org" "site-static"))))



;; Publish projects
(org-publish "site")

;; Generate RSS feed
(webfeeder-build "blog/rss.xml"
                 "./public/"
                 "https://elis.nu/"
                 (delete "blog/index.html"
                         (mapcar (lambda (f) (replace-regexp-in-string "public/" "" f))
                                 (directory-files-recursively "public/blog/" "index.html")))
                 :builder 'webfeeder-make-rss
                 :title "~elis/blog/"
                 :description "I may sometime write about things.")



(provide 'publish)
;;; publish.el ends here
