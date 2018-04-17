#lang rosette
(require rosette/lib/synthax rosette/lib/angelic)


; a simple language is defined. its grammar is given by
; P             :==: init : [direction steps]+
; direction     :==: -> | <-
; steps         :==: number
;
; the goal is to find values for steps given the pattern describing directions.

(define-syntax move-agent
  (syntax-rules (-> <-)
    [(_ init_pos -> steps) (+ init_pos steps)]
    [(_ init_pos <- steps) (- init_pos steps)]
    )
  )

(define-syntax line-mover
  (syntax-rules (:)
    [(_ init_pos : [direction steps])
     (move-agent init_pos direction steps)]
   [(_ init_pos : [direction steps] [dirRest stepsRest] ... )
    (line-mover (move-agent init_pos direction steps) : [dirRest stepsRest] ...)
    ]
    )
)





(define-symbolic s x y integer?)

(define sketch
  (line-mover s : [-> x] [<- y]))


(define (synth goal-pos)
  (solve
   (assert
     (and
      (= sketch goal-pos)
      (>= x 0)
     (>= y 0)
     )
   )
  )
  )


(define t (model (synth 20)))

(hash-ref t s)
(hash-ref t x)
(hash-ref t y)


;(line-mover 6 : [-> 4] [<- 14] [-> 20])
;(line-mover 3 : [-> 12] [d 34])
;(line-mover2 5 : [-> 4] [-> 45] [-> 98] [<- 100])
                               
