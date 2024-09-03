import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String text;
  final int value;
  final int relevancy;
  final String set;

  Question({
    required this.text,
    required this.value,
    required this.relevancy,
    required this.set,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
