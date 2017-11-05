import 'package:sudoku_core/sudoku_core.dart';

class SudokuBoard<T> extends RectangularGameBoard {

  static const boardSize = 9;
  static const sectionSize = 3;

  SudokuBoard() : super(boardSize, boardSize);

  List<List<T>> get sections {
    List<List<T>> _sections = [];
    for (var i = 0; i < sectionSize; i++) {
      for (var j = 0; j < sectionSize; j++) {
        List<T> currentSection = [];
        for (var k = 0; k < sectionSize; k++) {
          int start = (i * sectionSize + k) * boardSize + j * sectionSize;
          currentSection.addAll(board.getRange(start, start + sectionSize).toList() as List<T>);
        }
        _sections.add(currentSection);
      }
    }
    return _sections;
  }
}
