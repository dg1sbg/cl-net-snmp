;;;; -*- Mode: Lisp -*-
;;;; $Id: parser.lisp 806 2010-07-10 13:44:57Z binghe $

(in-package :asn.1)

#+asn.1-features:parsergen
(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "parsergen"))

#+asn.1-features:parsergen
(macrolet ((define-parser (name syntax)
             `(parsergen:defparser ,name ,@syntax)))
  (define-parser asn.1-parser #.*asn.1-syntax*))

#+asn.1-features:cl-yacc
(macrolet ((define-parser (name reserved-words start-symbol syntax)
             `(snmp.yacc:define-parser ,name
                (:terminals ,reserved-words)
                (:start-symbol ,start-symbol)
                ,@syntax)))
  (define-parser *asn.1-parser*
                 #.(list* :id :number :string *reserved-words*)
                 %module-definition
                 #.(defparser-to-yacc *asn.1-syntax*)))

(defun asn.1-lexer (stream)
  (let ((*readtable* *asn.1-readtable*)
        (*package* (find-package :asn.1)))
    (let ((token (read stream nil nil nil)))
      (when token
        (values (detect-token token) token)))))

(defgeneric detect-token (token))

(defmethod detect-token ((token number))
  :number)

(defmethod detect-token ((token symbol))
  (gethash token *reserved-words-table* :id))

(defmethod detect-token ((token string))
  :string)

(defgeneric parse (source))

(defmethod parse ((source string))
  (with-input-from-string (s source)
    (parse s)))

(defmethod parse ((source pathname))
  (with-open-file (s source :direction :input)
    (parse s)))

(defmethod parse ((source stream))
  #+asn.1-features:parsergen
  (asn.1-parser #'(lambda () (asn.1-lexer source)))
  #+asn.1-features:cl-yacc
  (snmp.yacc:parse-with-lexer #'(lambda () (asn.1-lexer source))
                              *asn.1-parser*))

(defmethod parse ((source t))
  (error "Unknown Parser Source"))