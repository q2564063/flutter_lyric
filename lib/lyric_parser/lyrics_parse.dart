import 'package:flutter_lyric/lyrics_reader_model.dart';

///all parse extends this file
abstract class LyricsParse {
  String lyric;

  LyricsParse(this.lyric);

  ///call this method parse
  List<LyricsLineModel> parseLines({bool isMain = true, int offset = 0});

  ///verify [lyric] is matching
  bool isOK() => true;
}
