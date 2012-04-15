(defvar *response* nil)

(defmethod rpm-window-key-event-handler ((win rpm-window) key)
   (setf *response* (string key))
   (clear-exp-window)
   (proc-display)) 

;; define discrimination task
(defun do-discriminate (&optional who)
  
   (reset)
  
   (let* ((lis (permute-list '("B" "C" "D" "F" "G" "H" 
                               "J" "K" "L" "M" "N" "P" 
                               "Q" "R" "S" "T" "V" "W" 
                               "X" "Y" "Z")))
          ;(text1 (first lis))
          ;; simple discrimination:
          ;; determine if two letters are the same or different
          ;; TODO make images more complicated?
          (text1 "A")
          (text2 "A")
          (window (open-exp-window "Visual Register/Detect")))
    
      (add-text-to-exp-window :text text1 :x 100 :y 150)
      (add-text-to-exp-window :text text2 :x 200 :y 150)
    
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
(define-model visual-discriminate

(sgp :seed (123456 0))
(sgp :v t :needs-mouse nil :show-focus t :trace-detail high)

(chunk-type discriminate state)
;; chunk for imaginal buffer. holds two pieces of image information
;; and a determination about whether they are the same
(chunk-type scene image1 image2 choice)

(add-dm 
 (start isa chunk) (attend isa chunk)
 (respond isa chunk) (done isa chunk)
 (goal isa discriminate state start))

;; find the location of the first image
(P find-first-image
   =goal>
      ISA         discriminate
      state       start
 ==>
   +visual-location>
      ISA         visual-location
      :attended    nil
   =goal>
      state       attend-first-image
)

;; turn attention to the first letter
(P attend-first-image
   =goal>
      ISA         discriminate
      state       attend-first-image
   =visual-location>
      ISA         visual-location
   
   ?visual>
      state       free
   
==>
   +visual>
      ISA         move-attention
      screen-pos  =visual-location
   =goal>
      state       register-first-image
)

;; store info about the first image temporarily
(P register-first-image
   =goal>
      ISA         discriminate
      state       register-first-image
   =visual>
      ISA         text
      value       =letter
==>
   =goal>
      state       find-second-image
   +imaginal>
      isa         scene
      image1      =letter
)

;; find the location of the second image
(P find-second-image
   =goal>
      ISA         discriminate
      state       find-second-image
==>
   +visual-location>
      ISA         visual-location
      :attended   nil
   =goal>
      state       attend-second-image
)

;; turn attention to the second image
(P attend-second-image
   =goal>
      ISA         discriminate
      state       attend-second-image
   =visual-location>
      ISA         visual-location
   ?visual>
      state       free
==>
   +visual>
      ISA         move-attention
      screen-pos  =visual-location
   =goal>
      state       register-second-image
)

;; temporarily store info about second image
(P register-second-image
   =goal>
      ISA         discriminate
      state       register-second-image
    =visual>
      ISA         text
      value       =letter2
    ;; match imaginal to keep info about the last letter there
    =imaginal>
      ISA         scene
      image1      =letter1
==>
   =goal>
     state        discriminate-images
   +imaginal>
      ISA         scene
      image1      =letter1
      image2      =letter2
)

;; determine if the two images are the same
(P discriminate-images
   =goal>
      ISA         discriminate
      state       discriminate-images
   =imaginal>
      ISA         scene
      image1      =letter1
      image2      =letter1
==>
   +imaginal>
      ISA         scene
      image1      =letter1
      image2      =letter1
      choice      same
   =goal>
      state       done
  !output!        "same"
)


;(P respond
;   =goal>
;      ISA         discriminate
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
