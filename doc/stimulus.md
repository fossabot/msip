# Uso de controladores Stimulus de motores rails

En aplicaciones es típico que los controladores stimulus se ubiquen
en `app/javascript/controllers` pero en motores no hay una sugerencia
ni un mecanismo proveido por rails para cargar los controladores stimulus
de motores.

Usando `esbuild` nos ha funcionado emplear `--preserve-symlinks` y
enlaces desde la aplicación a los controladores de los motores. Por eso
sip provee la tarea rake `msip:stimulus_motores` que crea los enlaces.

Si el motor `mi_motor` define el controlador `miControlador` en su
directorio `app/javascript/controllers`, al ejecutar
```
bin/rails msip:stimulus_motores
``` 
en una aplicación (o en la aplicación de prueba del motor) la ruta
`app/javascript/controllers/mi_motor` será un enlace
al directorio `app/javascript/controllers` de `mi_motor`, por esto
desde la aplicación se podrá referenciar con
`mi-motor--mi-controlador`

Un ejemplo más concreto es el controlador stimulus 
`cancelar_vacio_es_eliminar` incluido en el motor msip en
`app/javascript/controllers/cancelar_vacio_es_eliminar.js` 
el cual cambia el comportamiento de un botón cancelar de un formulario
de edición para que elimine si se determina que el formulario
está vacío.

Desde aplicaciones (o motores que incluyan msip) que lo empleen
en el HTML se conectaría el controlador a un formulario añadiendole
```
data-controller="msip--cancelar-vacio-es-eliminar"
```
Hay otros elementos HTML que deberán marcarse para que ese controlador opere
bien como puede verse en sus fuentes, pero todos son de la forma 
`data-msip--cancelar-vacio-es-eliminar...=...`.
