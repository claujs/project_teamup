import 'package:dartz/dartz.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../../../core/errors/failures.dart';

class ChatRepositoryImpl implements ChatRepository {
  final List<ChatMessage> _messages = [];
  final Map<String, ChatConversation> _conversations = {};

  ChatRepositoryImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _messages.addAll([
      ChatMessage(
        id: '1',
        text: 'Olá! Como você está?',
        senderId: 'user_123',
        receiverId: 'current_user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        text: 'Oi! Estou bem, obrigado. E você?',
        senderId: 'current_user',
        receiverId: 'user_123',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isRead: true,
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        text: 'Também estou bem! Podemos conversar sobre o projeto?',
        senderId: 'user_123',
        receiverId: 'current_user',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        isRead: true,
        isMe: false,
      ),
    ]);
  }

  @override
  Future<Either<Failure, ChatConversation>> getConversation(
    String participantId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final conversation = ChatConversation(
        id: 'conv_$participantId',
        participantId: participantId,
        participantName: 'Nome do Usuário',
        participantAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
        messages: _messages,
        lastActivity: DateTime.now(),
        isOnline: true,
      );

      _conversations[participantId] = conversation;
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar conversa'));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String conversationId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return Right(List.from(_messages));
    } catch (e) {
      return Left(ServerFailure('Erro ao carregar mensagens'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(ChatMessage message) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final newMessage = message.copyWith(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
      );

      _messages.add(newMessage);

      Future.delayed(const Duration(seconds: 2), () {
        final autoResponse = _generateAutoResponse(newMessage);
        _messages.add(autoResponse);
      });

      return Right(newMessage);
    } catch (e) {
      return Left(ServerFailure('Erro ao enviar mensagem'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      for (int i = 0; i < _messages.length; i++) {
        if (!_messages[i].isMe) {
          _messages[i] = _messages[i].copyWith(isRead: true);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao marcar como lida'));
    }
  }

  ChatMessage _generateAutoResponse(ChatMessage originalMessage) {
    final responses = [
      'Entendi! Vou analisar isso.',
      'Ótima ideia! Vamos implementar.',
      'Concordo totalmente com você.',
      'Deixa eu verificar e te retorno.',
      'Perfeito! Obrigado pela sugestão.',
      'Vou compartilhar isso com a equipe.',
      'Excelente ponto! Não havia pensado nisso.',
      'Sim, faz sentido. Vamos seguir por aí.',
    ];

    final responseText =
        responses[DateTime.now().millisecond % responses.length];

    return ChatMessage(
      id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
      text: responseText,
      senderId: originalMessage.receiverId,
      receiverId: originalMessage.senderId,
      timestamp: DateTime.now(),
      isRead: false,
      isMe: false,
    );
  }
}
