#|
the goal is to find the expression equivalent to input boolean formula in terms of boolean formulas with only "not", "xor" and "or" operators. Additionally, the formula should
be of minimal size (with a tolerance allowed). We limit the search by max-formula-size
|#


#lang rosette
(require rosette/lib/synthax rosette/lib/angelic rosette/lib/match racket/format)

; max size of a formula
(define max-formula-size 10)

; when searching for a formula size, we make steps of step-size. Setting this value to 1 will yield the minimal formula. Increasing it
; will make search faster, but potentially the formulas will be huge without need for it
(define step-size 2)

#|
this defines the grammar: we only allow formula-or and formula-neg with meaning of "or" and "not" operators
|#

(struct formula () #:transparent)
(struct formula-or formula (arg1 arg2) #:transparent)
(struct formula-xor formula (arg1 arg2) #:transparent)
(struct formula-neg formula (arg) #:transparent)

; defining how to interpret the formula
(define (interpret formula)
  (match formula
    [(formula-or arg1 arg2) (or (interpret arg1) (interpret arg2))]
    [(formula-neg arg) (not (interpret arg))]
    [(formula-xor arg1 arg2) (xor (interpret arg1) (interpret arg2))]
    [_ formula]
    )
  )
  

; a procedure for sketching a formula of depth <= d
(define (sketch propVars d)
  (if
   ;either we reached depth zero or the solver decided to stop the expansion (because we want to generate formulas of depth "up to d".
   ; in that case, choose one of the propositional variables
   (or (= d 0)
       (let() (define-symbolic* b-stop-expansion boolean?) b-stop-expansion)
       )
   (apply choose* propVars)
   ; otherwise (if we are not stopping the search)
   (let ([left-child (sketch propVars (- d 1))])
     ; if the solver decides to use unary operation (in our case "formula-neg")
     ; we only need to generate one argument, left child
     (if (let() (define-symbolic* b-unary-op boolean?) b-unary-op)
         (formula-neg left-child)
         ; otherwise, if the solver decides to use binary operation, we generate
         ; another argument and choose between the two binary operation (formula-or and formula-xor)
          (let ([right-child (sketch propVars (- d 1))])
               ([choose* formula-or formula-xor] left-child right-child)
               )
             )
         )
       )
   )
 
(define-symbolic* x y z boolean?)

; this function synthesizes a formula of size up to d
(define (synth-formula-size goal-formula d)
  ; inputs are all the symbolic variables appearing in goal-formula
  (define inputs (symbolics goal-formula))
  ;the sketch: a space of all formulas of size up to d
  (define sketch-formula (sketch inputs d))
  (define sol    
    (synthesize #:forall inputs
                #:guarantee (assert (equal? (interpret sketch-formula) goal-formula))
                )
    )

  (if (sat? sol)
      (evaluate sketch-formula sol)
      sol
      )  
  )

(define (helper-iteration spec d)
  (if (> d max-formula-size)
      null
      (let ([sol (synth-formula-size spec d)])
        (if (formula? sol)
            sol
            (helper-iteration spec (+ d step-size))
         )
        )
      )
  )

(define (synth-formula goal-formula)
  (define sol (helper-iteration goal-formula 0))
  (if (null? sol)
      (string-append "can not find the formula for of size up to " (~a max-formula-size) " for formula " (~a goal-formula) )
      sol
  )
 )
    

;(synth-formula-exact-size (=> x y) 2)
;(synth-formula-exact-size (&& x y) 6)

(synth-formula (and x y))
(synth-formula (not x))
(synth-formula (xor x y))
