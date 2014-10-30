#!/bin/bash
#
# Instalador desatendido para Openstack Juno sobre UBUNTU
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Octubre del 2014
#
# Script de instalacion y preparacion de indentidades Keystone para Sahara
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "No puedo acceder a mi archivo de configuración"
	echo "Revise que esté ejecutando el instalador/módulos en el directorio correcto"
	echo "Abortando !!!!."
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "Proceso de BD verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende de que el proceso de base de datos"
	echo "haya sido exitoso, pero aparentemente no lo fue"
	echo "Abortando el módulo"
	echo ""
	exit 0
fi


if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Proceso principal de Keystone verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende del proceso principal de keystone"
	echo "pero no se pudo verificar que dicho proceso haya sido"
	echo "completado exitosamente - se abortará el proceso"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-extra-idents ]
then
	echo ""
	echo "Aparentemente todas las identidades ya fueron creadas"
	echo "Saliendo del módulo"
	echo ""
	exit 0
fi

source $keystone_admin_rc_file

echo ""
echo "Creando Identidades para SAHARA"
echo ""

echo "Creando Usuario para Sahara"
keystone user-create --name=$saharauser --pass=$saharapass --email=$saharaemail
sync
sleep 5
sync

echo "Creando Tenant para Sahara"
keystone tenant-create --name=$saharauser

echo "Agregando Role para usuario de Sahara en tenants $saharauser y $keystoneservicestenant"
keystone user-role-add --user=$saharauser --tenant=$saharauser --role=$keystoneadminuser
keystone user-role-add --user=$saharauser --tenant=$keystoneservicestenant --role=$keystoneadminuser
sync
sleep 5
sync

echo "Creando Servicios para Sahara"
keystone service-create --name=$saharasvce --type=data_processing --description="OpenStack Data Processing Service"
sync
sleep 5
sync

keystonesaharaserviceid=`keystone service-get $saharasvce|grep id|awk '{print $4}'`

echo "Creando Endpoints para Sahara"

keystone endpoint-create --region=$endpointsregion \
  --service-id=$keystonesaharaserviceid \
  --publicurl="http://$saharahost:8386/v1.1/\$(tenant_id)s" \
  --internalurl="http://$saharahost:8386/v1.1/\$(tenant_id)s" \
  --adminurl="http://$saharahost:8386/v1.1/\$(tenant_id)s"

echo "Listo"

echo ""
echo "Todas las identidades para Sahara han sido creadas"
echo ""

