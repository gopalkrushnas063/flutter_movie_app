
// lib/features/users/views/user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/views/movie_list_screen.dart';
import 'package:movie_app/features/users/controllers/user_controller.dart';
import 'package:movie_app/features/users/viewModels/user_view_model.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userControllerProvider.notifier).getUsers();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(userControllerProvider.notifier).getUsers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(
              userState.isOnline ? Icons.wifi : Icons.wifi_off,
              color: userState.isOnline ? Colors.green : Colors.red,
            ),
            onPressed:
                () =>
                    ref
                        .read(userControllerProvider.notifier)
                        .checkConnectivity(),
          ),
        ],
      ),
      body: _buildBody(userState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // In your UserScreen's _buildBody method
  Widget _buildBody(UserViewModel userState) {
    if (userState.status == APIState.initial ||
        userState.status == APIState.loading &&
            (userState.users?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator());
    } else if (userState.status == APIState.error) {
      return Center(child: Text(userState.error ?? 'Error loading users'));
    } else if (userState.users == null || userState.users!.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemHeight = constraints.maxHeight / 6;

        return ListView.builder(
          controller: _scrollController,
          itemCount:
              userState.hasReachedMax
                  ? userState.users!.length
                  : userState.users!.length + 1,
          itemBuilder: (context, index) {
            if (index >= userState.users!.length) {
              return SizedBox(
                height: itemHeight,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            final user = userState.users![index];

            return SizedBox(
              height: itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MovieListScreen(userId: user.id),
                          ),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(user.avatar),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        user.email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // In your UserScreen's _showAddUserDialog method
  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final jobController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: jobController,
                decoration: const InputDecoration(labelText: 'Job'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Consumer(
              builder: (context, ref, _) {
                return TextButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final job = jobController.text;

                    if (name.isEmpty || job.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    final success = await ref
                        .read(userControllerProvider.notifier)
                        .addUser(name, job);

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'User added successfully'
                                : 'Failed to add user',
                          ),
                        ),
                      );

                      // Refresh the list
                      ref.read(userControllerProvider.notifier).getUsers();
                    }
                  },
                  child: const Text('Add'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}