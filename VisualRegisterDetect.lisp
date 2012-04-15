(defvar *response* nil)

(defmethod rpm-window-key-event-handler ((win rpm-window) key)
  (setf *response* (string key))
  (clear-exp-window)
  (proc-display)) 

(defun do-reg-detect (&optional who)
  
  (reset)
  
  (let* ((lis (permute-list '("B" "C" "D" "F" "G" "H" 
                              "J" "K" "L" "M" "N" "P" 
                              "Q" "R" "S" "T" "V" "W" 
                              "X" "Y" "Z")))
         (text1 (first lis))
         (window (open-exp-window "Visual Register/Detect")))
    
    (add-text-to-exp-window :text text1 :x 125 :y 150)
    
    (setf *response* nil)
    (install-device window)
    (proc-display)
          
    (if (not (eq who 'human))
        (run 10 :real-time t)
      
      (while (null *response*)
        (allow-event-manager window)))
    
    *response*))



(clear-all)

(define-model visual-register-detect

(sgp :seed (123456 0))
(sgp :v t :needs-mouse nil :show-focus t :trace-detail high)

(chunk-type detect-image state)
(chunk-type array letter)

(add-dm 
 (start isa chunk) (attend isa chunk)
 (respond isa chunk) (done isa chunk)
 (goal isa detect-image state start))

(P find-unattended-image
   =goal>
      ISA         detect-image
      state       start
 ==>
   +visual-location>
      ISA         visual-location
      :attended    nil
   =goal>
      state       find-location
)

(P attend-letter
   =goal>
      ISA         detect-image
      state       find-location
   =visual-location>
      ISA         visual-location
   
   ?visual>
      state       free
   
==>
   +visual>
      ISA         move-attention
      screen-pos  =visual-location
   =goal>
      state       attend
)

(P register-image
   =goal>
      ISA         detect-image
      state       attend
   =visual>
      ISA         text
      value       =letter
==>
   =goal>
      state       done
   +imaginal>
      isa         array
      letter      =letter
)


;(P respond
;   =goal>
;      ISA         detect-image
;      state       respond
;   =imaginal>
;      isa         array
;      letter      =letter
;   ?manual>   
;      state       free
;==>
;   =goal>
;      state       done
;   +manual>
;      ISA         press-key
;      key         =letter
;)

(goal-focus goal)

)
