#!/bin/bash

# Verificamos si el primer parametro empieza con -, en caso de que si, comparamos y vemos si es -t, que es valido, en caso contrario mandamos mensaje de error
LISTAR=0
if [ `echo $1 | cut -c1` = "-" >/dev/null 2>/dev/null ]    #identificamos si empieza o no con -, si no empieza sigue normal porque es un archivo
then
        if [ $1 = "-t" ]        #igualamos a -t para ver si el modificador es valido o no
        then
                LISTAR=1        #si existe t se carga en variable LISTAR un 1, si no existe, se mantiene el 0
                shift           #elimina el primer parametro, en este caso -t
        else
                echo "Modificador" $1 "incorrecto. Solo se acepta -t para desplegar la cantidad de archivos listada con exito" >&2
                exit 2          
        fi
fi

# Controlamos si se ingresaron o no parametros, si es 0 envia mensaje por salida estandard de errores, y envia codigo de error 3
if [ "$#" = 0 ]
then
        echo "Cantidad de parametros erronea, por favor ingrese algun archivo a listar" >&2
        exit 3
fi

#Desplegamos info de archivos
EXISTE=0
NOEXISTE=0
for i in "$@"
do
        CA=`readlink -m  $i`        #Cargo en variable CA, el camino absoluto del archivo con el comando readlink cada vez que empieza a recorrer un nuevo elemento de la lista el FOR, el readlink con -m muestra camino absoluto exista o no
        if [ -e $CA ]                   #compruebo que exista el archivo
        then
                if [ -d $CA ]           #veo si es directorio
                then
                        TIPO="Directorio"
                        TAMANO="---"
                else
                        if [ -c $CA ]           #veo si es dispositivo
                        then
                                TIPO="Dispositivo"
                                TAMANO="---"
                        else
                                if [ -L $i ]            #veo si es softlink
                                then
                                        TIPO="Softlink"
                                        TAMANO="---"
                                else
                                        if [ -f $CA ]           #veo si es regular o no
                                        then
                                                TIPO="Regular"
                                                TAMANO=`ls -l $CA | tr -s " " | cut -d" " -f5`
                                        else
                                                TIPO="Otro"
                                                TAMANO="---"
                                        fi
                                fi
                        fi
                fi

                if ls -d $CA >/dev/null 2>/dev/null               #Compruebo que tenga permisos de lectura con el comando LS
                then
                        EXISTE=$(($EXISTE + 1 ))

                        GRUPO=`ls -dl $CA | tr -s " " | cut -d" " -f4`
                        OWNER=`ls -dl $CA | tr -s " " | cut -d" " -f3`
                        if [ "root" = "$OWNER" ]                        #Chequea si el usuario es root, ya que trata de manera levemente diferente la forma de mostrar los grupos
                        then
                                USUARIOS=`getent group $GRUPO | cut -d: -f1,4 | tr ':' ','`     #Getent "busca" automaticamente utilizando "group" la linea del arhcivo /etc/group del grupo que se le pasa como parametro
                        else
                                USUARIOS=`getent group $GRUPO | cut -d: -f4`
                        fi

                        echo "Archivo:" $CA "         Cantidad de Links:" `ls -dl $CA | tr -s " " | cut -d" " -f2`
                        echo "Numero de inodo:" `ls -dli $CA | tr -s " " | cut -d" " -f1` "            Sistema de archivos montado en:" `df -P $i | tr -s " " | tail -1 | cut -d' ' -f 6`    #df muestra info del sistema de archivos donde se enuentra el archivo, -P muestra la info en 6 columnas, 2 lineas
                        echo "Tamaño:" $TAMANO "                        Permisos:" `ls -dl $CA | tr -s " " | cut -c 2-10`
                        echo "Tipo de archivo:" $TIPO "              Dueño:" $OWNER
                        echo "Grupo:" $GRUPO "                        Usuarios:" $USUARIOS       

                        echo "--------------------------------------------------------------------------"

                else
                        echo "No se tienen los permisos necesarios para acceder a la informacion del archivo:" $CA >&2
                        echo "///"
                        NOEXISTE=1
                fi

        else   
                echo "No existe en el sistema el archivo:" $CA >&2
                echo "*** " >&2
                NOEXISTE=1          
        fi

done

if [ $EXISTE = 0 ]
then
        echo "NO EXISTE NINGUN ARCHIVO DE LOS SOLICITADOS" >&2
        exit 4
fi

if [ $LISTAR = 1 ]
then
        echo "+++++++++++++++++++++++++++++"
        echo "Se han listado" $EXISTE "archivos."
fi

if [ $NOEXISTE = 1 ]
then
        exit 1
else   
        exit 0
fi