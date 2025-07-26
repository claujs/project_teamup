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

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    state.maybeWhen(
      loaded: (conversation) async {
        final message = ChatMessage(
          id: '',
          text: text.trim(),
          senderId: 'current_user',
          receiverId: conversation.participantId,
          timestamp: DateTime.now(),
          isMe: true,
        );

        final updatedMessages = [...conversation.messages, message];
        final updatedConversation = conversation.copyWith(
          messages: updatedMessages,
          lastActivity: DateTime.now(),
        );
        state = ChatState.loaded(updatedConversation);

        final result = await _chatRepository.sendMessage(message);
        result.fold(
          (failure) {
            state = ChatState.loaded(conversation);
            state = ChatState.error(failure.message);
          },
          (sentMessage) {
            final confirmedMessages = [...conversation.messages, sentMessage];
            final confirmedConversation = conversation.copyWith(
              messages: confirmedMessages,
              lastActivity: DateTime.now(),
            );
            state = ChatState.loaded(confirmedConversation);

            _listenForAutoResponse(conversation);
          },
        );
      },
      orElse: () {},
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
