// lib/features/movies/views/movie_list_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_app/Utilities/enums.dart';
import 'package:movie_app/features/movies/controllers/movie_controller.dart';
import 'package:movie_app/features/movies/models/movie_model.dart';
import 'package:movie_app/features/movies/viewModels/movie_view_model.dart';
import 'package:movie_app/features/movies/views/movie_detail_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MovieListScreen extends ConsumerStatefulWidget {
  final int userId;
  const MovieListScreen({super.key, required this.userId});

  @override
  ConsumerState<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends ConsumerState<MovieListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(movieControllerProvider);
      if (state.movies.isEmpty) {
        ref.read(movieControllerProvider.notifier).getMovies();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreMovies();
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await ref.read(movieControllerProvider.notifier).getMovies();
    setState(() => _isLoadingMore = false);
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Trending Movies',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(movieState),
    );
  }

  Widget _buildBody(MovieViewModel movieState) {
    // Initial loading state - show progress indicator
    if (movieState.status == APIState.initial ||
        (movieState.status == APIState.loading && movieState.movies.isEmpty)) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Error state with no movies
    if (movieState.status == APIState.error && movieState.movies.isEmpty) {
      return const Center(
        child: Text(
          'Error loading movies',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Empty state (after loading completed)
    if (movieState.movies.isEmpty) {
      return const Center(
        child: Text('No movies found', style: TextStyle(color: Colors.white)),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200) {
          _loadMoreMovies();
        }
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Carousel Sliver for first 5 movies (first page)
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildCarousel(movieState.movies.take(5).toList()),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'More Movies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Grid view for all movies (or remaining movies if we showed carousel)
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // If we showed carousel, skip first 5 movies in grid
                  final displayIndex =
                      (movieState.currentPage == 1 &&
                              movieState.movies.length >= 5)
                          ? index + 5
                          : index;

                  if (displayIndex >= movieState.movies.length) {
                    return const SizedBox.shrink();
                  }

                  final movie = movieState.movies[displayIndex];
                  return _buildMovieItem(movie);
                },
                childCount:
                    movieState.hasReachedMax
                        ? (movieState.currentPage == 1 &&
                                movieState.movies.length >= 5)
                            ? movieState.movies.length - 5
                            : movieState.movies.length
                        : ((movieState.currentPage == 1 &&
                                movieState.movies.length >= 5)
                            ? movieState.movies.length - 5 + 1
                            : movieState.movies.length + 1),
              ),
            ),
          ),
          // Loading indicator for pagination
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child:
                    _isLoadingMore
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel(List<MovieModel> movies) {
    return Column(
      children: [
        CarouselSlider(
          items:
              movies.map((movie) {
                return GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  MovieDetailScreen(movieId: movie.imdbID),
                        ),
                      ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.movie, color: Colors.white),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                );
              }).toList(),
          options: CarouselOptions(
            height: 200,
            aspectRatio: 16 / 9,
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              movies.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      _currentCarouselIndex == entry.key ? 0.9 : 0.4,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildMovieItem(MovieModel movie) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movieId: movie.imdbID),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: movie.posterUrl,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.movie, color: Colors.white),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.year,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
