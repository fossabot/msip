# Personalización de modelos

Casi todos están en el espacio de nombres `Msip` excepto `usuario` y `ability`
(usados por Devise y CanCan sin espacio de nombres).  Por esto se usan 2
técnicas para personalizar modelos:

### Mixins

Se usa con todas las tablas en espacio de nombres `msip_`, por lo cual
se definen de verdad en `lib/msip/concerns/models` y en `app/models/msip`
sólo  se incluyen.

Si motores descendientes de `msip` deben modificarlos, se espera que usen la
misma técnica, recordando que `concerns/models/mimodelo` puede incluir el
módulo de msip ubicado en `lib/msip/concerns/models/mimodelo`.   Ver por
ejemplo <https://gitlab.com/pasosdeJesus/sivel2_gen/blob/master/lib/sivel2_gen/concerns/models/etiqueta.rb>

Una aplicación que requiera modificar uno de estos modelos tiene dos
posibilidades: (1) Crear un decorador en `app/decorators/msip/mimodelo.rb` o
(2) definir la clase nuevamente en `app/models/msip/mimodelo.rb` e incluir
el módulo de msip ubicado en `lib/msip/concerns/models/mimodelo`.
Por uniformidad y para facilitar la conversión de aplicaciones en motores
preferimos el segundo método.

Las tablas básicas no requieren que se definan vistas, sino que su modelo
incluya `Msip::Basica` y que su  controlador sea descendiente de
`Msip::Admin::BasicasController`, ver [Tablas Básicas](https://gitlab.com/pasosdeJesus/msip/blob/master/doc/tablas-basicas.md)

### Tablas unión

Si la tabla unión que está planeando crear, sólo relacionará registros entre
tablas existentes, sin requerir información adicional, no será indispensable
que tenga un campo `id`.  Pero si requiere poner información adicional en
esa tabla unión, si debe tener campo `id`.

Las tablas unión que `rails` genera con `create_join_table`:
* No tienen llave primaria `id` (es una llave compuesta por las referencias),
  por eso no debe llamarse el método `destroy` en objetos de estas.
* Las asociaciones (e.g `has_many`) que se definan a estas tablas en los
  modelos de otras tablas (las que se unen) deben usar `dependent: delete_all`
  en lugar de `dependent: destroy`
* Puede servir como `join_table` en asociaciones `has_and_belongs_to_many`,
  por ejemplo si se hiciera una tabla unión entre `msip_orgsocial` y
  `lineabase` en el modelo `msip_orgsocial`:
```
has_and_belongs_to_many :lineabase,
  class_name: '::Lineabase',
  foreign_key: 'orgsocial_id',
  association_foreign_key: 'lineabase_id',
  join_table: 'lineabase_orgsocial'
```
* En el controlador de `msip_orgsocial` en `atributos_index` se incluiría
  `lineabase_ids` y en `atributos_show` y `atributos_form` se incluye
  `[:lineabase_ids => []]`

Para generar una tabla unión sin un campo `id` sugerimos:
```
bin/rails g migration create_orgsocial_lineabase
```
Editar la migración generado y definir algo como lo siguiente (puede que
no requiera renombramientos en su caso, ni homologación de información):
```
 def up
    create_join_table :msip_orgsocial, :linebase,
      table_name: 'orgsocial_lineabase'
    add_foreign_key :orgsocial_lineabase, :msip_orgsocial
    add_foreign_key :orgsocial_lineabase, :lineabase
    rename_column :orgsocial_lineabase, :msip_orgsocial_id,
      :orgsocial_id
    execute <<-SQL
      INSERT INTO orgsocial_linebase
        (orgsocial_id, lineabase_id)
        (SELECT  id, 1 FROM msip_orgsocial WHERE lineabase20182021='t');
    SQL
  end
  def down
    drop_table :orgsocial_lineabase
  end
```

### Herencia con `ability` y `usuarios`

Por si se quiere usar el método de mixins, al igual que en otros modelos se
definen `lib/msip/concerns/models/{ability,usuario}.rb` y en
`app/models/msip/{ability,usuario}.rb` sólo se incluyen.   Las vistas de
usuario se definen en `app/views/msip/usuarios,` incluyendo una vista
parcial `_usuario.html.erb`

En motores descendientes podría usarse la misma técnica, pero es más breve
definir `app/models/mimotor/{ability,usuario}.rb` como clases descendientes
de Msip::Ability y Msip::Usuario respectivamente y personalizar.  Pueden
personalizarse las vistas de usuarios redefiniéndolas en
`app/views/mimotor/usuarios`, puede aprovechar la vista parcial, como se
hace en <https://gitlab.com/pasosdeJesus/cor1440_gen/tree/master/app/views/cor1440_gen/usuarios>

Se espera que las aplicaciones creen `app/models/ability.rb` y
`app/models/usuario.rb` que hereden respectivamente de `Msip::Ability` y
`Msip::Usuario` (o sus equivalentes en otros motores descendientes de msip,
como por ejemplo <https://gitlab.com/pasosdeJesus/cor1440/blob/master/app/models/ability.rb>
y <https://gitlab.com/pasosdeJesus/cor1440/blob/master/app/models/usuario.rb>).

En la tabla usuario no puede sobrecargarse la validación de mínima longitud,
por lo que se ha introducido la constante  `longitud_nusuario` en
`lib/msip/engine.rb` (inicialmente en valor 15) que una aplicación puede
sobrecargar en `config/initializers/msip.rb`  (ver por ejemplo
<https://gitlab.com/pasosdeJesus/sal7711_cinep/blob/master/config/initializers/msip.rb.plantilla>).

Una convención respecto a permiso de ingresar a la página principal por
parte de un usuario autenticado es que tenga la habilidad de CanCan
`:contar,  Msip::Ubicacion` Por esto en motores que sobrecargen la función
`initialize` de `ability.rb` debe asegurarse de permitir esta operación a
`app/models/usuario.rb` que hereden respectivamente de `Msip::Ability` y 
todos los usuarios:
```
  can :contar, Msip::Ubicacion
```
