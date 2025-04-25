// lib/features/movies/views/movie_list_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/controllers/movie_controller.dart';
import 'package:movie_app/features/movies/viewModels/movie_view_model.dart';
import 'package:movie_app/features/movies/views/movie_detail_screen.dart';

class MovieListScreen extends ConsumerStatefulWidget {
  final int userId;
  const MovieListScreen({super.key, required this.userId});

  @override
  ConsumerState<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends ConsumerState<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movieControllerProvider.notifier).getMovies();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(movieControllerProvider.notifier).getMovies();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(movieControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trending Movies')),
      body: _buildBody(movieState),
    );
  }

  Widget _buildBody(MovieViewModel movieState) {
    if (movieState.status == APIState.initial ||
        movieState.status == APIState.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (movieState.status == APIState.error) {
      return const Center(child: Text('Error loading movies'));
    } else if (movieState.movies == null || movieState.movies!.isEmpty) {
      return const Center(child: Text('No movies found'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount:
          movieState.hasReachedMax
              ? movieState.movies!.length
              : movieState.movies!.length + 1,
      itemBuilder: (context, index) {
        if (index >= movieState.movies!.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final movie = movieState.movies![index];
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movieId: movie.id),
                ),
              ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    placeholder:
                        (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        movie.releaseDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
