#!/bin/bash
source /home/ubuntu/secreto

############# FUNCIONES ################
function procesando() {
    while true
    do
        read -p "Introduce una ip. Si quieres salir teclea 'q' " ip
	# Comprobar que tenga la estructura de la dirección IPv4
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	    # Llamada a la API
            curl -s "https://proxycheck.io/v2/$ip?vpn=1&asn=1&key=$API_proxycheck"
        elif [ "$ip" = "q" ]; then
            exit
        else
            echo "No es válido. Inténtalo de nuevo o sal del script con 'q'."
        fi
    done
}

#############PROGRAMA PRINCIPAL ################
procesando
