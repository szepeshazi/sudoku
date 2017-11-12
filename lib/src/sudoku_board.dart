import 'package:sudoku_core/sudoku_core.dart';

class SudokuBoard extends RectangularGameBoard<SudokuCell> {
  static const int boardSize = 9;
  static const int sectionSize = 3;

  List<List<SudokuCell>> _sections;
  List<Map<CellLocation, SudokuCell>> _sectionsMapRep;

  SudokuBoard() : super(boardSize, boardSize);

  Map<CellLocation, SudokuCell> cleanUp(CellLocation location, {Map<CellLocation, SudokuCell> filled}) {
    int value = elementAt(location).value;
    Map<CellLocation, SudokuCell> newlyFilled = {};
    filled ??= new Map<CellLocation, SudokuCell>();
    List<CellLocation> locations = sameRowLocations(location)
      ..addAll(sameColumnLocations(location))
      ..addAll(sameSectionLocations(location))
      ..toSet()
      ..toList();

    for (var loc in locations) {
      SudokuCell cell = elementAt(loc);
      if (cell.value == null) {
        cell.removeCandidate(value);
        if (cell.value != null) {
          filled[loc] = cell;
          newlyFilled[loc] = cell;
        }
      }
    }

    for (var loc in newlyFilled.keys) {
      filled.addAll(cleanUp(loc));
    }

    return filled;
  }

  List<List<SudokuCell>> get sections {
    if (_sections == null) {
      _sections = [];
      for (var i = 0; i < boardSize; i++) {
        List<SudokuCell> currentSection = [];
        var x = (i % sectionSize) * sectionSize;
        var y = (i ~/ sectionSize) * sectionSize;
        for (var j = 0; j < sectionSize; j++) {
          currentSection.addAll(board.getRange(x + (y + j) * boardSize, x + (y + j) * boardSize + sectionSize));
        }
        _sections.add(currentSection);
      }
    }
    return _sections;
  }

  List<Map<CellLocation, SudokuCell>> get sectionsAsMap {
    if (_sectionsMapRep == null) {
      _sectionsMapRep = [];
      for (var i = 0; i < boardSize; i++) {
        var x = (i % sectionSize) * sectionSize;
        var y = (i ~/ sectionSize) * sectionSize;
        Map<CellLocation, SudokuCell> sectionMap = {};
        for (var j = 0; j < boardSize; j++) {
          var x0 = (j % sectionSize);
          var y0 = (j ~/ sectionSize);
          CellLocation location = new CellLocation(x + x0, y + y0);
          sectionMap[location] = elementAt(location);
        }
        _sectionsMapRep.add(sectionMap);
      }
    }
    return _sectionsMapRep;
  }

  List<CellLocation> sameSectionLocations(CellLocation location, {bool includeSelf: false}) {
    List<CellLocation> locations = [];
    int x = (location.x ~/ sectionSize) * sectionSize;
    int y = (location.y ~/ sectionSize) * sectionSize;
    for (var j = 0; j < sectionSize; j++) {
      for (var i = 0; i < sectionSize; i++) {
        var loc = new CellLocation(x + i, y + j);
        if (includeSelf || loc != location) {
          locations.add(loc);
        }
      }
    }
    return locations.toList();
  }

  @override
  set rows(List<List<SudokuCell>> newRows) {
    super.rows = newRows;
    clearCache();
  }

  @override
  set columns(List<List<SudokuCell>> newColumns) {
    super.columns = newColumns;
    clearCache();
  }

  @override
  void clearCache() {
    super.clearCache();
    _sections = null;
    _sectionsMapRep = null;
  }

  List<int> sameRowSectionIndices(CellLocation location) {
    List<int> relatedSectionIndices = [];
    int index = sectionIndex(location);
    int row = index ~/ sectionSize;
    int currentColumn = index % sectionSize;
    for (var column = 0; column < sectionSize; column++) {
      if (column != currentColumn) {
        relatedSectionIndices.add(row * sectionSize + column);
      }
    }
    return relatedSectionIndices;
  }

  List<int> sameColumnSectionIndices(CellLocation location) {
    List<int> relatedSectionIndices = [];
    int index = sectionIndex(location);
    int currentRow = index ~/ sectionSize;
    int column = index % sectionSize;
    for (var row = 0; row < sectionSize; row++) {
      if (row != currentRow) {
        relatedSectionIndices.add(row * sectionSize + column);
      }
    }
    return relatedSectionIndices;
  }

  int sectionIndex(CellLocation location) =>
      location.x ~/ SudokuBoard.sectionSize + (location.y ~/ SudokuBoard.sectionSize) * SudokuBoard.sectionSize;

  CellLocation sectionCenter(index) {
    final x = (index % SudokuBoard.sectionSize) * SudokuBoard.sectionSize + 1;
    final y = (index ~/ SudokuBoard.sectionSize) * SudokuBoard.sectionSize + 1;
    return new CellLocation(x, y);
  }
}
