(deftemplate aeronave
    (slot id)
    (slot compania)
    (slot aerodromoOrigen)
    (slot aerodromoDestino)
    (slot velocidadActual)
    (slot peticion (allowed-values Ninguna Despegue Aterrizaje Emergencia Rumbo))
    (slot estado (allowed-values enTierra Ascenso Crucero Descenso) (default enTierra))
)

(deftemplate aerodromo
    (slot id)
    (slot ciudad)
    (slot estadoRadar (allowed-values ON OFF))
    (slot visibilidad)
    (slot viento)
)

(deftemplate piloto
    (slot aeronave)
    (slot accion (default-values OK SOS Ejecutando Stand-by) (default Stand-by))
)

(deftemplate vuelo
    (slot idOrigen)
    (slot idDestino)
    (slot distancia)
    (slot velDespegue (default 240))
    (slot velCrucero (default 700))
)

(defrule Despegar
    ?a <- (aeronave (id ?id) (compania ?compania) (aerodromoOrigen ?aOrigen) (aerodromoDestino ?aDestino) (peticion Despegue) (estado enTierra))
    ?p <- (piloto (accion OK)(aeronave ?id))
    (aerodromo (id ?aOrigen) (ciudad ?ciudadO) (estadoRadar ON) (visibilidad ?visibilidad) (viento ?viento))
    (aerodromo (id ?aDestino) (ciudad ?ciudadD))
    (vuelo (idOrigen ?aOrigen) (idDestino ?aDestino) (velDespegue ?vDespegue))
    (test (> ?visibilidad 5))
    (test (< ?viento 75))
    =>
    (modify ?p (accion Ejecutando))
    (modify ?a (estado Ascenso) (peticion Ninguna) (velocidadActual ?vDespegue))
    (printout t "La aeronave " ?id " de la compañía " ?compania " va a realizar la acción de " ?peticion " desde el aeródromo " ?aOrigen " de " ?ciudadO " con destino " ?ciudadD crlf)
)

(defrule Excepcion
    ?a <- (aeronave (id ?id) (compania ?compania) (aerodromoOrigen ?aOrigen) (aerodromoDestino ?aDestino))
    (piloto (accion ~OK) (aeronave ?id))
    (aerodromo (id ?aOrigen))
    (aerodromo (id ?aDestino))
    (Vuelo (aerodromoOrigen ?aOrigen) (aerodromoDestino ?aDestino))
    (test (neq ?accion OK))
    =>
    (modify ?a (peticion Emergencia))
    (printout t "ATENCIÓN: El piloto de la aeronave " ?id " de la compañía " ?compania " no se encuentra disponible para iniciar el despegue desde el aeródromo " ?aOrigen "con destino " ?aDestino crlf)
)  

(defrule Crucero
    ?p <- (piloto (accion Despegue) (aeronave ?id))
    (vuelo (velCrucero ?velCrucero) (distancia ?distancia))
    ?a <- (aeronave (id ?id) (compania ?compania) (peticion ?peticion) (estado Ascenso) (aerodromoOrigen ?aOrigen) (aerodromoDestino ?aDestino))
    (aerodromo (id ?aOrigen) (ciudad ?ciudadO))
    (aerodromo (id ?aDestino) (ciudad ?ciudadD))
    =>
    (modify ?a (estado Crucero) (velocidadActual ?velCrucero) (peticion Ninguna))
    (modify ?p (accion Stand-by))
    (printout t "El vuelo durará un total de " (tiempoVueloHoras (?velCrucero ?distancia)) "horas y " (tiempoVueloMinutos (?velCrucero ?distancia)) " minutos." crlf)
    (printout t "La aeronave " ?id " de la compañía " ?compania " va a realizar la acción de crucero desde el aeródromo " ?aOrigen " de " ?ciudadO " con destino " ?ciudadD crlf)
)    

(deffunction tiempoVueloHoras (?velCrucero ?distancia)
    (return (div ?distancia ?velCrucero))
)

(deffunction tiempoVueloMinutos (?velCrucero ?distancia)
    (bind ?resto (mod ?distancia ?velCrucero))
    (bind ?minutos(* (/ ?resto ?vel) 60))
    (return ?minutos)
)
 