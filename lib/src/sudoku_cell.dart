class SudokuCell {
  int _value;
  Set<int> _candidates;

  set value(int newValue) {
    _candidates = null;
    _value = newValue == 0 ? null : newValue;
  }

  get value => _value;

  set candidates(List<int> newValues) {
    _value = null;
    _candidates = newValues.toSet();
    _validate();
  }

  get candidates => _candidates;

  void removeCandidate(int candidate) {
    _candidates.remove(candidate);
    _validate();
  }

  void _validate() {
    if (_candidates.length == 1) {
      value = _candidates.first;
    }
  }

}