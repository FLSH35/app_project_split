// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    text: json['text'] as String,
    value: json['value'] as int,
    relevancy: json['relevancy'] as int,
    set: json['set'] as String,
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'text': instance.text,
  'value': instance.value,
  'relevancy': instance.relevancy,
  'set': instance.set,
};
