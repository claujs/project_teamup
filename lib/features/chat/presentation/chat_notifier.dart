import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/entities/chat_conversation.dart';
import '../domain/entities/chat_message.dart';
import '../domain/repositories/chat_repository.dart';

part 'chat_notifier.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState.initial() = _Initial;
  const factory ChatState.loading() = _Loading;
  const factory ChatState.loaded(ChatConversation conversation) = _Loaded;
  const factory ChatState.error(String message) = _Error;
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  String? _currentConversationId;

  ChatNotifier(this._chatRepository) : super(const ChatState.initial());

  Future<void> loadConversation(
    String participantId,
    String participantName,
    String participantAvatar,
  ) async {
    state = const ChatState.loading();

    final result = await _chatRepository.getConversation(participantId);
    result.fold((failure) => state = ChatState.error(failure.message), (
      conversation,
    ) {
      _currentConversationId = conversation.id;
      final updatedConversation = conversation.copyWith(
        participantName: participantName,
        participantAvatar: participantAvatar,
      );
      state = ChatState.loaded(updatedConversation);
    });
  }

  Future<bool> sendMessage(String text) async {
    if (!_isValidMessage(text)) return false;

    state.maybeWhen(
      loaded: (conversation) async {
        final message = _createMessage(text, conversation.participantId);
        final updatedConversation = _addMessageToConversation(
          conversation,
          message,
        );
        state = ChatState.loaded(updatedConversation);

        final result = await _chatRepository.sendMessage(message);
        result.fold(
          (failure) {
            state = ChatState.loaded(conversation);
            state = ChatState.error(failure.message);
          },
          (sentMessage) {
            final confirmedConversation = _addMessageToConversation(
              conversation,
              sentMessage,
            );
            state = ChatState.loaded(confirmedConversation);
            _listenForAutoResponse(conversation);
          },
        );
      },
      orElse: () {},
    );
    return true;
  }

  bool _isValidMessage(String text) {
    return text.trim().isNotEmpty;
  }

  ChatMessage _createMessage(String text, String receiverId) {
    return ChatMessage(
      id: '',
      text: text.trim(),
      senderId: 'current_user',
      receiverId: receiverId,
      timestamp: DateTime.now(),
      isMe: true,
    );
  }

  ChatConversation _addMessageToConversation(
    ChatConversation conversation,
    ChatMessage message,
  ) {
    final updatedMessages = [...conversation.messages, message];
    return conversation.copyWith(
      messages: updatedMessages,
      lastActivity: DateTime.now(),
    );
  }

  void _listenForAutoResponse(ChatConversation conversation) {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _refreshMessages();
      }
    });
  }

  Future<void> _refreshMessages() async {
    if (_currentConversationId == null) return;

    final result = await _chatRepository.getMessages(_currentConversationId!);
    result.fold((failure) => state = ChatState.error(failure.message), (
      messages,
    ) {
      state.maybeWhen(
        loaded: (conversation) {
          final updatedConversation = conversation.copyWith(
            messages: messages,
            lastActivity: DateTime.now(),
          );
          state = ChatState.loaded(updatedConversation);
        },
        orElse: () {},
      );
    });
  }

  Future<void> markAsRead() async {
    if (_currentConversationId == null) return;

    await _chatRepository.markAsRead(_currentConversationId!);
  }
}
