# Facilidades para un controlador descendiente de Msip::ModelosController

La principal funcionalidad de msip para controladores descendientes
de `Msip::ModelosController` son vistas más automáticas, como se describe en:
<https://gitlab.com/pasosdeJesus/msip/blob/main/doc/vistas-automaticas.md>

Pero hay otras facilidades disponibles que aquí se describen.


## Validar datos en el controlador

En rails las validaciones de datos deben hacerse en el modelo, sin embargo 
hay situaciones en las que debe hacerse la validación a nivel de controlador
al crear o al actualizar un registro (un ejemplo es el modelo `Msip::Persona`
que en general no requiere documento de identidad, pero que para un cierto 
formulario deba requerirse).

En tal situación su controlador puede sobrecargar la función 
`validaciones` que recibe el objeto por crear o actualizar y que debe
retornar `true` si y solo si es válido.

Cuando esta función retorne `false`, no se creará ni actualizará el
registro, sino que se volverá a editar y se presentará como notificación
el mensaje de error que se deje en la variable de instancia
`@validaciones_error`.  Un ejemplo de su uso es:

```rb
def validaciones(registro)
  if params[:persona][:numerodocumento].blank?
    @validaciones_error = "Se requiere número de documento" 
    return false
  end
  return true
end
```

## Evitar eliminación de registros referenciados por otras tablas

El método destroy de este controlador, puede recibr un parámetro 
`verifica_tablas_union`, en caso de ser verdadero, antes de la eliminación
revisa si el registro está referenciado en otras tablas y en caso
afirmativo impide la eliminacin y presenta un mensaje indicado las tablas
en la que el registro es referenciado y cuantas veces en cada una.
