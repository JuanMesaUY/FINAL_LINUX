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
<PRE>"          


#############################
## DEFINICION DE VARIABLES ##
#############################
PARAMETROS="`echo "$QUERY_STRING" | cut -d"&" -f1 | cut -d= -f2 | sed 's/%3B/ /g' | sed 's/%2F/\//g'`"   
MOSTRAR=0


##################################
## CONTROL DE CAMINOS ABSOLUTOS ##
##################################
for i in $PARAMETROS 
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
if [ $CODIGO -eq 0 -o $CODIGO -eq 1 ]   
then
    for i in $PARAMETROS     
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
    if echo "$QUERY_STRING" | egrep -q "&check=t$"          
    then
        /obligatorio/ejercicio2/cgi-bin/search -t $PARAMETROS | tail -2    
    fi
else
    /obligatorio/ejercicio2/cgi-bin/search $PARAMETROS 2>&1                  
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