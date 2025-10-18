// lib/features/ai_assistant/presentation/widgets/chat_message_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final bool isError = message.isError;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isError
              ? (isDark
                    ? Colors.red.shade900.withOpacity(0.3)
                    : Colors.red.shade50)
              : isUser
              ? colorScheme.primary
              : (isDark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(
                message.text,
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
              )
            else
              MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isError
                        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                        : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  h2: TextStyle(
                    color: isError
                        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                        : colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: TextStyle(
                    color: isError
                        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                        : colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  listBullet: TextStyle(
                    color: isError
                        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                        : colorScheme.onSurface,
                  ),
                  strong: TextStyle(
                    color: isError
                        ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                        : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  em: const TextStyle(fontStyle: FontStyle.italic),
                  code: TextStyle(
                    backgroundColor: isError
                        ? (isDark
                              ? Colors.red.shade900.withOpacity(0.3)
                              : Colors.red.shade100)
                        : (isDark
                              ? colorScheme.surfaceContainer
                              : Colors.grey.shade200),
                    fontFamily: 'monospace',
                    color: colorScheme.onSurface,
                  ),
                  blockquote: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.recommendedSpecialization != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.recommendedSpecialization!,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: isUser
                        ? colorScheme.onPrimary.withOpacity(0.7)
                        : colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
