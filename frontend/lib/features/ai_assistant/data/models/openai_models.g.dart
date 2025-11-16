// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIMessage _$OpenAIMessageFromJson(Map<String, dynamic> json) =>
    OpenAIMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      functionCall: json['function_call'] == null
          ? null
          : FunctionCall.fromJson(
              json['function_call'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIMessageToJson(OpenAIMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'function_call': instance.functionCall,
    };

FunctionCall _$FunctionCallFromJson(Map<String, dynamic> json) => FunctionCall(
      name: json['name'] as String,
      arguments: json['arguments'] as String,
    );

Map<String, dynamic> _$FunctionCallToJson(FunctionCall instance) =>
    <String, dynamic>{
      'name': instance.name,
      'arguments': instance.arguments,
    };

OpenAIAssistant _$OpenAIAssistantFromJson(Map<String, dynamic> json) =>
    OpenAIAssistant(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      model: json['model'] as String,
      instructions: json['instructions'] as String,
      tools: (json['tools'] as List<dynamic>)
          .map((e) => AssistantTool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OpenAIAssistantToJson(OpenAIAssistant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created_at': instance.createdAt,
      'name': instance.name,
      'description': instance.description,
      'model': instance.model,
      'instructions': instance.instructions,
      'tools': instance.tools,
    };

AssistantTool _$AssistantToolFromJson(Map<String, dynamic> json) =>
    AssistantTool(
      type: json['type'] as String,
      function: json['function'] == null
          ? null
          : FunctionDefinition.fromJson(
              json['function'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AssistantToolToJson(AssistantTool instance) =>
    <String, dynamic>{
      'type': instance.type,
      'function': instance.function,
    };

FunctionDefinition _$FunctionDefinitionFromJson(Map<String, dynamic> json) =>
    FunctionDefinition(
      name: json['name'] as String,
      description: json['description'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$FunctionDefinitionToJson(FunctionDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'parameters': instance.parameters,
    };

OpenAIThread _$OpenAIThreadFromJson(Map<String, dynamic> json) => OpenAIThread(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$OpenAIThreadToJson(OpenAIThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created_at': instance.createdAt,
      'metadata': instance.metadata,
    };

OpenAIRun _$OpenAIRunFromJson(Map<String, dynamic> json) => OpenAIRun(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      assistantId: json['assistant_id'] as String,
      threadId: json['thread_id'] as String,
      status: json['status'] as String,
      requiredAction: json['required_action'] == null
          ? null
          : RequiredAction.fromJson(
              json['required_action'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIRunToJson(OpenAIRun instance) => <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created_at': instance.createdAt,
      'assistant_id': instance.assistantId,
      'thread_id': instance.threadId,
      'status': instance.status,
      'required_action': instance.requiredAction,
    };

RequiredAction _$RequiredActionFromJson(Map<String, dynamic> json) =>
    RequiredAction(
      type: json['type'] as String,
      submitToolOutputs: SubmitToolOutputs.fromJson(
          json['submit_tool_outputs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequiredActionToJson(RequiredAction instance) =>
    <String, dynamic>{
      'type': instance.type,
      'submit_tool_outputs': instance.submitToolOutputs,
    };

SubmitToolOutputs _$SubmitToolOutputsFromJson(Map<String, dynamic> json) =>
    SubmitToolOutputs(
      toolCalls: (json['tool_calls'] as List<dynamic>)
          .map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubmitToolOutputsToJson(SubmitToolOutputs instance) =>
    <String, dynamic>{
      'tool_calls': instance.toolCalls,
    };

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => ToolCall(
      id: json['id'] as String,
      type: json['type'] as String,
      function: FunctionCall.fromJson(json['function'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'function': instance.function,
    };
