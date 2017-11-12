import 'package:sudoku_core/sudoku_core.dart';

class SudokuGame {
  SudokuBoard board = new SudokuBoard();

  SudokuRules rules;

  void start(List<List<int>> rows) {
    List<List<SudokuCell>> transformedRows =
        rows.map((row) => row.map((value) => new SudokuCell()..value = value)).toList();
    board.rows = transformedRows;
    print(board);
    rules = new SudokuRules(board);

    int pass = 0;
    Map<CellLocation, SudokuCell> filled = {};
    int removed;
    do {
      pass++;
      removed = 0;
      for (var location in board.asMap.keys) {
        List<EliminationResult> eliminations = rules.evaluate(location, useAdvancedRules: pass > 1);
        if ((eliminations ?? const []).isNotEmpty) {
          for (var elimination in eliminations) {
            print('${elimination.value} can be removed at $location due to ${elimination
                .reason} occuring at ${elimination
                .locations}');
            SudokuCell cell = board.elementAt(location);
            cell.removeCandidate(elimination.value);
            if (cell.value != null) {
              filled[location] = cell;
              var newlyFilled = board.cleanUp(location);
              if (newlyFilled != null) {
                filled.addAll(newlyFilled);
              }
            }
            removed++;
          }
        }
      }
      print('Pass $pass, removed $removed candidates');
      print(board);
    } while (removed > 0);
    print('Done, filled ${filled.length} cell(s): $filled');
    print(board);
  }
}
