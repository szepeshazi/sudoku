import 'package:sudoku_core/sudoku_core.dart';

class SudokuBoard<T> extends RectangularGameBoard {

  static const boardSize = 9;

  SudokuBoard(int x) : super(boardSize, boardSize);

}