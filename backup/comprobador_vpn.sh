#!/bin/bash
source /home/ubuntu/secreto

################################# FUNCIONES #####################################

function procesando() {
    echo "Procesando ${#ips[@]} IPs..."

    for ip in "${ips[@]}"
    do
        url="https://proxycheck.io/v2/$ip?vpn=1&asn=1&key=$API_proxycheck"
        response=$(curl -s "$url")

        type_linea=$(echo "$response" | grep -o '"type": *"[^"]*"' | head -n1)
        provider_linea=$(echo "$response" | grep -o '"provider": *"[^"]*"' | head -n1)

        type=$(echo "$type_linea" | sed -E 's/"type": *"([^"]*)"/\1/')
        provider=$(echo "$provider_linea" | sed -E 's/"provider": *"([^"]*)"/\1/')

        if [[ "$type" != "VPN" && "$type" != "proxy" && "$type" != "Compromised Server" ]]
        then
            clean_ips+=("$ip")
	    mysql -u $mysql_user -p$mysql_passwd -e "USE proveedor_ip; Insert ignore into clean_ips values ('$ip')" -P 3307
        else
            echo "⚠️  $ip detectada como $type y ela provee '$provider'"
	    mysql -u $mysql_user -p$mysql_passwd -e "USE proveedor_ip; Insert ignore into ips values ('$ip', '$type', '$provider')" -P 3307
        fi
    done
}

function visualizar() {
    echo "✅ Estas son las IPs que NO son VPN/proxy:"
    for i in ${clean_ips[@]}
    do
        echo "-> $i"
    done | sort -u
}

######################## PROGRAMA PRINCIPAL ##########################
datos=$(mysql -u $mysql_user -p$mysql_passwd -e "USE laravel; SELECT ip COLLATE utf8mb4_general_ci AS ip FROM laravel.sospechosos UNION SELECT ip COLLATE utf8mb4_general_ci FROM cowrie.sessions UNION SELECT src_ip COLLATE utf8mb4_general_ci AS ip FROM opencanary.open_ftp;" -P 3307 | tail -n +2) 2> /dev/null
ips=($datos)
clean_ips=()

procesando
visualizar
