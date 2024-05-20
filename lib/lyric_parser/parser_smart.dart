import 'package:flutter_lyric/lyric_parser/lyrics_parse.dart';
import 'package:flutter_lyric/lyric_parser/parser_lrc.dart';
import 'package:flutter_lyric/lyric_parser/parser_qrc.dart';
import 'package:flutter_lyric/lyrics_reader_model.dart';

///smart parser
///Parser is automatically selected
class ParserSmart extends LyricsParse {
  ParserSmart(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true, int offset = 0}) {
    var qrc = ParserQrc(lyric);
    if (qrc.isOK()) {
      return qrc.parseLines(isMain: isMain, offset: offset);
    }
    return ParserLrc(lyric).parseLines(isMain: isMain, offset: offset);
  }
}
