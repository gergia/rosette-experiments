#lang rosette
(require rosette/lib/synthax rosette/lib/angelic)


; the goal is to combine three different function, f, g and h, in a way to produce a desired result.
; h is identity and is there because I still don't know how to have variable number of steps (a symbolic value that a solver would decide about)

(define (f i)
  (+ i 2)
  )

(define (g i)
  (+ i 3)
  )

(define (h i)
  i
  )



(define (operation-list n) (build-list n (lambda (x) [choose* f g h] )))

(define (prog-combination i n)
  
    (foldl
     (lambda (next_el result)
       (next_el result)
       )
     i
     (operation-list n)
     )
    )
  



(define (combine-concrete-length start-value repetitions goal-value)
 (solve
  (assert         
   (equal? (prog-combination start-value repetitions) goal-value)    
  )
 )
)
; the call to (combine-concrete-length 1 3 10) gives that function g should be called three times,
;(combine-concrete-length 10 3 10) that h should be invoked three times and (combine-concrete-length 1 3 11) returns unsat



;
;
; this way doesn't work because build-list expects a concrete value n

;(define-symbolic n integer?)
;(define combine-symbolic-length
; (solve
;  (assert         
;   (equal? (prog-combination 1 n) 6)    
;  )
; )
;)


