#!/bin/bash

echo Content-Type: text/html
echo

############################
## Genero encabezado HTML ##
############################

echo "<HTML>
<HEAD>
<TITLE>Respuesta de consulta</TITLE>
</HEAD>
<BODY>
<PRE>"          #PreFormatedText, para mantener formato de lo que introduzcamos luego dentro del body, inclusive el script nuestro, si no queda todo de corrido

#Se sacan los parametros ingresados en el formulario, para decodificar la QUERY_STRING.
#Hay que cortar primero en el & para que no nos de problema luego, cortando la parte del checkbox (si existe) del resto del string, luego en = para sacar los parametros introducidos
#sustituyo el separador de parametros ; (%3B) por un espacio y %2F por / con SED. Asi se usan como parametros para el script del ejercicio 1 
#y apreto los espacios a uno solo



#############################
## DEFINICION DE VARIABLES ##
#############################

PARAMETROS="`echo "$QUERY_STRING" | cut -d"&" -f1 | cut -d= -f2 | sed 's/%3B/ /g' | sed 's/%2F/\//g'`"    #hay que poner el QUERY_STRING entre "" para que no tome el & como tarea, y cortar primero por ese caracter y luego por =
MOSTRAR=0


##################################
## CONTROL DE CAMINOS ABSOLUTOS ##
##################################

for i in $PARAMETROS #se controla que el primer char de cada parametro sea "/" y de esta manera verificar si es una ruta absoluta
do
    if ! [ `echo $i | cut -c1` = "/" ]
    then 
        echo "</PRE>  
            ERROR!! Ingresar parametros solamente con caminos absolutos.
            <BR>
            Retorno al forulario, haga <a href="http://obligatorio/html/index.html">clic aqui</a>
            </BODY>
            </HTML>"

        exit
    fi
done


#####################################################
## GUARDO CODIGO DE ERROR CON TODOS LOS PARAMETROS ##
#####################################################

/obligatorio/ejercicio2/cgi-bin/search $PARAMETROS >/dev/null 2>/dev/null
CODIGO=$?



##########################################
## Printado y control de hardlinks y -t ##
##########################################

if [ $CODIGO -eq 0 -o $CODIGO -eq 1 ]                     #Detecta si el script envia error o mostrara algo en pantalla
then
    for i in $PARAMETROS                  #el for recorre archivo por archivo, y en caso de tener HARDLINK>1 imprime con <b>, si no solo imprime lo que manda el script, SIN usar modificador -t
    do
        if [ `/obligatorio/ejercicio2/cgi-bin/search $i | tr -s " " | grep "Cantidad de Links" | cut -d" " -f6` -gt 1 ]
        then
            echo "<b>"
            /obligatorio/ejercicio2/cgi-bin/search $i 2>&1 | egrep -v "^NO EXISTE NINGUN ARCHIVO DE LOS SOLICITADOS$" 
            echo "</b>"
        else
            /obligatorio/ejercicio2/cgi-bin/search $i 2>&1 | egrep -v "^NO EXISTE NINGUN ARCHIVO DE LOS SOLICITADOS$"
        fi
    done
    if echo "$QUERY_STRING" | egrep -q "&check=t$"                 #Controla si se envio modificador -t
    then
        /obligatorio/ejercicio2/cgi-bin/search -t $PARAMETROS | tail -2    
    fi
else
    /obligatorio/ejercicio2/cgi-bin/search $PARAMETROS 2>&1                  #En caso que sea codigo 2 o 3, el script mandara un error, por lo tanto, mostramos lo que manda directamente el script
fi



###############################################
## Control para printar link de retorno o no ##
## si lo muestra sale generando final HTML   ##
###############################################

if [ $? -gt 0 ]
then
    echo "</PRE>
        Retorno al formulario, haga <a href="http://obligatorio/html/index.html">clic aqui</a>
        </BODY>
        </HTML>"
    exit
fi


################
## Final HTML ##
################

echo "</PRE>
</BODY>
</HTML>"