#|
the goal is to find the combinations of functions add, f and g of a certain depth that would achieve a desired result.
this example is somewhat artificial, but it illustrates nicely the concept of "deep embedding", where the structure
of the allowed language is encoded into structs and the interpretation of ast is defined.
|#



#lang rosette
(require rosette/lib/synthax rosette/lib/angelic rosette/lib/match)


(define (add x y)
  (+ x y)
  )

(define (f i)
  (+ i 2)
  )

(define (g i)
  (+ i 3)
  )


#|
 the grammar of our language:
prog :=: prog-f(arg) | prog-g(arg) | prog-add(arg)
arg  :=: integer (concrete or symbolic)
|#
(struct prog () #:transparent)
(struct prog-f prog (arg) #:transparent)
(struct prog-g prog (arg) #:transparent)
(struct prog-add prog (left right) #:transparent)

; this function defines how a ast should be interpreted
(define (interpret ast)
  (match ast
    [(prog-f arg) (f (interpret arg))]
    [(prog-g arg) (g (interpret arg))]
    [(prog-add left right) (add (interpret left) (interpret right))]
    [_ ast]
    )
  )
    

; a procedure for sketching a circuit of depth <= d
(define (sketch terminal d)
  (assert (>= terminal 0))
  (if
   (or (<= d 0)
       ; this allows us to have programs of depth smaller than d (based on the value of b-stop-expansion, solver can decide to stop the expansion early)
       ; and go directly to terminal value
       (let() (define-symbolic* b-stop-expansion boolean?) b-stop-expansion)
       )
   terminal
   
   (let ([left (sketch terminal (- d 1))])
     ; b-unary-op is a variable to decide whether to use a unary or a binary operation
     (if (let() (define-symbolic* b-unary-op boolean?) b-unary-op)
         ; if unary, we have to sketch a program of depth d-1 as a first argument
       ([choose* prog-f prog-g] left)

       ; if binary, we have to have to arguments (left and right)
       (let ([right (sketch terminal (- d 1))])
         (prog-add left right)
         )
       )
     )
  )
)

(define-symbolic x integer?)

; C is a program that uses symbolic terminal value
(define C (sketch x 3))

; D is a program that uses concrete terminal value
(define D (sketch 4 3))

(define (synth-chain-of-operations goal-value sketched-chain)
  (define sol (solve (assert (equal? goal-value (interpret sketched-chain)))))
  (if (sat? sol)
      (evaluate sketched-chain sol)
      sol
      )
  )


(current-bitwidth #f)
(synth-chain-of-operations 7 C)
(synth-chain-of-operations 234 C)
(synth-chain-of-operations 1 C)


(synth-chain-of-operations 9 D)
(synth-chain-of-operations 8 D)
(synth-chain-of-operations 9 D)
(synth-chain-of-operations 10 D)
(synth-chain-of-operations 14 D)
(synth-chain-of-operations 6 D)
(synth-chain-of-operations 4 D)
(synth-chain-of-operations 23 D)
(synth-chain-of-operations 54 D)
