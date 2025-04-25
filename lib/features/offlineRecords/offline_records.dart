import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/data/local/db_provider.dart';


class OfflineUsersScreen extends ConsumerWidget {  // Changed to ConsumerWidget
  const OfflineUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // Added WidgetRef parameter
    final database = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Users'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: database.getLocalUsersWithStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offline users found'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final lastSync = user['lastSyncAttempt'] != null 
                  ? DateFormat('MMM dd, yyyy - HH:mm').format(user['lastSyncAttempt']) 
                  : 'Never';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['job']),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            user['synced'] ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color: user['synced'] ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user['synced'] 
                                ? 'Synced (ID: ${user['remoteId']})' 
                                : 'Pending sync',
                            style: TextStyle(
                              color: user['synced'] ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text('Last attempt: $lastSync', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: user['synced']
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.sync_problem, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
    );
  }
}