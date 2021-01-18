import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_io18/AlbumsListError.dart';
import 'package:flutter_reactive_io18/events.dart';
import 'package:flutter_reactive_io18/model.dart';
import 'package:flutter_reactive_io18/services.dart';
import 'package:flutter_reactive_io18/states.dart';

class AlbumsBloc extends Bloc<AlbumEvents, AlbumsState> {

  final AlbumsRepo albumsRepo;
  List<Album> albums;

  AlbumsBloc({this.albumsRepo}) : super(AlbumsInitState());

  @override
  Stream<AlbumsState> mapEventToState(AlbumEvents event) async* {
    switch (event) {
      case AlbumEvents.fetchAlbums:
        yield AlbumsLoading();
        try {
          albums = await albumsRepo.getAlbumList();
          yield AlbumsLoaded(albums: albums);
        } on SocketException {
          yield AlbumsListError(
            error: NoInternetException('No Internet'),
          );
        } on HttpException {
          yield AlbumsListError(
            error: NoServiceFoundException('No Service Found'),
          );
        } on FormatException {
          yield AlbumsListError(
            error: InvalidFormatException('Invalid Response format'),
          );
        } catch (e) {
          yield AlbumsListError(
            error: UnknownException('Unknown Error'),
          );
        }
        break;
    }
  }
}