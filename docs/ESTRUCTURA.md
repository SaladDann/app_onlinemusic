```text
app_offline/
│
├── lib/                                      # Código principal de Flutter
│   ├── app.dart                              # Contenedor raíz: tema global, rutas iniciales e interfaz base
│   ├── main.dart                             # Punto de entrada: inicialización de Flutter, servicios y widget raíz
│   │
│   ├── core/                                 # Componentes compartidos y configuración transversal
│   │   ├── appearance_scope.dart              # Propaga estados de apariencia, temas y paletas dinámicas
│   │   ├── dashboard_layout.dart              # Define la estructura visual y distribución responsiva del Dashboard
│   │   ├── format.dart                       # Utilidades de formato, como convertir milisegundos a mm:ss
│   │   ├── log.dart                          # Sistema centralizado de registros y depuración por categorías
│   │   ├── palette.dart                      # Define paletas de colores estáticas y dinámicas
│   │   ├── theme.dart                        # Configura los temas globales claro y oscuro con Material Design
│   │   │
│   │   ├── native_bridge/                    # Comunicación general con la plataforma nativa
│   │   │   └── media_channel_bridge.dart      # Centraliza solicitudes y eventos mediante canales de medios
│   │   │
│   │   └── strings/                          # Textos estáticos compartidos de la interfaz
│   │       ├── access_strings.dart            # Cadenas de texto para permisos y accesos iniciales
│   │       └── dashboard_strings.dart         # Etiquetas y textos del reproductor y del Dashboard
│   │
│   ├── data/                                 # Modelos, persistencia y acceso a datos
│   │   ├── library_database.dart              # Gestiona SQLite para almacenar y recuperar la biblioteca offline
│   │   ├── library_repository.dart             # Coordina el acceso a los datos entre SQLite y los servicios
│   │   ├── play_mode.dart                    # Enumera los modos: normal, repetir todo, repetir una pista y aleatorio
│   │   ├── song.dart                         # Modelo de canción: id, título, artista, álbum, URI, ruta y duración
│   │   │
│   │   ├── permissions/                      # Abstracciones de permisos
│   │   │   ├── media_permission_gateway.dart   # Solicita y verifica permisos para acceder a archivos multimedia
│   │   │   └── permission_gateway.dart         # Define la interfaz genérica para gestionar permisos
│   │   │
│   │   └── playback/                         # Contratos e implementación de reproducción
│   │       ├── audio_player_service.dart       # Contrato de reproducción: play, pause, seek, saltos y estados
│   │       ├── native_audio_player_service.dart # Implementa reproducción mediante MethodChannel y EventChannel
│   │       │
│   │       └── format_pipeline/               # Pipeline de carga y procesamiento de formatos de audio
│   │           ├── alac_cache.dart            # Administra la caché local de archivos ALAC procesados o convertidos
│   │           ├── alac_converter.dart        # Convierte o procesa formatos de audio específicos, como ALAC
│   │           ├── format_service.dart        # Coordina el procesamiento de los formatos de audio compatibles
│   │           ├── preloader.dart             # Precarga audio o metadatos para reducir demoras de reproducción
│   │           └── source_loader.dart         # Localiza y carga las fuentes físicas de los archivos de audio
│   │
│   ├── features/                              # Funcionalidades organizadas por módulos
│   │   │
│   │   ├── appearance/                       # Personalización visual
│   │   │   ├── controllers/
│   │   │   │   └── appearance_controller.dart # Gestiona las preferencias visuales del usuario
│   │   │   │
│   │   │   └── widgets/
│   │   │       └── appearance_settings_sheet.dart # Bottom sheet para cambiar tema, colores y estilo
│   │   │
│   │   ├── dashboard/                        # Interfaz principal del reproductor y biblioteca
│   │   │   ├── controllers/
│   │   │   │   ├── dashboard_controller.dart  # Coordina biblioteca, apariencia y reproducción
│   │   │   │   ├── library_controller.dart    # Gestiona el estado, filtrado y listado de canciones
│   │   │   │   └── playback_controller.dart   # Gestiona el estado lógico de reproducción para la interfaz
│   │   │   │
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart      # Pantalla principal: integra reproductor y biblioteca
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── album_artwork.dart         # Renderiza la carátula del álbum o la imagen de la pista
│   │   │       ├── dashboard_header.dart      # Cabecera con navegación y accesos rápidos
│   │   │       ├── icon_action_button.dart    # Botón reutilizable para acciones representadas por iconos
│   │   │       ├── playback_progress.dart    # Muestra el progreso y permite cambiar la posición de reproducción
│   │   │       ├── player_controls_row.dart   # Agrupa los controles anterior, reproducir/pausar y siguiente
│   │   │       ├── play_pause_button.dart     # Control individual de reproducción y pausa sincronizado con el estado
│   │   │       ├── tinted_background.dart     # Proporciona el fondo visual dinámico del Dashboard
│   │   │       └── track_info_row.dart        # Muestra el título y el artista de la canción actual
│   │   │
│   │   ├── permissions/                      # Flujo de autorización de acceso
│   │   │   ├── controllers/
│   │   │   │   └── access_controller.dart     # Coordina la solicitud y comprobación de permisos de almacenamiento
│   │   │   │
│   │   │   └── screens/
│   │   │       └── permission_screen.dart     # Pantalla que solicita permisos cuando no están concedidos
│   │   │
│   │   └── splash/                           # Inicialización visual de la aplicación
│   │       ├── controllers/
│   │       │   └── splash_controller.dart     # Comprueba permisos y prepara los datos iniciales
│   │       │
│   │       └── screens/
│   │           └── splash_screen.dart         # Pantalla de presentación mostrada durante el inicio
│   │
│   └── services/                             # Servicios compartidos de alto nivel
│       ├── artwork_service.dart              # Extrae, resuelve y proporciona rutas de carátulas de audio
│       └── library_service.dart              # Facilita el escaneo y sincronización de la biblioteca con SQLite
│
└── android/
    └── app/
        └── src/
            └── main/
                └── kotlin/
                    └── com/
                        └── example/
                            └── offline_music/
                                ├── MainActivity.kt
                                │   # Actividad principal: inicializa Flutter y registra los puentes nativos
                                │
                                └── media/     # Operaciones nativas sobre archivos y metadatos multimedia
                                    ├── ArtworkExtractor.kt
                                    │   # Extrae las carátulas incrustadas en los archivos de audio
                                    ├── AudioDecoderChecker.kt
                                    │   # Verifica la disponibilidad y compatibilidad de decodificadores
                                    ├── AudioMimeDetector.kt
                                    │   # Detecta el tipo MIME de los archivos de audio locales
                                    ├── AudioScanner.kt
                                    │   # Escanea el almacenamiento y localiza archivos de música compatibles
                                    ├── AudioWavConverter.kt
                                    │   # Convierte audio a WAV cuando lo requiere el pipeline
                                    ├── MediaChannelHandler.kt
                                    │   # Atiende solicitudes Flutter para escaneo y extracción de metadatos
                                    ├── MediaConstants.kt
                                    │   # Define constantes de canales y metadatos multimedia
                                    ├── WavHeaderWriter.kt
                                    │   # Escribe o corrige cabeceras de archivos WAV procesados
                                    │
                                    └── playback/ # Reproducción nativa en segundo plano
                                        ├── MusicNotificationProvider.kt
                                        │   # Construye y actualiza la notificación multimedia persistente
                                        ├── MusicPlaybackActionReceiver.kt
                                        │   # Recibe acciones de la notificación: play, pausa y siguiente
                                        ├── MusicPlaybackBridge.kt
                                        │   # Conecta Flutter con el servicio nativo de reproducción
                                        ├── MusicPlaybackConstants.kt
                                        │   # Centraliza canales, acciones, estados y claves de metadatos
                                        ├── MusicPlaybackService.kt
                                        │   # Reproduce audio en segundo plano y gestiona cola y sesión multimedia
                                        └── MusicPlaybackStateHolder.kt
                                            # Conserva estados auxiliares del reproductor nativo en memoria

```
----------------------
1. Raíz (lib/)
app.dart: Define el contenedor principal de la aplicación, configurando el tema global, las rutas iniciales y envolviendo la interfaz con los widgets base del sistema de diseño.

main.dart: Punto de entrada de la aplicación. Inicializa los enlaces de Flutter, los servicios principales y lanza el widget raíz definido en app.dart.

2. Capa Core (lib/core/)
appearance_scope.dart: Administra el alcance y la propagación de los estados de apariencia (como temas y paletas de colores dinámicas) a lo largo del árbol de widgets.

dashboard_layout.dart: Establece la estructura visual macro y la distribución responsiva principal de la pantalla del Dashboard.

format.dart: Utilidades y funciones auxiliares para formatear datos comunes, como la conversión de milisegundos a formato de tiempo legible (mm:ss).

log.dart: Sistema centralizado de registro de eventos y depuración por consolas con etiquetas específicas para reproducción, UI y servicios.

palette.dart: Define la paleta de colores base y los esquemas cromáticos estáticos y dinámicos de la aplicación.

theme.dart: Configura los temas visuales globales (modo claro u oscuro) utilizando Material Design.

native_bridge/media_channel_bridge.dart: Puente general para canalizar y comunicar eventos de metadatos o solicitudes auxiliares con la plataforma nativa.

strings/access_strings.dart: Contiene los textos y cadenas estáticas orientadas a las pantallas de permisos y accesos iniciales.

strings/dashboard_strings.dart: Contiene las cadenas de texto y etiquetas utilizadas en la interfaz del reproductor y el Dashboard.

3. Capa de Datos (lib/data/)
library_database.dart: Gestiona la base de datos local SQLite para almacenar y recuperar la biblioteca de canciones de forma offline.

library_repository.dart: Repositorio encargado de coordinar el acceso a los datos musicales entre la base de datos local y los servicios del sistema.

play_mode.dart: Enum que define los modos de reproducción disponibles (orden normal, repetir todo, repetir una pista y aleatorio).

song.dart: Modelo de datos principal que representa una canción con sus propiedades físicas (id, title, artist, album, uri, data, duration, etc.).

permissions/media_permission_gateway.dart: Pasarela específica para solicitar y verificar los permisos de acceso a archivos multimedia en el sistema operativo.

permissions/permission_gateway.dart: Interfaz o pasarela genérica para el manejo de permisos generales de la aplicación.

playback/audio_player_service.dart: Interfaz abstracta que define el contrato estándar de servicios de reproducción multimedia (reproducir, pausar, saltar, seek, etc.).

playback/native_audio_player_service.dart: Implementación concreta de AudioPlayerService que se comunica mediante MethodChannels y EventChannels con el servicio nativo en Kotlin.

playback/format_pipeline/alac_cache.dart: Gestiona la caché local para archivos decodificados o convertidos en formato ALAC.

playback/format_pipeline/alac_converter.dart: Módulo encargado de la conversión o procesamiento de formatos de audio específicos (como ALAC).

playback/format_pipeline/format_service.dart: Orquestador principal del pipeline de formatos de audio compatibles en el dispositivo.

playback/format_pipeline/preloader.dart: Precarga fragmentos de audio o metadatos para optimizar la fluidez de inicio de reproducción.

playback/format_pipeline/source_loader.dart: Localiza y carga la fuente física de los archivos de audio desde el almacenamiento local.

4. Capa de Características (lib/features/)
appearance/controllers/appearance_controller.dart: Controlador de estado para las preferencias visuales y de apariencia elegidas por el usuario.

appearance/widgets/appearance_settings_sheet.dart: Panel flotante (bottom sheet) que permite al usuario modificar los ajustes visuales y de estilo.

dashboard/controllers/dashboard_controller.dart: Orquestador modular principal que coordina la interacción entre la biblioteca, la apariencia y el reproductor en el Dashboard.

dashboard/controllers/library_controller.dart: Administra el estado, filtrado y listado de las canciones visibles en la interfaz de la biblioteca.

dashboard/controllers/playback_controller.dart: Controlador encargado de gestionar el estado lógico de la reproducción multimedia en la interfaz de usuario.

dashboard/screens/dashboard_screen.dart: Pantalla principal ("Coraza Base") que integra todos los componentes visuales del reproductor y la biblioteca.

dashboard/widgets/album_artwork.dart: Widget visual para renderizar la carátula o arte del álbum de la pista en reproducción.

dashboard/widgets/dashboard_header.dart: Cabecera superior del Dashboard con controles de navegación y accesos rápidos.

dashboard/widgets/icon_action_button.dart: Botón de acción genérico basado en iconos para controles secundarios.

dashboard/widgets/playback_progress.dart: Barra de progreso interactiva para visualizar y realizar saltos de posición (seek) en el audio.

dashboard/widgets/player_controls_row.dart: Fila con los botones principales de control de reproducción (anterior, play/pause, siguiente).

dashboard/widgets/play_pause_button.dart: Botón específico de reproducción/pausa con sincronización de estado visual.

dashboard/widgets/tinted_background.dart: Fondo dinámico o estético para el Dashboard.

dashboard/widgets/track_info_row.dart: Muestra la información textual de la canción actual (título y artista).

permissions/controllers/access_controller.dart: Controlador lógico para el flujo de concesión de permisos de almacenamiento.

permissions/screens/permission_screen.dart: Pantalla visual solicitando permisos al usuario cuando aún no han sido concedidos.

splash/controllers/splash_controller.dart: Gestiona la verificación inicial de permisos y carga preliminar de datos en la pantalla de bienvenida.

splash/screens/splash_screen.dart: Pantalla de presentación (Splash Screen) mostrada al iniciar la aplicación.

5. Servicios Globales (lib/services/)
artwork_service.dart: Servicio encargado de extraer, resolver y proveer las rutas de las carátulas e imágenes incrustadas en los archivos de música.

library_service.dart: Servicio de alto nivel para interactuar con la biblioteca local, facilitando el escaneo y sincronización con SQLite.

6. Capa Nativa Android / Kotlin (android/app/src/main/kotlin/com/example/offline_music/)
MainActivity.kt: Actividad principal de Android. Configura e inicializa los motores de Flutter, los puentes de canales multimedia (MediaChannelHandler) y el puente de reproducción (MusicPlaybackBridge).

media/ArtworkExtractor.kt: Utilidad nativa en Kotlin para extraer carátulas directamente de los metadatos de los archivos de audio en el almacenamiento.

media/AudioDecoderChecker.kt: Verifica la compatibilidad y disponibilidad de los decodificadores de audio del dispositivo.

media/AudioMimeDetector.kt: Detecta el tipo MIME de los archivos de audio locales.

media/AudioScanner.kt: Escanea de forma nativa el almacenamiento del dispositivo en busca de archivos de música compatibles.

media/AudioWavConverter.kt: Convierte formatos de audio a WAV cuando el pipeline nativo lo requiere.

media/MediaChannelHandler.kt: Maneja las peticiones de canales nativos enfocados en el escaneo de la biblioteca y extracción de metadatos.

media/MediaConstants.kt: Define las constantes asociadas al canal nativo de medios y metadatos generales.

media/WavHeaderWriter.kt: Escribe o corrige las cabeceras en archivos de audio WAV procesados nativamente.

media/playback/MusicNotificationProvider.kt: Proveedor nativo encargado de construir y actualizar la notificación multimedia persistente en la barra de notificaciones de Android.

media/playback/MusicPlaybackActionReceiver.kt: Receptor de emisiones (BroadcastReceiver) que capta las acciones ejecutadas desde los botones de la notificación flotante (play, pausa, siguiente, etc.).

media/playback/MusicPlaybackBridge.kt: Puente de comunicación nativo que conecta los métodos y eventos de Flutter con el servicio de reproducción en segundo plano (MusicPlaybackService).

media/playback/MusicPlaybackConstants.kt: Catálogo completo de constantes compartidas para canales (offline_music/playback), acciones, estados y llaves de metadatos.

media/playback/MusicPlaybackService.kt: Servicio en segundo plano basado en ExoPlayer (Media3) y NextLib que ejecuta la reproducción de audio física, gestiona la cola y mantiene la sesión activa.

media/playback/MusicPlaybackStateHolder.kt: Contenedor de estado auxiliar en memoria para variables globales del reproductor nativo (como el estado de favoritos).
