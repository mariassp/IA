; Declaramos variables globales para la fecha actual y límite de dinero
(defglobal ?*FECHA* = 2023) 
(defglobal ?*LIMITE1* = 900)

; -- Declaración de hechos estructurados --
(deftemplate Usuario
    (slot dni)
    (slot pin)
    (slot dinero (default 0))
)

(deftemplate Tarjeta
    (slot pin)
    (slot dni)
    (slot intentos (default 3))
    (slot limiteDinero (default 100))
    (slot anno (default 2030))
    (slot validada (allowed-values Si No)(default no))
)

(deftemplate Cuenta
    (slot dni)
    (slot saldo)
    (slot estado (allowed-values enPantalla dineroEntregado Inicial SuperaLimite SinSaldo) (default Inicial))
)


; -- Hechos iniciales --
(deffacts iniciales
    (tarjeta (dni 123456) (pin 1212) (intentos 3) (limiteDinero 500) (anno 2026))
    (tarjeta (dni 456456) (pin 1211) (intentos 3) (limiteDinero 500) (anno 2026))
    (tarjeta (dni 000111) (pin 0011) (intentos 0) (limiteDinero 500) (anno 2026))

    (cuenta (dni 123456) (saldo 5000))
    (cuenta (dni 456456) (saldo 33))
    (cuenta (dni 000111) (saldo 30000))
)


; -- Declaración de reglas --
(defrule inicial
    ;introducir los datos desde una pantalla
    =>
    (assert (Usuario (dni ?dni) (pin ?pin) (cantidad ?cantidad)))
)

(defrule Supera_Intentos
    (declare (salience 2)) ; le da una prioridad de 2
    ?t <- (Tarjeta (intentos 0) (dni ?dni)) 
    (Cuenta (dni ?dni))
    =>
    (retract ?t) ;elimina la tarjeta a la que le quedan 0 intentos
    (printout t "La tarjeta ha alcanzado el número límite de intentos" crlf) 
)

(defrule Pin_Invalido
    (declare (salience 1)) ; le da una prioridad de 1
    ?u <- (Usuario (dni ?dni) (pin ?pin))
    ?t <- (Tarjeta (dni ?dni) (pin ?pin2) (intentos ?intentos))
    (Cuenta (dni ?dni))
    (test (neq ?pin ?pin2)) ;comprueba que el pin introducido por el usuario 
    =>                      ;y de la tarjeta NO sean iguales
    (modify ?t (intentos (decremento ?intentos)))  ;restamos un intento mediante una función
    ; otra opción para la línea anterior sería: (modify ?t (intentos ?intentos-1))
    (printout t "Pin inválido" crlf)
    (retract ?u) ; elimina los datos introducidos por el usuario para empezar de nuevo
)

(defrule Valida_Tarjeta
    ?u <- (Usuario (dni ?dni) (pin ?pin))
    ?t <- (Tarjeta (dni ?dni) (pin ?pin) (intentos ?intentos) (anno ?anno) (validada No))
    (Cuenta (dni ?dni))
    (test (< ?*FECHA* ?anno))
    =>
    (modify ?t (validada Si))
    (printout t "Validacion OK" crlf)
)

(defrule Muestra_Saldo
    (Usuario (dni ?dni))
    (Tarjeta (dni ?dni) (validada Si))
    ?c <- (Cuenta (dni ?dni) (estado ?estado) (saldo ?saldo))
    =>
    (modify ?c (estado enPantalla))
    (printout t "El saldo es: " ?saldo crlf)
)

(defrule Saldo_NoSuficiente
    ?u <- (Usuario (dni ?dni)(dinero ?dinero))
    (Tarjeta (dni ?dni) (validada Si))
    (Cuenta (dni ?dni) (saldo ?saldo))
    (test (>= ?saldo ?dinero))
    =>
    (printout t "No tiene suficiente saldo para realizar la  operación" crlf) 
    (retract ?u) 
)

(defrule Comprueba_Limite1
    ?u <- (Usuario (dni ?dni)(dinero ?dinero))
    (Tarjeta (dni ?dni) (validada Si))
    (test (< ?*LIMITE1 ?dinero))
    =>
    (printout t "El límite establecido por el banco ha sido superado" crlf)
    (retract ?u)
)

(defrule Comprueba_Limite2
    ?u <- (Usuario (dni ?dni) (dinero ?dinero))
    (Tarjeta (dni ?dni) (limiteDinero ?limite) (validada Si))
    (Cuenta (dni ?dni) (saldo ?saldo))
    (test (> ?dinero ?limite))
    =>
    (printout t "El límite establecido por la tarjeta ha sido superado" crlf)
    (retract ?u)
)

(defrule Entrega_Dinero
    (declare (salience -1)) 
    (Usuario (dni ?dni) (dinero ?dinero))
    ?c <- (Cuenta (dni ?dni) (estado ?estado) (saldo ?saldo))
    (Tarjeta (dni ?dni) (validada Si))
    =>
    (modify ?c (estado DineroEntregado) (saldo (diferencia ?saldo ?dinero))) ; usamos la función de resta para calcular el nuevo saldo: saldo antiguo - dinero sacado
    (retract ?u)
)

; Función para decrementar un valor dado en 1
(deffunction decremento (?a)
    (- ?a 1)
)

; Función para realizar la resta de dos valores
(deffunction diferencia (?a ?b)
    (- ?a ?b) ; a - b
)

