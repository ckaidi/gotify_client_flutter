// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gotify_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GotifyMessage _$GotifyMessageFromJson(Map<String, dynamic> json) =>
    GotifyMessage(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      priority: (json['priority'] as num).toInt(),
      appid: (json['appid'] as num).toInt(),
    );

Map<String, dynamic> _$GotifyMessageToJson(GotifyMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'date': instance.date.toIso8601String(),
      'priority': instance.priority,
      'appid': instance.appid,
    };
