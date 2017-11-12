enum NeighborCellDirection { self, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left }

class CellLocation {
  final int x;
  final int y;

  CellLocation(this.x, this.y);

  CellLocation operator +(CellLocation other) => new CellLocation(x + other.x, y + other.y);

  @override
  bool operator ==(dynamic other) => (other is CellLocation && x == other.x && y == other.y);

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + x;
    result = 37 * result + y;
    return result;
  }

  @override
  String toString() => 'Location($x, $y)';
}

final Map<NeighborCellDirection, CellLocation> directionMap = {
  NeighborCellDirection.self: new CellLocation(0, 0),
  NeighborCellDirection.topLeft: new CellLocation(-1, -1),
  NeighborCellDirection.top: new CellLocation(0, -1),
  NeighborCellDirection.topRight: new CellLocation(1, -1),
  NeighborCellDirection.right: new CellLocation(1, 0),
  NeighborCellDirection.bottomRight: new CellLocation(1, 1),
  NeighborCellDirection.bottom: new CellLocation(0, 1),
  NeighborCellDirection.bottomLeft: new CellLocation(-1, 1),
  NeighborCellDirection.left: new CellLocation(-1, 0),
};

class RectangularGameBoard<T> {
  final int x;
  final int y;

  List<T> board;
  List<List<T>> _rows;
  List<List<T>> _columns;
  Map<CellLocation, T> _mapRep;

  RectangularGameBoard(this.x, this.y) : board = new List<T>(x * y);

  List<List<T>> get rows {
    if (_rows == null) {
      _rows = [];
      for (var i = 0; i < y; i++) {
        _rows.add(board.getRange(i * y, (i + 1) * y).toList());
      }
    }
    return _rows;
  }

  set rows(List<List<T>> newRows) {
    board = [];
    newRows.forEach(board.addAll);
    clearCache();
  }

  List<List<T>> get columns {
    if (_columns == null) {
      _columns = [];
      for (var i = 0; i < x; i++) _columns.add([]);
      for (var i = 0; i < x * y; i++) {
        _columns[i % x].add(board.elementAt(i));
      }
    }
    return _columns;
  }

  set columns(List<List<T>> newColumns) {
    board = [];
    for (var i = 0; i < y; i++) {
      for (var j = 0; j < x; j++) {
        board.add(columns[j][i]);
      }
    }
    clearCache();
  }

  Map<CellLocation, T> get asMap {
    if (_mapRep == null) {
      _mapRep = {};
      for (var j = 0; j < y; j++) {
        for (var i = 0; i < x; i++) {
          var location = new CellLocation(i, j);
          _mapRep[location] = elementAt(location);
        }
      }
    }
    return _mapRep;
  }

  void clearCache() {
    _rows = null;
    _columns = null;
    _mapRep = null;
  }

  bool isValidLocation(CellLocation location) {
    return location.x >= 0 && location.x < x && location.y >= 0 && location.y < y;
  }

  T elementAt(CellLocation location, {T orElse()}) {
    T element;
    if (isValidLocation(location)) {
      element = board[location.x + location.y * x];
    } else {
      if (orElse != null) {
        element = orElse();
      } else {
        throw new ArgumentError.value(location, 'Invalid cell location');
      }
    }
    return element;
  }

  List<CellLocation> neighborLocations(CellLocation location, {bool includeSelf: false}) {
    List<CellLocation> locations;
    locations = includeSelf ? directionMap.values : directionMap.values.skip(1);
    locations.retainWhere((location) => isValidLocation(location));
    return locations.toList();
  }

  List<CellLocation> sameRowLocations(CellLocation location, {bool includeSelf: false}) {
    List<CellLocation> locations;
    List<int> xCoords = new List.generate(x, (i) => i);
    if (!includeSelf) xCoords.remove(location.x);
    locations = xCoords.map((coord) => new CellLocation(coord, location.y));
    return locations.toList();
  }

  List<CellLocation> sameColumnLocations(CellLocation location, {bool includeSelf: false}) {
    List<CellLocation> locations;
    List<int> yCoords = new List.generate(y, (i) => i);
    if (!includeSelf) yCoords.remove(location.y);
    locations = yCoords.map((coord) => new CellLocation(location.x, coord));
    return locations.toList();
  }

    @override
  String toString() => rows.map((row) => '$row').join('\r\n');
}
