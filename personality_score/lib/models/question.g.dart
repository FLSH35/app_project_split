// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      text: json['text'] as String,
      value: (json['value'] as num).toInt(),
      relevancy: (json['relevancy'] as num).toInt(),
      set: json['set'] as String,
      backgroundInfo: json['backgroundInfo'] as String,
      id: (json['id'] as num).toInt()
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'text': instance.text,
      'value': instance.value,
      'relevancy': instance.relevancy,
      'set': instance.set,
      'backgroundInfo': instance.backgroundInfo,
      'id' : instance.id
    };
