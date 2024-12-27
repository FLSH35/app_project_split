import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String text;
  final int value;
  final int relevancy;
  final String set;
  final String backgroundInfo;
  final int id;

  Question({
    required this.text,
    required this.value,
    required this.relevancy,
    required this.set,
    required this.backgroundInfo,
    required this.id,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
