// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
  serverUrl: json['serverUrl'] as String? ?? '',
  clientToken: json['clientToken'] as String? ?? '',
  enableNotifications: json['enableNotifications'] as bool? ?? true,
  autoConnect: json['autoConnect'] as bool? ?? false,
  connectionTimeoutSeconds:
      (json['connectionTimeoutSeconds'] as num?)?.toInt() ?? 30,
);

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
  'serverUrl': instance.serverUrl,
  'clientToken': instance.clientToken,
  'enableNotifications': instance.enableNotifications,
  'autoConnect': instance.autoConnect,
  'connectionTimeoutSeconds': instance.connectionTimeoutSeconds,
};
