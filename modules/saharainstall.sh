#!/bin/bash
#
# Instalador desatendido para Openstack Juno sobre UBUNTU
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Octubre del 2014
#
# Script de instalacion y preparacion de Sahara
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

if [ -f /etc/openstack-control-script-config/sahara-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo "keystone keystone/auth-token password $SERVICE_TOKEN" > /tmp/keystone-seed.txt
echo "keystone keystone/admin-password password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-password-confirm password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-user string admin" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-tenant-name string $keystoneadminuser" >> /tmp/keystone-seed.txt
echo "keystone keystone/region-name string $endpointsregion" >> /tmp/keystone-seed.txt
echo "keystone keystone/endpoint-ip string $keystonehost" >> /tmp/keystone-seed.txt
echo "keystone keystone/register-endpoint boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-email string $keystoneadminuseremail" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-role-name string $keystoneadmintenant" >> /tmp/keystone-seed.txt
echo "keystone keystone/configure_db boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/create-admin-tenant boolean false" >> /tmp/keystone-seed.txt

debconf-set-selections /tmp/keystone-seed.txt

echo "glance-common glance/admin-password password $glancepass" > /tmp/glance-seed.txt
echo "glance-common glance/auth-host string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-api glance/keystone-ip string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-common glance/paste-flavor select keystone" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-tenant-name string $keystoneadmintenant" >> /tmp/glance-seed.txt
echo "glance-api glance/endpoint-ip string $glancehost" >> /tmp/glance-seed.txt
echo "glance-api glance/region-name string $endpointsregion" >> /tmp/glance-seed.txt
echo "glance-api glance/register-endpoint boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-user	string $keystoneadminuser" >> /tmp/glance-seed.txt
echo "glance-common glance/configure_db boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_host string $messagebrokerhost" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_password password $brokerpass" >> /tmp/glance-seed.txt
echo "glance-common glance/rabbit_userid string $brokeruser" >> /tmp/glance-seed.txt

debconf-set-selections /tmp/glance-seed.txt

echo "cinder-common cinder/admin-password password $cinderpass" > /tmp/cinder-seed.txt
echo "cinder-api cinder/region-name string $endpointsregion" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/configure_db boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-tenant-name string $keystoneadmintenant" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/register-endpoint boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/auth-host string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/start_services boolean false" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/endpoint-ip string $cinderhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/volume_group string cinder-volumes" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/keystone-ip string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-user string $keystoneadminuser" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_password password $brokerpass" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_host string $messagebrokerhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/rabbit_userid string $brokeruser" >> /tmp/cinder-seed.txt

debconf-set-selections /tmp/cinder-seed.txt

echo "neutron-common neutron/admin-password password $keystoneadminpass" > /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-password password $keystoneadminpass" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/keystone-ip string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/local_ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/region-name string $endpointsregion" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/register-endpoint boolean false" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-user string $keystoneadminuser" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/tunnel_id_ranges string 0" >> /tmp/neutron-seed.txt
echo "neutron-plugin-openvswitch neutron-plugin-openvswitch/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/auth-host string $keystonehost" >> /tmp/neutron-seed.txt
echo "neutron-server neutron/endpoint-ip string $neutronhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "neutron-metadata-agent neutron/admin-tenant-name string $keystoneadmintenant" >> /tmp/neutron-seed.txt
echo "openswan openswan/install_x509_certificate boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_password password $brokerpass" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_userid string $brokeruser" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/rabbit_host string $messagebrokerhost" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tunnel_id_ranges string 1" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/tenant_network_type select vlan" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/enable_tunneling boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/configure_db boolean false" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/plugin-select select OpenVSwitch" >> /tmp/neutron-seed.txt
echo "neutron-common neutron/local_ip string $neutronhost" >> /tmp/neutron-seed.txt

debconf-set-selections /tmp/neutron-seed.txt

echo "nova-common nova/admin-password password $keystoneadminpass" > /tmp/nova-seed.txt
echo "nova-common nova/configure_db boolean false" >> /tmp/nova-seed.txt
echo "nova-consoleproxy nova-consoleproxy/daemon_type select spicehtml5" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit-host string 127.0.0.1" >> /tmp/nova-seed.txt
echo "nova-api nova/register-endpoint boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/my-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-common nova/start_services boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-user string $keystoneadminuser" >> /tmp/nova-seed.txt
echo "nova-api nova/region-name string $endpointsregion" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-tenant-name string $keystoneadmintenant" >> /tmp/nova-seed.txt
echo "nova-api nova/endpoint-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-api nova/keystone-ip string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/active-api multiselect ec2, osapi_compute, metadata" >> /tmp/nova-seed.txt
echo "nova-common nova/auth-host string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_host string $messagebrokerhost" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_password password $brokerpass" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit_userid string $brokeruser" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_url string http://$neutronhost:9696" >> /tmp/nova-seed.txt
echo "nova-common nova/neutron_admin_password password $neutronpass" >> /tmp/nova-seed.txt

debconf-set-selections /tmp/nova-seed.txt

echo "sahara-common sahara/rabbit_password password $brokerpass" > /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-password password $saharapass" >> /tmp/sahara-seed.txt
echo "sahara sahara/register-endpoint boolean false" >> /tmp/sahara-seed.txt
echo "sahara sahara/region-name string $endpointsregion" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-tenant-name string $keystoneservicestenant" >> /tmp/sahara-seed.txt
echo "sahara sahara/keystone-ip string $saharahost" >> /tmp/sahara-seed.txt
echo "sahara sahara/endpoint-ip string $keystonehost" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/admin-user string $saharauser" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/auth-host string $keystonehost" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/configure_db boolean false" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/rabbit_userid string $brokeruser" >> /tmp/sahara-seed.txt
echo "sahara-common sahara/rabbit_host string $messagebrokerhost" >> /tmp/sahara-seed.txt

debconf-set-selections /tmp/sahara-seed.txt

#

echo ""
echo "Instalando paquetes para Sahara"

aptitude -y install python-sahara sahara-common sahara

echo "Listo"
echo ""

rm -f /tmp/*.seed.txt

source $keystone_admin_rc_file

echo ""
echo "Configurando Heat"
echo ""

/etc/init.d/sahara stop

echo ""
echo "Configurando Sahara"
echo ""

echo "#" >> /etc/sahara/sahara.conf

crudini --del /etc/sahara/sahara.conf database connection
crudini --del /etc/sahara/sahara.conf database connection
crudini --del /etc/sahara/sahara.conf database connection
crudini --del /etc/sahara/sahara.conf database connection
crudini --del /etc/sahara/sahara.conf database connection

case $dbflavor in
"mysql")
        crudini --set /etc/sahara/sahara.conf database connection mysql://$saharadbuser:$saharadbpass@$dbbackendhost:$mysqldbport/$saharadbname
        ;;
"postgres")
        crudini --set /etc/sahara/sahara.conf database connection postgresql://$saharadbuser:$saharadbpass@$dbbackendhost:$psqldbport/$saharadbname
        ;;
esac

crudini --set /etc/sahara/sahara.conf DEFAULT debug false
crudini --set /etc/sahara/sahara.conf DEFAULT verbose false
crudini --set /etc/sahara/sahara.conf DEFAULT log_dir /var/log/sahara
crudini --set /etc/sahara/sahara.conf DEFAULT log_file sahara.log
crudini --set /etc/sahara/sahara.conf DEFAULT host $saharahost
crudini --set /etc/sahara/sahara.conf DEFAULT port 8386
crudini --set /etc/sahara/sahara.conf DEFAULT use_neutron true
crudini --set /etc/sahara/sahara.conf DEFAULT use_namespaces true
crudini --set /etc/sahara/sahara.conf DEFAULT os_region_name $endpointsregion
crudini --set /etc/sahara/sahara.conf DEFAULT control_exchange openstack

crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_user $saharauser
crudini --set /etc/sahara/sahara.conf keystone_authtoken admin_password $saharapass
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_host $keystonehost
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_port 35357
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_protocol http
crudini --set /etc/sahara/sahara.conf keystone_authtoken auth_uri http://$keystonehost:5000/v2.0/
crudini --set /etc/sahara/sahara.conf keystone_authtoken identity_uri http://$keystonehost:35357
crudini --set /etc/sahara/sahara.conf keystone_authtoken signing_dir /tmp/keystone-signing-sahara

case $brokerflavor in
"qpid")
        crudini --set /etc/sahara/sahara.conf DEFAULT rpc_backend qpid
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_reconnect_interval_min 0
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_username $brokeruser
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_tcp_nodelay True
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_protocol tcp
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_hostname $messagebrokerhost
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_password $brokerpass
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_port 5672
        crudini --set /etc/sahara/sahara.conf DEFAULT qpid_topology_version 1
        ;;

"rabbitmq")
        crudini --set /etc/sahara/sahara.conf DEFAULT rpc_backend rabbit
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_host $messagebrokerhost
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_userid $brokeruser
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_password $brokerpass
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_port 5672
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_use_ssl false
        crudini --set /etc/sahara/sahara.conf DEFAULT rabbit_virtual_host $brokervhost
        ;;
esac

mkdir -p /var/log/sahara
echo "" > /var/log/sahara/sahara.log
chown -R sahara.sahara /var/log/sahara /etc/sahara

echo ""
echo "Sahara Configurado"
echo ""

#
# Se aprovisiona la base de datos
echo ""
echo "Aprovisionando/inicializando BD de SAHARA"
echo ""

sahara-db-manage --config-file /etc/sahara/sahara.conf upgrade head

chown -R sahara.sahara /var/log/sahara /etc/sahara



echo "Listo"
echo ""

echo ""
echo "Aplicando reglas de IPTABLES"

iptables -A INPUT -p tcp -m multiport --dports 8386 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Listo"

echo ""
echo "Activando Servicios"
echo ""

/etc/init.d/sahara start
chkconfig sahara on

testsahara=`dpkg -l sahara-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testsahara == "0" ]
then
	echo ""
	echo "Falló la instalación de sahara - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/sahara-installed
	date > /etc/openstack-control-script-config/sahara
fi


echo ""
echo "Sahara Instalado"
echo ""


