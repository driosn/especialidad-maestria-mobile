#Instrucciones de proyecto

#Reglas de codigo
Haz uso de sealed classes para estados de cubit
Usa cubit


#Arquitectura
Utilizar una arquitectura por capas sencilla que tenga
Data
- Services
- Models

Presentation
- Screens
- Cubits



#Gestion de estado
Para el proyecto es necesario que se haga uso de gestion de estado

#Inyección de dependencias
Hacer uso de get_it, para manejar la inyección de dependencias

#Separacion de Widgets
Cada vez que crees una pantalla, los widgets principales tienen que estar separados en clases a parte

Si es posible para cada pantalla crear una carpeta, es decir
carpeta login, etc, y que dentro de esa carpeta existan widgets por modulo para realizar una correcta separacion