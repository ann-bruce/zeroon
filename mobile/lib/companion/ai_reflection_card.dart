import 'package:flutter/material.dart';

class AiReflectionCard extends StatelessWidget {
  const AiReflectionCard({
    super.key,
    required this.title,
    required this.loading,
    required this.loadingText,
    this.reply,
    this.notice,
    this.error,
    this.retryLabel,
    this.onRetry,
    this.margin,
  });

  final String title;
  final bool loading;
  final String loadingText;
  final String? reply;
  final String? notice;
  final String? error;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (loading)
              Text(loadingText)
            else if (_hasText(error)) ...[
              Text(error!, style: const TextStyle(color: Color(0xFF8A5A00))),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(retryLabel ?? '重试'),
                ),
              ],
            ] else ...[
              Text(reply ?? ''),
              if (_hasText(notice)) ...[
                const SizedBox(height: 12),
                Text(notice!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
