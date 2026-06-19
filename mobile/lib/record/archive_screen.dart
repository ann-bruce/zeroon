import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_controller.dart';
import 'record_detail_screen.dart';
import 'record_models.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordListProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(recordListProvider),
          child: records.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Archive', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 48),
                Text('读取失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(recordListProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
            data: (page) => _ArchiveList(page: page),
          ),
        ),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  const _ArchiveList({required this.page});

  final RecordPage page;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Archive', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 64),
          Text('还没有归零记录。', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('完成一次 Reset 后，这里会出现你的记录。'),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: page.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archive', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 24),
              Text('已缓存 ${page.totalElements} 条记录'),
            ],
          );
        }
        final record = page.items[index - 1];
        return Card(
          child: ListTile(
            title: Text(
              recordPreview(record),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${record.state} · ${record.createdAt.toLocal()}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordDetailScreen(recordId: record.id),
              ),
            ),
          ),
        );
      },
    );
  }
}
