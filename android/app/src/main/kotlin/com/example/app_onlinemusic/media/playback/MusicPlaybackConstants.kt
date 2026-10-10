//android/app/src/main/kotlin/com/example/offline_music/media/playback/MusicPlaybackConstants
package com.example.offline_music.media.playback

object MusicPlaybackConstants {

    const val METHOD_CHANNEL = "offline_music/playback"
    const val EVENT_CHANNEL = "offline_music/playback_events"

    const val ACTION_PLAY = "com.example.offline_music.playback.PLAY"
    const val ACTION_PAUSE = "com.example.offline_music.playback.PAUSE"
    const val ACTION_TOGGLE = "com.example.offline_music.playback.TOGGLE"
    const val ACTION_NEXT = "com.example.offline_music.playback.NEXT"
    const val ACTION_PREVIOUS = "com.example.offline_music.playback.PREVIOUS"
    const val ACTION_FAVORITE = "com.example.offline_music.playback.FAVORITE"
    const val ACTION_CLOSE = "com.example.offline_music.playback.CLOSE"

    const val NOTIFICATION_CHANNEL_ID = "offline_music_playback"
    const val NOTIFICATION_ID = 1001

    const val EXTRA_FAVORITE = "extra_favorite"

    const val METHOD_SET_LIBRARY = "setLibrary"
    const val METHOD_SET_QUEUE = "setQueue"
    const val METHOD_SET_QUEUE_BY_INDEX = "setQueueByIndex"
    const val METHOD_REPLACE_UPCOMING_QUEUE = "replaceUpcomingQueue"
    const val METHOD_PLAY = "play"
    const val METHOD_PAUSE = "pause"
    const val METHOD_SKIP_NEXT = "skipToNext"
    const val METHOD_SKIP_PREVIOUS = "skipToPrevious"
    const val METHOD_SEEK = "seek"
    const val METHOD_SET_PLAY_MODE = "setPlayMode"
    const val METHOD_SET_SPEED = "setSpeed"
    const val METHOD_SET_FAVORITE = "setFavorite"
    const val METHOD_STOP = "stop"
    const val METHOD_GET_STATE = "getState"

    const val EVENT_STATE = "state"
    const val EVENT_FAVORITE_TOGGLED = "favoriteToggled"

    const val PLAY_MODE_ORDER = "order"
    const val PLAY_MODE_REPEAT_ALL = "repeatAll"
    const val PLAY_MODE_REPEAT_ONE = "repeatOne"
    const val PLAY_MODE_SHUFFLE = "shuffle"

    const val KEY_ID = "id"
    const val KEY_TITLE = "title"
    const val KEY_ARTIST = "artist"
    const val KEY_ALBUM = "album"
    const val KEY_URI = "uri"
    const val KEY_DATA = "data"
    const val KEY_DURATION = "duration"
    const val KEY_MIME_TYPE = "mimeType"
    const val KEY_ARTWORK_URI = "artworkUri"

    const val KEY_SONGS = "songs"
    const val KEY_INDICES = "indices"
    const val KEY_LIBRARY_INDEX = "libraryIndex"
    const val KEY_INITIAL_INDEX = "initialIndex"
    const val KEY_START_POSITION_MS = "startPositionMs"
    const val KEY_POSITION_MS = "positionMs"
    const val KEY_PLAY_MODE = "playMode"
    const val KEY_SPEED = "speed"
    const val KEY_IS_FAVORITE = "isFavorite"

    const val STATE_CURRENT_ID = "currentId"
    const val STATE_IS_PLAYING = "isPlaying"
    const val STATE_POSITION_MS = "positionMs"
    const val STATE_DURATION_MS = "durationMs"
    const val STATE_PLAY_MODE = "playMode"
    const val STATE_INDEX = "index"
    const val STATE_QUEUE_SIZE = "queueSize"
    const val STATE_LIBRARY_INDEX = "libraryIndex"

    const val STATE_UPDATE_INTERVAL_MS = 500L
}
