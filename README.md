# Equilibra Mobile

<p align="center">
  <strong>App móvil de bienestar y seguimiento de salud</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
</p>

---

## Descripción

**Equilibra** es una aplicación móvil desarrollada en Flutter para el seguimiento del bienestar y la salud. Permite registrar alimentación, ejercicio, sueño y visitas médicas, con soporte offline y sincronización con Firebase. Incluye estadísticas mensuales y notificaciones push.

---

## Funcionalidades principales

| Módulo | Descripción |
|--------|-------------|
| **Inicio** | Dashboard con resumen del día y actividad reciente |
| **Alimentación** | Registro de comidas por tipo (desayuno, comida, cena, etc.) con ingredientes y resumen nutricional |
| **Ejercicio** | Registro de ejercicios realizados con duración e intensidad |
| **Sueño** | Registro de períodos de sueño con horarios y totales |
| **Citas médicas** | Historial de visitas médicas con fecha, motivo y notas |
| **Estadísticas** | Gráficas mensuales de nutrición, ejercicio y sueño (acceso desde el menú de perfil) |
| **Sincronización** | Cola de operaciones pendientes cuando no hay conexión; sincronización manual al recuperar internet |

### Autenticación y perfil

- **Login** y **registro** con Firebase Auth (email/contraseña)
- **Perfil** en drawer lateral: nombre, email, enlaces a Estadísticas y Sincronización, y cerrar sesión
- **Notificaciones push** (Firebase Cloud Messaging) con token e inicialización al arranque

---

## Stack técnico

- **Framework:** Flutter (SDK ^3.11)
- **Estado:** Cubit + sealed classes (`flutter_bloc`)
- **Inyección de dependencias:** GetIt
- **Backend:** Firebase (Auth, Firestore, Cloud Messaging)
- **Gráficas:** fl_chart
- **Almacenamiento local:** SharedPreferences (cola offline)
- **Conectividad:** connectivity_plus
- **Notificaciones locales:** flutter_local_notifications, permission_handler

---

## Arquitectura

El proyecto sigue una **arquitectura por capas** sencilla:

```
lib/
├── data/                    # Capa de datos
│   ├── models/              # Modelos de dominio (User, Meal, Exercise, Sleep, etc.)
│   └── services/            # Servicios (Auth, Firestore, offline, red)
├── di/                      # Inyección de dependencias (GetIt)
│   └── injection.dart
├── presentation/
│   ├── cubits/              # Lógica de estado (Auth, Alimentación, Ejercicio, Sueño, Visitas médicas)
│   ├── screens/             # Pantallas por módulo (carpeta por pantalla + widgets)
│   └── theme/               # Colores y tema (AppColors)
├── services/                # Servicios globales (notificaciones)
├── firebase_options.dart    # Configuración Firebase (generado)
└── main.dart
```

- **Cubits** con **sealed classes** para los estados.
- Cada pantalla tiene su **carpeta** con widgets separados por módulo.
- Servicios en `data/services` para Auth, comidas, ejercicios, sueño, visitas médicas, ingredientes por defecto, tipos de comida, red y cola offline.

---

## Cómo ejecutar el proyecto

### Requisitos

- **Flutter** 3.11 o superior ([instalación](https://docs.flutter.dev/get-started/install))
- **Cuenta Firebase** y un proyecto con Auth, Firestore y Cloud Messaging configurados
- **Android:** Android Studio / SDK (minSdk 23 según `pubspec.yaml`)
- **iOS:** Xcode (si vas a correr en iOS)

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repo>
   cd equilibra_mobile
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   - Añade una app Android y/o iOS y descarga los archivos de configuración.
   - Coloca `google-services.json` en `android/app/` y el `GoogleService-Info.plist` en `ios/Runner/`.
   - Si usas FlutterFire CLI:
     ```bash
     dart run flutterfire configure
     ```
     Esto generará/actualizará `lib/firebase_options.dart`.

4. **Ejecutar la app**
   ```bash
   # Listar dispositivos
   flutter devices

   # Ejecutar en el dispositivo/emulador por defecto
   flutter run

   # O especificar dispositivo
   flutter run -d <device_id>
   ```

5. **Build de release (opcional)**
   ```bash
   flutter build apk        # Android
   flutter build ios        # iOS (en macOS)
   ```

---

## Lo que se implementó

- **Autenticación:** Login, registro y cierre de sesión con Firebase Auth; redirección automática según estado de autenticación.
- **Navegación:** Home con 5 tabs (Inicio, Alimentación, Ejercicio, Sueño, Citas médicas) y drawer de perfil.
- **Módulos de datos:** Servicios que leen/escriben en Firestore para usuarios, comidas, ejercicios, sueño y visitas médicas; uso de ingredientes y tipos de comida por defecto.
- **Modo offline:** Detección de red con `connectivity_plus`; operaciones creadas sin conexión se guardan en SharedPreferences y se sincronizan manualmente desde la pantalla de Sincronización cuando hay internet.
- **Estadísticas:** Pantalla de estadísticas mensuales con gráficas (nutrición, ejercicio, sueño) accesible desde el drawer.
- **Notificaciones:** Inicialización de FCM y notificaciones locales al arrancar la app.
- **UI/UX:** Tema Material 3, paleta propia en `AppColors`, widgets reutilizables por pantalla y navegación inferior con iconos y etiquetas.

---

## Estructura de pantallas (resumen)

| Ruta / Pantalla | Descripción |
|-----------------|-------------|
| `LoginScreen` | Formulario de login |
| `RegisterScreen` | Formulario de registro |
| `HomeScreen` | Contenedor con tabs + drawer |
| `InicioScreen` | Dashboard (resumen del día, actividad reciente) |
| `AlimentacionScreen` | Lista de comidas, navegación por fecha, resumen nutricional |
| `EjercicioScreen` | Lista de ejercicios, navegación por fecha |
| `SuenoScreen` | Períodos de sueño, totales |
| `CitasMedicasScreen` | Lista de visitas médicas |
| `EstadisticasScreen` | Gráficas mensuales (desde drawer) |
| `SincronizacionScreen` | Pendientes offline y botón de sincronizar (desde drawer) |

---

## Licencia

Proyecto de uso educativo / Maestría. Consulta el repositorio para más detalles.
