(defvar *response* nil)

(defmethod rpm-window-key-event-handler ((win rpm-window) key)
   (setf *response* (string key))
   (clear-exp-window)
   (proc-display)) 

(defun random-element (lis)
   (let* ((len (length lis)))
      (nth (random len) lis)
   )
)
;; define discrimination task
(defun do-scan-search-monitor (&optional who)
  
   (reset)
  
   (let* ((lis (permute-list '("A" "B" "C" "D" "F" "G" "H")))
          (len (length lis))
          (letters)
          ;(text1 (first lis))
          ;; simple scanning:
          ;; continully scan through images and compare against target image
          ;; TODO make images more complicated?

          (window (open-exp-window "Visual Scan/Search/Monitor")))

      ;; create text items in window and get letters back
      (setf letters (maplist #'(lambda (letters)
                     (add-text-to-exp-window :text (car letters)
                                             :x (+ 150
                                                   (* 15
                                                      (- len (length letters))))
                                             :y 150)
                     ) lis
                    )
      )
      ;;(add-text-to-exp-window :text text1 :x 100 :y 150)
    
      (setf *response* nil)
      (install-device window)
      (proc-display)

      ;; form taken from VisualTrackFollow.lisp
      (schedule-periodic-event .5 #'(lambda ()
                                       ;; assign a new random letter from the list to a random
                                       ;; entry on the screen
                                       (setf (dialog-item-text (random-element letters)) (random-element lis))
                                       ;(print (dialog-item-text (car letters)))
                                       (proc-display)
                                    )
                                 :details "moving letter"
                                 :initial-delay 1.0
      )
      (run 3))
      
)



(clear-all)
;; define discrimination behavior
(define-model visual-scan-search-monitor

(sgp :seed (123456 0))
(sgp :v t :needs-mouse nil :show-focus t :trace-detail high)

;; TODO should we retrieve the target letter like in inspect-check?
(chunk-type scan-search-monitor state letter)
;; chunk representing an image we are checking
(chunk-type image letter)
;; chunk to performa a comparison in imaginary
;;(chunk-type comparison letter1 letter2 choice)

(add-dm
   (start isa chunk) (attend isa chunk)
   (respond isa chunk) (done isa chunk)
   (goal isa scan-search-monitor state start letter "A"))

;; find the location of leftmost image right of current focus
(P find-image
   =goal>
      ISA         scan-search-monitor
      state       start
 ==>
   +visual-location>
      ISA         visual-location
    > screen-x    current
      screen-x    lowest
   =goal>
      state       attend-image
)
;; find location of leftmost image overall if none more to the right
(P find-image-left
   =goal>
      ISA         scan-search-monitor
      state       attend-image
   ?visual-location>
      state       error
==>
   +visual-location>
      ISA         visual-location
      screen-x    lowest
   =goal>
      state       attend-image
)

;; turn attention to the letter
(P attend-image
   =goal>
      ISA         scan-search-monitor
      state       attend-image
   =visual-location>
      ISA         visual-location
   
   ?visual>
      state       free
   
==>
   +visual>
      ISA         move-attention
      screen-pos  =visual-location
   =goal>
      state       compare-image
)

;; compare image to target (equal)
(P compare-image-same
   =goal>
      ISA         scan-search-monitor
      state       compare-image
      letter      =target
   =visual>
      ISA         visual-object
      value       =target
==>
   =goal>
      ;; repeat
      state       start
   !output!       "target"
)
;; compare image to target (non-equal)
(P compare-image-different
   =goal>
      ISA         scan-search-monitor
      state       compare-image
      letter      =target
   =visual>
      ISA         visual-object
      value       =val
    - value       =target
==>
   =goal>
      ;; repeat
      state       start
   !output!       (=val " is not " =target)
)

(goal-focus goal)

)
