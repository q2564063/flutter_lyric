/*
 * @Author: zzq 
 * @Date: 2024-01-05 11:16:09
 * @LastEditors: zzq 
 * @LastEditTime: 2024-01-08 16:13:24
 * @FilePath: /light_player/Users/bmi/Documents/flutter_lyric/lib/lyrics_model_builder.dart
 * @Description: 
 */
import 'package:flutter_lyric/lyric_parser/lyrics_parse.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

import 'lyric_parser/parser_smart.dart';
import 'lyrics_reader_model.dart';
import 'package:collection/collection.dart';

/// lyric Util
/// support Simple format、Enhanced format
class LyricsModelBuilder {
  ///if line time is null,then use MAX_VALUE replace
  static final defaultLineDuration = 5000;

  var _lyricModel = LyricsReaderModel();

  reset() {
    _lyricModel = LyricsReaderModel();
  }

  List<LyricsLineModel>? mainLines;
  List<LyricsLineModel>? extLines;

  int offset = 0;

  static LyricsModelBuilder create() => LyricsModelBuilder._();

  LyricsModelBuilder bindLyricToMain(String lyric, [LyricsParse? parser]) {
    final RegExp exp1 =
        RegExp(r"(\[\d+:\d+)(\.0)?\]"); //存在歌词时间戳为：[00:00] 和 [00:00.0]的情况
    if (exp1.hasMatch(lyric)) {
      lyric = lyric.replaceAllMapped(exp1, ((m) => '${m[1]}.00]'));
    }
    final RegExp exp2 = RegExp(r"(\[\d+:\d+(\.\d+)?\])(\[\d+:\d+(\.\d+)?\])");
    if (exp2.hasMatch(lyric)) {
      lyric = lyric.replaceAllMapped(exp2, ((m) {
        return '${m[1]}\n${m[3]}';
      }));
    }
    offset = getLyricsTimelineOffset(lyric);
    mainLines = (parser ?? ParserSmart(lyric)).parseLines(offset: offset);

    return this;
  }

  int getLyricsTimelineOffset(String lyrics) {
    // example: [offset:500]  // 500ms 负数：提前显示， 正数：延后显示
    final regExp = RegExp(r"\[offset:(-?\d+)\]");
    final match = regExp.firstMatch(lyrics);
    if (match != null) {
      return int.parse(match.group(1) ?? "0");
    }
    return 0;
  }

  LyricsModelBuilder bindLyricToExt(String lyric, [LyricsParse? parser]) {
    extLines = (parser ?? ParserSmart(lyric))
        .parseLines(isMain: false, offset: offset);
    return this;
  }

  _setLyric(List<LyricsLineModel>? lineList, {isMain = true}) {
    if (lineList == null) return;
    //下一行的开始时间则为上一行的结束时间，若无则MAX
    for (int i = 0; i < lineList.length; i++) {
      var currLine = lineList[i];
      try {
        currLine.endTime = lineList[i + 1].startTime;
      } catch (e) {
        var lastSpan = currLine.spanList?.lastOrNull;
        if (lastSpan != null) {
          currLine.endTime = lastSpan.end;
        } else {
          currLine.endTime = (currLine.startTime ?? 0) + defaultLineDuration;
        }
      }
    }
    if (isMain) {
      _lyricModel.lyrics.clear();
      _lyricModel.lyrics.addAll(lineList);
    } else {
      //扩展歌词对应行
      for (var mainLine in _lyricModel.lyrics) {
        var extLine = lineList.firstWhere(
            (extLine) =>
                mainLine.startTime == extLine.startTime &&
                mainLine.endTime == extLine.endTime, orElse: () {
          return LyricsLineModel();
        });
        mainLine.extText = extLine.extText;
      }
    }
  }

  LyricsReaderModel getModel() {
    _setLyric(mainLines, isMain: true);
    _setLyric(extLines, isMain: false);

    return _lyricModel;
  }

  LyricsModelBuilder._();
}
