import 'package:json_annotation/json_annotation.dart';

part 'gotify_message.g.dart';

@JsonSerializable()
class GotifyMessage {
  final int id;
  final String title;
  final String message;
  final DateTime date;
  final int priority;
  final int appid;

  const GotifyMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.priority,
    required this.appid,
  });

  factory GotifyMessage.fromJson(Map<String, dynamic> json) =>
      _$GotifyMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GotifyMessageToJson(this);

  @override
  String toString() {
    return 'GotifyMessage{id: $id, title: $title, message: $message, date: $date, priority: $priority, appid: $appid}';
  }
}