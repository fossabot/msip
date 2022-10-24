Una tabla asociativa (que tambien hemos llamado tabla combinada o tabla unión) permite asociar dos o más tablas en una relación muchos a muchos. 

Si la tabla asociativa no va a tener información adicional a las llaves foráneas de las tablas que asocia y si en la vista se desea presentar como un
cuadro de selección (o tal vez cajas de chequeo), lo más recomendable con rails sería crear una tabla sin campo `id` ni marcas de tiempo pero para evitar duplicaciones es importante agregarle como llave primaria la combinación de las llaves foráneas.

Si la tabla asociativa va a tener información adicional, lo recomendable es que tenga un campo id y puede emplearse cocoon para 
hacer un formulario anidado que facilite diligenciarla.


# 1. Tabla asociativa sólo con las llaves foráneas de las tablas que asocia


El ejemplo de usuarios y permisos de https://es.wikipedia.org/wiki/Entidad_asociativa se podría implementar (agregando campo id a las tablas Usuarios y Permisos) con:
```
% bin/rails g migration CreateUsuario LoginUsuario:string:50 ContrasenaUsuario:string:50 NombreUsuario:string:50
% bin/rails g migration CreatePermiso LlavePermiso:string:50 DescripcionPermiso:string:500 NombreUsuario:string:50
```

Por ejemplo la primera crearía una migración con un nombre como `20210924144641_create_usuario.rb`:
```rb
class CreateUsuario < ActiveRecord::Migration[6.1]                         
  def change                                                                     
    create_table :usuarios do |t|                                          
      t.string :LoginUsuario                                                     
      t.string :ContrasenaUsuario                                                
      t.string :NombreUsuario                                                    
                                                                                 
      t.timestamps                                                               
    end                                                                          
  end                                                                            
end       
```
Y al correrse la migración con `bin/rails db:migrate` crearía una tabla que podría examinarse desde la consola de `psql`:
```
% bin/rails dbconsole
psql (13.4)
Type "help" for help.

[local:/var/www/var/run/postgresql] isa5417@minmsip_des=# \d usuarios
                                             Table "public.usuarios"
      Column       |              Type              | Collation | Nullable |               Default                
-------------------+--------------------------------+-----------+----------+--------------------------------------
 id                | bigint                         |           | not null | nextval('usuarios_id_seq'::regclass)
 LoginUsuario      | character varying              |           |          | 
 ContrasenaUsuario | character varying              |           |          | 
 NombreUsuario     | character varying              |           |          | 
 created_at        | timestamp(6) without time zone |           | not null | 
 updated_at        | timestamp(6) without time zone |           | not null | 
Indexes:
    "usuarios_pkey" PRIMARY KEY, btree (id)

[local:/var/www/var/run/postgresql] isa5417@minmsip_des=#
```

Lo análogo ocurre con `permisos`.

La tabla combinada que referenciaría los campos id de Usuarios y Permisos, es recomendable que el 
nombre sea el de las tablas que asocia (en orden lexicográfico) separadas por raya al piso y se haría con:
```
% bin/rails g migration CreateJoinTablePermisoUsuario permiso usuario
```
que generaría la migración:
```
class CreateJoinTablePermisoUsuario < ActiveRecord::Migration[6.1]               
  def change                                                                     
    create_join_table :permisos, :usuarios do |t|                                
      # t.index [:usuario_id, :permiso_id]                                       
      # t.index [:permiso_id, :usuario_id]                                       
    end                                                                          
  end                                                                            
end 
```
Y que recomendamos modificar para referenciar las tablas que asocia y definir la combianción de las llaves foraneas como llavea primaria (esto último evitaría que se duplique información en la tabla asociativa, cuando se importe masivamente en SQL reiteradas veces la misma información):
```
class CreateJoinTablePermisoUsuario < ActiveRecord::Migration[6.1]               
  def up                                                                     
    create_join_table :permisos, :usuarios do |t|                                
    end
    add_foreign_key :permisos_usuarios, :permisos
    add_foreign_key :permisos_usuarios, :usuarios
    execute 'ALTER TABLE permisos_usuarios ADD CONSTRAINT "permisos_usuarios_pkey1" PRIMARY KEY(usuario_id, permiso_id)'
  end                                                                            
  def down
    drop_table :permisos
  end
end 
```
que al ejecutarse generaría la tabla `permisos_usuarios` (porque deja primero la tabla lexicograficamente menor)
```
           Table "public.permisos_usuarios"
   Column   |  Type  | Collation | Nullable | Default 
------------+--------+-----------+----------+---------
 permiso_id | bigint |           | not null | 
 usuario_id | bigint |           | not null | 
Indexes:
    "permisos_usuarios_pkey1" PRIMARY KEY, btree (usuario_id, permiso_id)
Foreign-key constraints:
    "fk_rails_9a877c317d" FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    "fk_rails_e51795c582" FOREIGN KEY (permiso_id) REFERENCES permisos(id) 
```

# 2. Tabla asociativa con información además de llaves foráneas

Aunque es posible usar una tabla asociativa sin campo `id` tendría que usarse código adicionale a la hora de actualizar y eliminar registros en el controlador
de la vista donde se edite.  Por eso sugerimos agregar a la tabla el campo `id` como llave primaria y usar un formulario anidado con `cocoon` como se explica en {1}

# 3. Referencias

* {1} https://dhobsd.pasosdejesus.org/formularios-anidados-en-rails-con-cocoon.html
