// lib/data/song.dart//lib/data/song.dart
import 'package:flutter/foundation.dart';

@immutable
class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    this.data,
    required this.duration,
    required this.fileSize,
    this.dateModified = 0,
    required this.mimeType,
    required this.fileName,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String uri;
  final String? data;
  final int duration;
  final int fileSize;
  final int dateModified;
  final String mimeType;
  final String fileName;

  Duration get durationAsDuration => Duration(milliseconds: duration);

  String get formattedDuration {
    final d = durationAsDuration;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? uri,
    String? data,
    int? duration,
    int? fileSize,
    int? dateModified,
    String? mimeType,
    String? fileName,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      uri: uri ?? this.uri,
      data: data ?? this.data,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      dateModified: dateModified ?? this.dateModified,
      mimeType: mimeType ?? this.mimeType,
      fileName: fileName ?? this.fileName,
    );
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    return Song(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Desconocido').toString(),
      artist: (map['artist'] ?? 'Desconocido').toString(),
      album: (map['album'] ?? 'Desconocido').toString(),
      uri: (map['uri'] ?? '').toString(),
      data: rawData?.toString(),
      duration: _toInt(map['duration']),
      fileSize: _toInt(map['fileSize']),
      dateModified: _parseDateModified(map['dateModified']),
      mimeType: (map['mimeType'] ?? 'audio/mpeg').toString(),
      fileName: (map['fileName'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'uri': uri,
      'data': data,
      'duration': duration,
      'fileSize': fileSize,
      'dateModified': dateModified,
      'mimeType': mimeType,
      'fileName': fileName,
    };
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int _parseDateModified(dynamic value) {
    final raw = _toInt(value);
    if (raw <= 0) return 0;
    if (raw < 100000000000) return raw * 1000;
    return raw;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Song(id: $id, title: $title, artist: $artist, dateModified: $dateModified)';
}
