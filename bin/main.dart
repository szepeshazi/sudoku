import 'package:sudoku_core/sudoku_core.dart';

void main(List<String> arguments) {

  print('Starting sudoku');
  SudokuGame game = new SudokuGame();
  game.start(hard3);
  return;


  print('************************************************************');
  print('************************************************************');
  print('************************************************************');
  print('************************************************************');

  SudokuBoard board = new SudokuBoard();
  List<List<SudokuCell>> transformedRows =
  hard3.map((row) => row.map((value) => new SudokuCell()..value = value)).toList();
  board.rows = transformedRows;
  game.solve(board);
}
