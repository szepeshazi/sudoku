import 'package:sudoku_core/sudoku_core.dart';

class SudokuGame {

  SudokuBoard<SudokuCell> board = new SudokuBoard<SudokuCell>(SudokuBoard.boardSize);

  void init(List<List<int>> rows) {
    board.rows = rows;
  }
}