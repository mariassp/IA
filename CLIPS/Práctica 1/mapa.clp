
(clear)
(reset)
(deffacts inicio
    (ubicacion A oeste B)
    (ubicacion A norte D)
    (ubicacion B oeste C)
    (ubicacion B norte E)
    (ubicacion C norte F)
    (ubicacion D oeste E)
    (ubicacion D norte G)
    (ubicacion E oeste F)
    (ubicacion E norte H)
    (ubicacion F norte I)
    (ubicacion G oeste H)
    (ubicacion H oeste I)
)

(defrule inicio
    ?f1 <-(situacion ?x ?y)
    (ubicacion ?x ?u ?y)
    =>
    (printout t ?x " esta al " ?u " de " ?y crlf)
    (retract ?f1)
) ;; inicio


; El sistema de representación será capaz de inferir todas las relaciones inversas de las dadas
; directamente, es decir, las relaciones “estar al sur de” y “estar al este de”
(defrule sur
    (ubicacion ?x norte ?y)
    =>
    (assert ?y sur ?x)
)

(defrule este
    (ubicacion ?x oeste ?y)
    =>
    (assert ?y este ?x)
)


;Se inferirán nuevas relaciones por transitividad. Por ejemplo, sabiendo que “A está al norte de D” y que
;“D está al norte de G” se inferirá que “A está al norte de G”.
(defrule norte2
    (ubicacion ?x norte ?y) (ubicacion ?y norte ?z)
    =>
    (assert ?x norte ?z)
)

(defrule oeste2
    (ubicacion ?x oeste ?y) (ubicacion ?y oeste ?z)
    =>
    (assert ?x oeste ?z)
)

(defrule este2
    (ubicacion ?x este ?y) (ubicacion ?y este ?z)
    =>
    (assert ?x este ?z)
)

(defrule sur2
    (ubicacion ?x sur ?y) (ubicacion ?y sur ?z)
    =>
    (assert ?x sur ?z)
)


;Se inferirán las relaciones noroeste, noreste, suroeste y sureste a partir de los hechos iniciales. Por
;ejemplo, se podrá inferir que “C está al noreste de G”.
(defrule noroeste
    (ubicacion ?x oeste ?y) (ubicacion ?y norte ?z)
    =>
    (assert ?x noroeste ?z)
)

(defrule noreste
    (ubicacion ?x este ?y) (ubicacion ?y norte ?z)
    =>
    (assert ?x noreste ?z)
)

(defrule suroeste
    (ubicacion ?x oeste ?y) (ubicacion ?y norte ?z)
    =>
    (assert ?z suroeste ?x)
)

(defrule sureste
    (ubicacion ?x este ?y) (ubicacion ?y norte ?z)
    =>
    (assert ?z sureste ?x)
)


