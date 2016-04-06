(in-package #:prometheus.test)

(plan 1)

(defmacro error-class-exists (name &optional (base 'prom:base-error))
  (let ((class-exists-msg (format nil "~s class exists" name))
        (class-is-base-msg (format nil "~s is ~s" name base))
        (no-class-msg (format nil "No ~s class" name)))
    `(subtest "Error existence check"
       (let ((error-class (find-class ',name nil)))
         (if error-class
             (progn
               (pass ,class-exists-msg)
               (is (subtypep error-class ',base) t ,class-is-base-msg))
             (fail ,no-class-msg))))))

(defmacro error-report-test (class &rest tests)
  `(subtest "Error report test(s)"
     ,@(loop for (args result) in tests
             collect `(is
                       (handler-case
                           (error ',class ,@args)
                         (,class (e) (princ-to-string e)))
                       ,result
                       ,(format nil "~s reported as ~s"
                                `(error ',class ,@args)
                                result)))))
(subtest "Errors"

  (subtest "Base Error"
    (error-class-exists prom:base-error error))

  (subtest "Invalid Label Name Error"
    (error-class-exists prom:invalid-label-name-error)

    (error-report-test prom:invalid-label-name-error ((:name 123 :reason "label name is not a string")
                                                      "Label name 123 is invalid. Reason: label name is not a string")))


  (subtest "Invalid Label Value Error"
    (error-class-exists prom:invalid-label-value-error)

    (error-report-test prom:invalid-label-value-error ((:value 123 :reason "label value is not a string")
                                                       "Label value 123 is invalid. Reason: label value is not a string")))

  (subtest "Invalid Metric Name Error"
    (error-class-exists prom:invalid-metric-name-error)

    (error-report-test prom:invalid-metric-name-error ((:name 123 :reason "metric name is not a string")
                                                       "Metric name 123 is invalid. Reason: metric name is not a string"))))

(finalize)