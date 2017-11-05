import 'package:sudoku_core/sudoku_core.dart';

class SudokuGame {

  SudokuBoard<SudokuCell> board = new SudokuBoard<SudokuCell>(SudokuBoard.boardSize);

  void start(List<List<int>> rows) {
    List<List<SudokuCell>> transformedRows = rows.map((row) => row.map((value) => new SudokuCell()..value = value));
    board.rows = transformedRows;

    List<List<SudokuCell>> boardRows = board.rows;
    List<List<SudokuCell>> boardColumns = board.columns;
    print('Row 7, column 5: ${boardRows[7][5].value} (should be 8)');
    print('Column 5, row 7: ${boardColumns[5][7].value} (should be 8)');
    print('Row 4, column 4: ${boardRows[7][5].value} (should be null)');
  }
}
