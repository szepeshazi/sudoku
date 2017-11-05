enum NeighborCellDirection { self, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left }

enum NeighborCellHeading { self, northWest, north, northEast, east, southEast, south, southWest, west }

class CellLocation {
  final int x;
  final int y;

  CellLocation(this.x, this.y);

  operator +(CellLocation other) => new CellLocation(x + other.x, y + other.y);

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

final Map<NeighborCellHeading, CellLocation> headingMap = {
  NeighborCellHeading.self: new CellLocation(0, 0),
  NeighborCellHeading.northWest: new CellLocation(-1, -1),
  NeighborCellHeading.north: new CellLocation(0, -1),
  NeighborCellHeading.northEast: new CellLocation(1, -1),
  NeighborCellHeading.east: new CellLocation(1, 0),
  NeighborCellHeading.southEast: new CellLocation(1, 1),
  NeighborCellHeading.south: new CellLocation(0, 1),
  NeighborCellHeading.southWest: new CellLocation(-1, 1),
  NeighborCellHeading.west: new CellLocation(-1, 0),
};

class RectangularGameBoard<T> {
  final int x;
  final int y;

  List<T> board;

  RectangularGameBoard(this.x, this.y) : board = new List<T>(x * y);

  List<List<T>> get rows {
    List<List<T>> _rows = [];
    for (var i = 0; i < y; i++) {
      _rows.add(board.getRange(i * y, (i + 1) * y).toList());
    }
    return _rows;
  }

  set rows(List<List<T>> newRows) {
    board = [];
    newRows.forEach(board.addAll);
  }

  List<List<T>> get columns {
    List<List<T>> _columns = [];
    for (var i = 0; i < x; i++) _columns.add([]);

    for (var i = 0; i < x * y; i++) {
      _columns[i % x].add(board.elementAt(i));
    }
    return _columns;
  }

  set Columns(List<List<T>> newColumns) {
    board = [];
    for (var i = 0; i < y; i++) {
      for (var j = 0; j < x; j++) {
        board.add(columns[j][i]);
      }
    }
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
        throw new ArgumentError.value('location', 'Invalid CellLocation');
      }
    }
    return element;
  }

  Map<NeighborCellDirection, T> neighborsByDirection(CellLocation location, {bool includeSelf: false}) {
    Map<NeighborCellDirection, T> neigbors;
    final keys = includeSelf ? directionMap.keys : directionMap.keys.skip(1);
    for (var key in keys) {
      neigbors[key] = elementAt(location + directionMap[key], orElse: () => null);
    }
    return neigbors;
  }

  Map<NeighborCellHeading, T> neighborsByHeading(CellLocation location, {bool includeSelf: false}) {
    Map<NeighborCellHeading, T> neigbors;
    final keys = includeSelf ? headingMap.keys : headingMap.keys.skip(1);
    for (var key in keys) {
      neigbors[key] = elementAt(location + directionMap[key], orElse: () => null);
    }
    return neigbors;
  }

  @override
  String toString() => rows.map((row) => '$row').join('\r\n');

}
