#!/bin/bash

######################################################
## Verificamos si el primer parametro empieza con - ## 
######################################################
LISTAR=0
if [ `echo $1 | cut -c1` = "-" >/dev/null 2>/dev/null ]    
then
        if [ $1 = "-t" ] 
        then
                LISTAR=1        
                shift       
        else
                echo "Modificador" $1 "incorrecto. Solo se acepta -t para desplegar la cantidad de archivos listada con exito" >&2
                exit 2          
        fi
fi


##################################################
## Controlamos si se ingresaron o no parametros ## 
##################################################
if [ "$#" = 0 ]
then
        echo "Cantidad de parametros erronea, por favor ingrese algun archivo a listar" >&2
        exit 3
fi



##################################
## Desplegamos info de archivos ##
##################################
EXISTE=0
NOEXISTE=0
for i in "$@"
do
        CA=`readlink -m  $i`       
        if [ -e $CA ]      
        then
                if [ -d $CA ]  
                then
                        TIPO="Directorio"
                        TAMANO="---"
                else
                        if [ -c $CA ]  
                        then
                                TIPO="Dispositivo"
                                TAMANO="---"
                        else
                                if [ -L $i ]    
                                then
                                        TIPO="Softlink"
                                        TAMANO="---"
                                else
                                        if [ -f $CA ]  
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

                if ls -d $CA >/dev/null 2>/dev/null               
                then
                        EXISTE=$(($EXISTE + 1 ))

                        GRUPO=`ls -dl $CA | tr -s " " | cut -d" " -f4`
                        OWNER=`ls -dl $CA | tr -s " " | cut -d" " -f3`
                        if [ "root" = "$OWNER" ]   
                        then
                                USUARIOS=`getent group $GRUPO | cut -d: -f1,4 | tr ':' ','`     
                        else
                                USUARIOS=`getent group $GRUPO | cut -d: -f4`
                        fi

                        echo "Archivo:" $CA "         Cantidad de Links:" `ls -dl $CA | tr -s " " | cut -d" " -f2`
                        echo "Numero de inodo:" `ls -dli $CA | tr -s " " | cut -d" " -f1` "            Sistema de archivos montado en:" `df -P $i | tr -s " " | tail -1 | cut -d' ' -f 6`    
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


###############################################
## Verificamos si existio algun archivo o no ##
###############################################
if [ $EXISTE = 0 ]
then
        echo "NO EXISTE NINGUN ARCHIVO DE LOS SOLICITADOS" >&2
        exit 4
fi

##########################################
## Verificamos si se ingreso o no el -t ##
##########################################
if [ $LISTAR = 1 ]
then
        echo "+++++++++++++++++++++++++++++"
        echo "Se han listado" $EXISTE "archivos."
fi

########################################################################
## Si existio algun archivo, enviamos codigo de error correspondiente ##
########################################################################
if [ $NOEXISTE = 1 ]
then
        exit 1
else   
        exit 0
fi