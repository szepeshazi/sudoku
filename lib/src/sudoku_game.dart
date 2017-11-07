import 'package:sudoku_core/sudoku_core.dart';

class SudokuGame {

  SudokuBoard<SudokuCell> board = new SudokuBoard<SudokuCell>();

  SudokuRules rules;

  void start(List<List<int>> rows) {
    List<List<SudokuCell>> transformedRows = rows.map((row) => row.map((value) => new SudokuCell()..value = value));
    board.rows = transformedRows;
    print(board);
    rules = new SudokuRules(board);

    int pass = 0;
    int removed;
    do {
      pass++;
      removed = 0;
      for (int j = 0; j < board.y; j++) {
        for (int i = 0; i < board.x; i++) {
          CellLocation location = new CellLocation(i, j);
          List<EliminationResult> eliminations = rules.evaluate(location);
          if (eliminations != null && eliminations.isNotEmpty) {
            for (var elimination in eliminations) {
              print(
                  '${elimination.value} can be removed at $location due to ${elimination
                      .reason} occuring at ${elimination
                      .locations}');
              SudokuCell cell = board.elementAt(location);
              cell.removeCandidate(elimination.value);
              removed++;
            }
          }
        }
      }
      print('Pass $pass, removed $removed candidates');
    } while (removed > 0);
    print('Done');
    print(board);
  }
}
