import 'package:sudoku_core/sudoku_core.dart';

enum EliminationRule { valueInSameRow, valueInSameColumn, valueInSameSection }

class EliminationResult {
  int value;
  List<CellLocation> locations;
  EliminationRule reason;
}

class SudokuRules {
  final SudokuBoard board;
  final List<List<SudokuCell>> rows;
  final List<List<SudokuCell>> columns;
  final List<List<SudokuCell>> sections;

  SudokuRules(this.board)
      : rows = board.rows,
        columns = board.columns,
        sections = board.sections {
    print('SudokuRules constructor');
    print(board);
  }

  List<EliminationResult> evaluate(CellLocation location) {
    List<EliminationResult> results;
    SudokuCell cell = board.elementAt(location);
    if (cell.value != null) return null;

    results = [];
    for (var candidate in cell.candidates) {
      EliminationResult result = hasValueInSameRow(candidate, location);
      result ??= hasValueInSameColumn(candidate, location);
      result ??= hasValueInSameSection(candidate, location);
      if (result != null) {
        results.add(result);
      }
    }

    return results;
  }

  EliminationResult hasValueInSameRow(int value, CellLocation location) {
    EliminationResult result;
    print('hasValueInSameRow, value: $value, location: $location');
    for (var i = 0; i < board.x; i++) {
      if (i != location.x && rows[location.y][i].value == value) {
        result = new EliminationResult()
          ..reason = EliminationRule.valueInSameRow
          ..value = value
          ..locations = [new CellLocation(i, location.y)];
        break;
      }
    }
    return result;
  }

  EliminationResult hasValueInSameColumn(int value, CellLocation location) {
    EliminationResult result;
    for (var i = 0; i < board.y; i++) {
      if (i != location.y && columns[location.x][i].value == value) {
        result = new EliminationResult()
          ..reason = EliminationRule.valueInSameColumn
          ..value = value
          ..locations = [new CellLocation(location.x, i)];
        break;
      }
    }
    return result;
  }

  EliminationResult hasValueInSameSection(int value, CellLocation location) {
    EliminationResult result;
    int index = sectionIndex(location);
    CellLocation center = sectionCenter(index);
    Map<NeighborCellDirection, SudokuCell> neighbors = board.neighborsByDirection(center);
    for (var k in neighbors.keys) {
      if (neighbors[k].value == value) {
        result = new EliminationResult()
          ..reason = EliminationRule.valueInSameSection
          ..value = value
          ..locations = [center + directionMap[k]];
        break;
      }
    }
    return result;
  }

  int sectionIndex(CellLocation location) =>
      location.x ~/ SudokuBoard.sectionSize + (location.y ~/ SudokuBoard.sectionSize) * SudokuBoard.sectionSize;

  CellLocation sectionCenter(index) {
    final x = (index % SudokuBoard.sectionSize) * SudokuBoard.sectionSize + 1;
    final y = (index ~/ SudokuBoard.sectionSize) * SudokuBoard.sectionSize + 1;
    return new CellLocation(x, y);
  }
}
