import 'package:sudoku_core/sudoku_core.dart';

class SudokuCell extends Cloneable<SudokuCell> {
  int _value;
  Set<int> _candidates;

  set value(int newValue) {
    if (newValue == 0) {
      _value = null;
      _candidates = new List<int>.generate(SudokuBoard.boardSize, (int index) => index + 1).toSet();
    } else {
      _candidates = null;
      _value = newValue;
    }
  }

  int get value => _value;

  set candidates(Set<int> newValues) {
    _value = null;
    _candidates = newValues.toSet();
    _resolveSingleCandidate();
  }

  Set<int> get candidates => _candidates;

  void removeCandidate(int candidate, {bool autoLock: true}) {
    _candidates.remove(candidate);
    if (autoLock) {
      _resolveSingleCandidate();
    }
  }

  void _resolveSingleCandidate() {
    if (_candidates.length == 1) {
      value = _candidates.first;
      _candidates = null;
    }
  }

  @override
  String toString() => _value != null ? 'Cell($value)' : 'Cell($_candidates)';

  @override
  SudokuCell clone() {
    return new SudokuCell()
    ..value = value
    ..candidates = candidates;
  }
}
