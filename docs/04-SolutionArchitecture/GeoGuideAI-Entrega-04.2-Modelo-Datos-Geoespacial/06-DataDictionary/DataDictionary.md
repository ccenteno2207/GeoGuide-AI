# Diccionario de Datos
## PointOfInterest
id UUID PK
name varchar(200)
category_id UUID
location geometry(Point,4326)
description text
opening_hours varchar
price numeric
website varchar
phone varchar
rating numeric
created_at timestamp
updated_at timestamp
