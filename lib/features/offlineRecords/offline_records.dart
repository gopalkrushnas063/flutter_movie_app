import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/data/local/db_provider.dart';

class OfflineUsersScreen extends ConsumerWidget {
  // Changed to ConsumerWidget
  const OfflineUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef parameter
    final database = ref.read(databaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Offline Users',
          style: TextStyle(color: Colors.white),
        ),
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
              final lastSync =
                  user['lastSyncAttempt'] != null
                      ? DateFormat(
                        'MMM dd, yyyy - HH:mm',
                      ).format(user['lastSyncAttempt'])
                      : 'Never';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    user['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['job'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            user['synced'] ? Icons.cloud_done : Icons.cloud_off,
                            size: 16,
                            color:
                                user['synced'] ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user['synced']
                                ? 'Synced (ID: ${user['remoteId']})'
                                : 'Pending sync',
                            style: TextStyle(
                              color:
                                  user['synced'] ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Last attempt: $lastSync',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing:
                      user['synced']
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(
                            Icons.sync_problem,
                            color: Colors.orange,
                          ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
