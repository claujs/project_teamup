import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_message.dart';

part 'chat_conversation.freezed.dart';
part 'chat_conversation.g.dart';

@freezed
class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    required String participantId,
    required String participantName,
    required String participantAvatar,
    required List<ChatMessage> messages,
    required DateTime lastActivity,
    @Default(true) bool isOnline,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
}
