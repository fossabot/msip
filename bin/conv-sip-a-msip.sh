#!/bin/sh
# Convierte uso de sip a msip

echo "Cambiando directorios"
for i in `find . -name sip -type d`; do 
  echo $i
  n=`echo $i | sed -e "s/sip/msip/g"`
  git mv $i $n
done

for i in `git ls-tree -r main --name-only`; do 
  echo $i | grep "db/migrate" > /dev/null 2>&1
  if (test "$?" = "0") then {
    echo "Excluyendo de conversión $i"
  } else {
    n=`echo $i | sed -e "s/\([^A-Za-z]\)\(sip[^A-Za-z]\)/\1m\2/g"`
    if (test "$n" != "$i") then {
      echo "Cambiando archivo $i->$n"
      git mv $i $n
    } fi;
   grep "sip" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando sip como palabra en $n";
      sed -i -e "s/\([^A-Za-z]\)\(sip[^A-Za-z]\)/\1m\2/g" $n
      sed -i -e "s/^\(sip[^A-Za-z]\)/m\2/g" $n
      sed -i -e "s/\([^A-Za-z]\)\(sip\)$/\1m\2/g" $n
    } fi;
    grep "Sip" $n > /dev/null
    if (test "$?" = "0") then {
      echo "Remplazando Sip como palabra en $n";
      sed -i -e "s/\([^A-Za-z]\)S\(ip[^A-Za-z]\)/\1Ms\2/g" $n
      sed -i -e "s/S\(ip[^A-Za-z]\)/Ms\1/g" $n
      sed -i -e "s/\([^A-Za-z]\)S\(ip\)$/\1Ms\2/g" $n
    } fi;
  } fi;
done
