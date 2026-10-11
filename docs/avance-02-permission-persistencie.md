# Avance 02: Permisos Persistentes, Tubería de Decodificación y Base de Datos Local

**Fecha y hora de validación:** 2026-10-06 (Actualizado a 2026-10-10 con Persistencia de Permisos, Caché SQLite y Tubería ALAC)
**Estado:** Validado y Compilado en Dispositivo Físico (Infinix X669)

## Objetivos del Avance
1. **Gestión de Permisos Persistentes:** Implementación de pasarelas de permisos y control de arranque inteligente para evitar solicitudes repetitivas en cada inicio de sesión.

2. **Persistencia Local con SQLite (LibraryDatabase):** Indexación masiva y atómica de la biblioteca de canciones para lograr un arranque instantáneo sin consultas repetitivas al MediaStore.

3. **Tubería de Formatos y Caché ALAC:** Incorporación de servicios de análisis de códecs (FormatService), gestión de caché temporal de archivos WAV (AlacCache), conversión nativa (AlacConverter) y precalentamiento anticipado (Preloader).

4. **Optimización del Flujo de Arranque (SplashController):** Integración de una validación dual que evalúa el estado del sistema y la base de datos local para transicionar eficientemente hacia el Dashboard de prueba.

5. **Verificación en Dispositivo Real:** Pruebas de compilación exitosas y resolución de incidencias de tipos en los canales de plataforma nativos de AndroidX Media3 / ExoPlayer.

## Cambios Realizados
- **Capa de Datos y Permisos (lib/data/):**

- `permissions/permission_gateway.dart & media_permission_gateway.dart:` Contratos e implementación nativa para la solicitud y validación de accesos de audio y almacenamiento.

- `library_database.dart:` Base de datos SQLite optimizada para transacciones atómicas e indexación rápida de pistas.

- `song.dart:` Modelo de datos inmutable altamente robusto con utilidades de formato de duración, parseo seguro de metadatos y métodos de comparación.

- **Tubería de Reproducción y Formatos (lib/data/playback/format_pipeline/):**

- `format_service.dart:` Servicio de análisis y sondeo de tipos MIME y capacidades de decodificación nativa de Android.

- `alac_converter.dart & alac_cache.dart:` Pasarela y almacenamiento temporal en disco para la conversión y reutilización de archivos de audio complejos (ALAC a WAV).

- `preloader.dart & source_loader.dart:` Estrategias de precarga asíncrona (look-ahead) y preparación inteligente de fuentes directas o de respaldo.

- **Controladores y Pantallas de Característica (lib/features/):**

- `splash/controllers/splash_controller.dart & splash_screen.dart:` Lógica de arranque inteligente con redirección condicionada por caché local y permisos.

- `dashboard/controllers/dashboard_controller.dart & dashboard_screen.dart:` Vista preliminar provisional de diagnóstico y conteo de pistas de audio detectadas.

## Registros de Validación (Logs)
- `[App] Iniciando offline_music en modo visual preliminar`

- `[Splash] Splash visual iniciado con control de persistencia`

- `[Splash] Iniciando verificación de permisos y diagnóstico del dispositivo...`

- `[Splash] Permisos y caché local detectados. Cargando biblioteca desde SQLite...`

- `[Library] Escaneo nativo completado. Se encontraron 1612 pistas.`

- `[Splash] Arranque optimizado completado. Canciones cargadas: 1612, Destino: Dashboard.`
