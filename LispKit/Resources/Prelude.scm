;;; Default Prelude for LispKit
;;; 
;;; Author: Matthias Zenger
;;; Copyright © 2017 Matthias Zenger. All rights reserved.
;;;
;;; Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
;;; except in compliance with the License. You may obtain a copy of the License at
;;;
;;;   http://www.apache.org/licenses/LICENSE-2.0
;;;
;;; Unless required by applicable law or agreed to in writing, software distributed under the
;;; License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
;;; either express or implied. See the License for the specific language governing permissions
;;; and limitations under the License.

(define-syntax for
  (syntax-rules (in from)
    ((for element in list body ...) (map (lambda (element) body ...) list))
    ((for element from (x ...) body ...) (map (lambda (element) body ...) (list x ...)))))

(define-syntax while
  (syntax-rules ()
    ((while condition body ...)
       (let loop ()
         (if condition (begin body ... (loop)) #f)))))

(define-syntax unless
  (syntax-rules ()
    ((unless pred body ...)
       (if (not pred) (begin body ...)))))

(define-syntax when
  (syntax-rules ()
    ((when pred body ...)
       (if pred (begin body ...)))))


;;; Scratch (for testing)

(define (fib n) (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2)))))
(define (fxfib n) (if (fx< n 2) n (fx+ (fxfib (fx- n 1)) (fxfib (fx- n 2)))))
