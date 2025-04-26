class MovieDetailModel {
  final String imdbID;
  final String title;
  final String year;
  final String rated;
  final String released;
  final String runtime;
  final String genre;
  final String director;
  final String writer;
  final String actors;
  final String plot;
  final String posterUrl;
  final String imdbRating;
  final String type;
  final String language;
  final String country;
  final String awards;
  final String metascore;
  

  MovieDetailModel({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.rated,
    required this.released,
    required this.runtime,
    required this.genre,
    required this.director,
    required this.writer,
    required this.actors,
    required this.plot,
    required this.posterUrl,
    required this.imdbRating,
    required this.type,
    required this.language,
    required this.country,
    required this.awards,
    required this.metascore,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      imdbID: json['imdbID'],
      title: json['Title'],
      year: json['Year'],
      rated: json['Rated'] ?? 'N/A',
      released: json['Released'] ?? 'N/A',
      runtime: json['Runtime'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      director: json['Director'] ?? 'N/A',
      writer: json['Writer'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      plot: json['Plot'] ?? 'N/A',
      posterUrl: json['Poster'] ?? '',
      imdbRating: json['imdbRating'] ?? 'N/A',
      type: json['Type'] ?? 'N/A',
      language: json['Language'] ?? 'N/A',
      country: json['Country'] ?? 'N/A',
      awards: json['Awards'] ?? 'N/A',
      metascore: json['Metascore'] ?? 'N/A',
    );
  }
}


// // lib/features/movies/models/movie_detail_model.dart
// class MovieDetailModel {
//   final int id;
//   final String title;
//   final String overview;
//   final String posterPath;
//   final String releaseDate;
//   final double voteAverage;
//   final int runtime;
//   final List<String> genres;

//   MovieDetailModel({
//     required this.id,
//     required this.title,
//     required this.overview,
//     required this.posterPath,
//     required this.releaseDate,
//     required this.voteAverage,
//     required this.runtime,
//     required this.genres,
//   });

//   String get posterUrl => posterPath.isNotEmpty 
//       ? "http://image.tmdb.org/t/p/w185/$posterPath"
//       : '';

//   factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
//     return MovieDetailModel(
//       id: json['id'],
//       title: json['title'],
//       overview: json['overview'],
//       posterPath: json['poster_path'] ?? '',
//       releaseDate: json['release_date'] ?? '',
//       voteAverage: (json['vote_average'] ?? 0).toDouble(),
//       runtime: json['runtime'] ?? 0,
//       genres: (json['genres'] as List<dynamic>?)
//           ?.map((genre) => genre['name'] as String)
//           .toList() ?? [],
//     );
//   }
// }
