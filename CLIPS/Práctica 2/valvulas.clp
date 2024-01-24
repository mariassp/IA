; Plantillas
(deftemplate Valvula
    (slot nombre)
    (slot t1 (default 0))
    (slot t2 (default 0))
    (slot presion (default 0))
    (slot estado (allowed-values abierta cerrada)(default cerrada))
)

; Hechos iniciales
(deffacts iniciales
    (Valvula (nombre Entrada) (t1 101) (t2 35) (presion 1))
    (Valvula (nombre Salida) (t1 101) (t2 155) (presion 5))
    (Valvula (nombre Pasillo1) (t1 99) (t2 37) (estado cerrada))
)

; Reglas
(defrule R1
    ?v <- (Valvula (estado abierta) (presion 5))
    =>
    (modify ?v (estado cerrada) (presion 0))
)

(defrule R2
    ?v <- (Valvula (presion ?presion) (t1 ?t1) (estado cerrada))
    (test (< ?presion 10))
    (test (> ?t1 35))
    =>
    (aumentoPresion ?presion ?t1)
    (modify ?v (estado abierta) (presion ?presion) (t1 ?t1))
)

(deffunction aumentoPresion (?presion ?t1)
    (while (> ?t1 35)
        (bind ?presion (+ ?presion 1)) ;bind para cambiar el valor de presion a uno nuevo aumentado
        (bind ?t1 (- ?t1 5))
    )
)

(defrule R3
    ?v1 <- (Valvula (nombre ?nA) (t1 ?t1A) (t2 ?t2) (estado ?estado))
    ?v2 <- (Valvula (nombre ?nB) (t1 ?t1B) (t2 ?t2) (estado ?estado))
    (test (!= ?nA ?nB))
    (test (< ?t1B ?t2))
    =>
    (decrementoTemp (?t1B ?t2))
    (modify ?v1 (estado abierta))
    (modify ?v2 (estado abierta) (t2 ?t2))
)

(deffunction decrementoTemp (?t1 ?t2)
    (while (> ?t2 ?t1)
        (bind ?t2 (- ?t2 ?t1))
    )
)