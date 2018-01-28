import 'package:sudoku_core/sudoku_core.dart';

class SudokuGame {

  void start(List<List<int>> rows) {
    SudokuBoard board = new SudokuBoard();
    List<List<SudokuCell>> transformedRows =
        rows.map((row) => row.map((value) => new SudokuCell()..value = value)).toList();
    board.rows = transformedRows;
    print(board);
    SudokuRules rules = new SudokuRules(board);

    int pass = 0;
    Map<CellLocation, SudokuCell> filled = {};
    int removed;
    do {
      pass++;
      removed = 0;
      for (var location in board.asMap.keys) {
        List<EliminationResult> eliminations = rules.reduceCellCanddates(location, useAdvancedRules: pass > 1);
        if ((eliminations ?? const []).isNotEmpty) {
          for (var elimination in eliminations) {
            print('${elimination.value} can be removed at $location due to ${elimination
                .reason} occuring at ${elimination
                .offendingLocations}');
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

  List<EliminationResult> solve(SudokuBoard board) {
    List<EliminationResult> steps = [];
    SudokuRules rules = new SudokuRules(board);

    int pass = 0;
    int removed;
    int resolved;
    bool boardClean = false;
    do {
      pass++;
      removed = 0;
      resolved = 0;
      for (var location in board.asMap.keys) {
        List<EliminationResult> eliminations = rules.reduceCellCanddates(location, useAdvancedRules: boardClean);
        if ((eliminations ?? const []).isNotEmpty) {
          steps.addAll(eliminations);
          SudokuCell cell = board.elementAt(location);
          for (var elimination in eliminations) {
            cell.removeCandidate(elimination.value);
            removed++;
            if (cell.value != null) {
              resolved++;
              boardClean = false;
            }
          }
        }
      }
      if (resolved == 0) {
        boardClean = true;
      }
    } while (removed > 0);
    return steps;
  }
}
