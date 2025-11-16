import 'package:json_annotation/json_annotation.dart';

part 'openai_models.g.dart';

@JsonSerializable()
class OpenAIMessage {
  final String role;
  final String content;
  @JsonKey(name: 'function_call')
  final FunctionCall? functionCall;

  const OpenAIMessage({
    required this.role,
    required this.content,
    this.functionCall,
  });

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) =>
      _$OpenAIMessageFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIMessageToJson(this);
}

@JsonSerializable()
class FunctionCall {
  final String name;
  final String arguments;

  const FunctionCall({
    required this.name,
    required this.arguments,
  });

  factory FunctionCall.fromJson(Map<String, dynamic> json) =>
      _$FunctionCallFromJson(json);
  Map<String, dynamic> toJson() => _$FunctionCallToJson(this);
}

@JsonSerializable()
class OpenAIAssistant {
  final String id;
  final String object;
  @JsonKey(name: 'created_at')
  final int createdAt;
  final String name;
  final String? description;
  final String model;
  final String instructions;
  final List<AssistantTool> tools;

  const OpenAIAssistant({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.name,
    this.description,
    required this.model,
    required this.instructions,
    required this.tools,
  });

  factory OpenAIAssistant.fromJson(Map<String, dynamic> json) =>
      _$OpenAIAssistantFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIAssistantToJson(this);
}

@JsonSerializable()
class AssistantTool {
  final String type;
  @JsonKey(name: 'function')
  final FunctionDefinition? function;

  const AssistantTool({
    required this.type,
    this.function,
  });

  factory AssistantTool.fromJson(Map<String, dynamic> json) =>
      _$AssistantToolFromJson(json);
  Map<String, dynamic> toJson() => _$AssistantToolToJson(this);
}

@JsonSerializable()
class FunctionDefinition {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const FunctionDefinition({
    required this.name,
    required this.description,
    required this.parameters,
  });

  factory FunctionDefinition.fromJson(Map<String, dynamic> json) =>
      _$FunctionDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$FunctionDefinitionToJson(this);
}

@JsonSerializable()
class OpenAIThread {
  final String id;
  final String object;
  @JsonKey(name: 'created_at')
  final int createdAt;
  final Map<String, dynamic> metadata;

  const OpenAIThread({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.metadata,
  });

  factory OpenAIThread.fromJson(Map<String, dynamic> json) =>
      _$OpenAIThreadFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIThreadToJson(this);
}

@JsonSerializable()
class OpenAIRun {
  final String id;
  final String object;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'assistant_id')
  final String assistantId;
  @JsonKey(name: 'thread_id')
  final String threadId;
  final String status;
  @JsonKey(name: 'required_action')
  final RequiredAction? requiredAction;

  const OpenAIRun({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.assistantId,
    required this.threadId,
    required this.status,
    this.requiredAction,
  });

  factory OpenAIRun.fromJson(Map<String, dynamic> json) =>
      _$OpenAIRunFromJson(json);
  Map<String, dynamic> toJson() => _$OpenAIRunToJson(this);
}

@JsonSerializable()
class RequiredAction {
  final String type;
  @JsonKey(name: 'submit_tool_outputs')
  final SubmitToolOutputs submitToolOutputs;

  const RequiredAction({
    required this.type,
    required this.submitToolOutputs,
  });

  factory RequiredAction.fromJson(Map<String, dynamic> json) =>
      _$RequiredActionFromJson(json);
  Map<String, dynamic> toJson() => _$RequiredActionToJson(this);
}

@JsonSerializable()
class SubmitToolOutputs {
  @JsonKey(name: 'tool_calls')
  final List<ToolCall> toolCalls;

  const SubmitToolOutputs({
    required this.toolCalls,
  });

  factory SubmitToolOutputs.fromJson(Map<String, dynamic> json) =>
      _$SubmitToolOutputsFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitToolOutputsToJson(this);
}

@JsonSerializable()
class ToolCall {
  final String id;
  final String type;
  @JsonKey(name: 'function')
  final FunctionCall function;

  const ToolCall({
    required this.id,
    required this.type,
    required this.function,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) =>
      _$ToolCallFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCallToJson(this);
}
