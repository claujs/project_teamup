import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatConversation>> getConversation(
    String participantId,
  );
  Future<Either<Failure, List<ChatMessage>>> getMessages(String conversationId);
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message);
  Future<Either<Failure, void>> markAsRead(String conversationId);
}
