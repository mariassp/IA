(deftemplate Modelo
    (slot precio)
    (slot tamMaletero (allowed-values Pequeno Mediano Grande))
    (slot caballos)
    (slot absCoche (allowed-values Si No))
    (slot consumo)
)

(deftemplate Formulario
    (slot maxPrecio (default 13000))
    (slot tamMaletero (allowed-values Pequeno Mediano Grande) (default Grande))
    (slot minCaballos (default 80))
    (slot absCoche (allowed-values Si No)(default Si))
    (slot maxConsumo (default 8,0))
)

(deffacts iniciales
    (Modelo (modelo1) (precio 12000) (tamMaletero Pequeno) (caballos 65) (absCoche No) (consumo 4,7))
    (Modelo (modelo2) (precio 12500) (tamMaletero Pequeno) (caballos 80) (absCoche Si) (consumo 4,9))
    (Modelo (modelo3) (precio 13000) (tamMaletero Mediano) (caballos 100) (absCoche Si) (consumo 7,8))
    (Modelo (modelo4) (precio 14000) (tamMaletero Grande) (caballos 125) (absCoche Si) (consumo 6,0))
    (Modelo (modelo5) (precio 15000) (tamMaletero Pequeno) (caballos 147) (absCoche Si) (consumo 8,5))
)

(defrule buscarModelo
    (formulario (maxPrecio ?maxPrecio) (tamMaletero ?tamMaletero) (minCaballos ?minCaballos) (absCoche ?absCoche) (maxConsumo ?maxConsumo))
    (modelo (modelo ?modelo) (precio ?precio) (tamMaletero ?tamMaletero) (caballos ?caballos) (absCoche ?absCoche) (consumo ?consumo))
    (test <= ?precio ?maxPrecio) 
    (test >= ?caballos ?minCaballos)
    (test <= ?consumo ?maxConsumo)
    =>
	(printout t "Modelo recomendado: " ?modelo crlf)
)