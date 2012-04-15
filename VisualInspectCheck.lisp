(defvar *response* nil)

(defmethod rpm-window-key-event-handler ((win rpm-window) key)
   (setf *response* (string key))
   (clear-exp-window)
   (proc-display)) 

;; define discrimination task
(defun do-inspect-check (&optional who)
  
   (reset)
  
   (let* ((lis (permute-list '("B" "C" "D" "F" "G" "H" 
                               "J" "K" "L" "M" "N" "P" 
                               "Q" "R" "S" "T" "V" "W" 
                               "X" "Y" "Z")))
          ;(text1 (first lis))
          ;; simple inspection:
          ;; determine if a letter is a specific letter
          ;; TODO make images more complicated?
          (text1 "A")
          (window (open-exp-window "Visual Inspect/Check")))
    
      (add-text-to-exp-window :text text1 :x 100 :y 150)
    
      (setf *response* nil)
      (install-device window)
      (proc-display)
          
      (if (not (eq who 'human))
          (run 10 :real-time t)
      
      (while (null *response*)
         (allow-event-manager window)))
    
    *response*))



(clear-all)
;; define discrimination behavior
(define-model visual-inspect-check

(sgp :seed (123456 0))
(sgp :v t :needs-mouse nil :show-focus t :trace-detail high)

(chunk-type inspect-check state)
;; chunk representing an image we are checking
(chunk-type image letter)
;; chunk to performa a comparison in imaginary
(chunk-type comparison letter1 letter2 choice)

(add-dm
   (image isa image letter "A")
   (start isa chunk) (attend isa chunk)
   (respond isa chunk) (done isa chunk)
   (goal isa inspect-check state start))

;; find the location of the image
(P find-first-image
   =goal>
      ISA         inspect-check
      state       start
 ==>
   +visual-location>
      ISA         visual-location
      :attended    nil
   =goal>
      state       attend-image
)

;; turn attention to the letter
(P attend-image
   =goal>
      ISA         inspect-check
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
      state       register-image
)

;; store info about the first image temporarily
(P register-image
   =goal>
      ISA         inspect-check
      state       register-image
   =visual>
      ISA         text
      value       =letter
==>
   =goal>
      state       recall-image
   +imaginal>
      isa         comparison
      letter1     =letter
)

(P recall-image
   =goal>
      ISA         inspect-check
      state       recall-image
==>
   +retrieval>
      ISA         image
   =goal>
      state       check-image
)

(P check-image
   =goal>
      ISA         inspect-check
      state       check-image
   =retrieval>
      ISA         image
      letter      =letter
   =imaginal>
      ISA         comparison
      letter1     =letter
==>
   =goal>
      state       done
   +imaginal>
      ISA         comparison
      letter1     =letter
      letter2     =letter
      choice      "passed"
   !output!       "passed"
)

;; TODO should be be storing the result in imaginal first, then doing choice in the next one?

(goal-focus goal)

)
