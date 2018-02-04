import 'package:sudoku_core/sudoku_core.dart';
import 'package:trotter/trotter.dart';
import 'package:collection/collection.dart';

enum EliminationRule {
  valueInSameRow,
  valueInSameColumn,
  valueInSameSection,
  valueLockedByOtherSection,
  isOtherSingleCandidateInSection,
  isValueLockedInSection
}

class EliminationResult {
  /// Location of the cell where we can eliminate a given candidate
  CellLocation location;

  /// The candidate value that can be eliminated
  int value;

  /// The reason why the candidate value van be eliminated
  EliminationRule reason;

  /// List of cell locations that caused the current EliminationRule to be applied
  List<CellLocation> offendingLocations;
}

class SudokuRules {
  final SudokuBoard board;
  final List<List<SudokuCell>> rows;
  final List<List<SudokuCell>> columns;
  final List<List<SudokuCell>> sections;

  SudokuRules(this.board)
      : rows = board.rows,
        columns = board.columns,
        sections = board.sections;

  bool isCompleted() => board.board.firstWhere((cell) => cell.value == null, orElse: null) == null;

  bool isValid() {
    bool valid = true;
    for (var location in board.asMap.keys) {
      int currentValue = board.elementAt(location).value;
      if (currentValue == null) {
        continue;
      }
      EliminationResult result = hasValueInSameRow(currentValue, location);
      result ??= hasValueInSameColumn(currentValue, location);
      result ??= hasValueInSameSection(currentValue, location);
      if (result != null) {
        valid = false;
        break;
      }
    }
    return valid;
  }

  List<EliminationResult> reduceCellCanddates(CellLocation location, {bool useAdvancedRules: false}) {
    List<EliminationResult> results;
    SudokuCell cell = board.elementAt(location);
    if (cell.value != null) return null;

    results = [];
    for (var candidate in cell.candidates) {
      EliminationResult result = hasValueInSameRow(candidate, location);
      result ??= hasValueInSameColumn(candidate, location);
      result ??= hasValueInSameSection(candidate, location);
      if (useAdvancedRules) {
        result ??= isValueLockedByOtherSection(candidate, location);
        result ??= isOtherSingleCandidateInSection(candidate, location);
        result ??= isValueLockedInSection(candidate, location);
      }
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  EliminationResult hasValueInSameRow(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations =
        board.sameRowLocations(location).where((loc) => board.elementAt(loc).value == value).toList();

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..location = location
        ..reason = EliminationRule.valueInSameRow
        ..value = value
        ..offendingLocations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult hasValueInSameColumn(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations =
        board.sameColumnLocations(location).where((loc) => board.elementAt(loc).value == value).toList();

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..location = location
        ..reason = EliminationRule.valueInSameColumn
        ..value = value
        ..offendingLocations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult hasValueInSameSection(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations =
        board.sameSectionLocations(location).where((loc) => board.elementAt(loc).value == value).toList();

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..location = location
        ..reason = EliminationRule.valueInSameSection
        ..value = value
        ..offendingLocations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult isValueLockedByOtherSection(int value, CellLocation location) {
    EliminationResult result;
    List<int> relatedSectionIdices = board.sameRowSectionIndices(location);
    List<Map<CellLocation, SudokuCell>> relatedSections =
        relatedSectionIdices.map((i) => board.sectionsAsMap[i]).toList();
    for (var section in relatedSections) {
      List<CellLocation> sameCandidates = [];
      for (var loc in section.keys) {
        if ((section[loc].candidates ?? new Set()).contains(value)) {
          sameCandidates.add(loc);
        }
      }
      if (sameCandidates.isNotEmpty && sameCandidates.every((loc) => loc.y == location.y)) {
        result = new EliminationResult()
          ..location = location
          ..reason = EliminationRule.valueLockedByOtherSection
          ..value = value
          ..offendingLocations = sameCandidates;
        break;
      }
    }
    if (result == null) {
      relatedSectionIdices = board.sameColumnSectionIndices(location);
      relatedSections = relatedSectionIdices.map((i) => board.sectionsAsMap[i]).toList();
      for (var section in relatedSections) {
        List<CellLocation> sameCandidates = [];
        for (var loc in section.keys) {
          if ((section[loc].candidates ?? new Set()).contains(value)) {
            sameCandidates.add(loc);
          }
        }
        if (sameCandidates.isNotEmpty && sameCandidates.every((loc) => loc.x == location.x)) {
          result = new EliminationResult()
            ..location = location
            ..reason = EliminationRule.valueLockedByOtherSection
            ..value = value
            ..offendingLocations = sameCandidates;
          break;
        }
      }
    }
    return result;
  }

  EliminationResult isOtherSingleCandidateInSection(int value, CellLocation location) {
    EliminationResult result;
    final emptySet = new Set<int>();
    var sectionLocations = board.sameSectionLocations(location, includeSelf: true);
    Set<int> otherCandidateValues =
        board.elementAt(location).candidates.where((candidate) => candidate != value).toSet();

    Map<int, List<CellLocation>> candidateLocations = {};
    for (var candidate in otherCandidateValues) {
      for (var loc in sectionLocations) {
        if ((board.elementAt(loc).candidates ?? emptySet).contains(candidate)) {
          candidateLocations[candidate] ??= [];
          candidateLocations[candidate].add(loc);
        }
      }
    }

    int singleValue =
        candidateLocations.keys.firstWhere((cd) => candidateLocations[cd].length == 1, orElse: () => null);
    if (singleValue != null) {
      result = new EliminationResult()
        ..location = location
        ..reason = EliminationRule.isOtherSingleCandidateInSection
        ..value = value
        ..offendingLocations = candidateLocations[singleValue];
    }

    return result;
  }

  EliminationResult isValueLockedInSection(int value, CellLocation location) {
    EliminationResult result;
    final emptySet = new Set<int>();
    var sectionLocations = board.sameSectionLocations(location, includeSelf: true);
    Set<int> otherCandidateValues =
        board.elementAt(location).candidates.where((candidate) => candidate != value).toSet();
    int maxSetSize = otherCandidateValues.length;

    Map<int, List<CellLocation>> candidateLocations = {};
    for (var candidate in otherCandidateValues) {
      for (var loc in sectionLocations) {
        if ((board.elementAt(loc).candidates ?? emptySet).contains(candidate)) {
          candidateLocations[candidate] ??= [];
          candidateLocations[candidate].add(loc);
        }
      }
    }
    print('For location: $location and value: $value other candidate locations: $candidateLocations');

    outer:
    for (var setSize = 2; setSize <= maxSetSize; setSize++) {
      // Form n-sized sets of candidate values and check if all has the same locations
      var combinations = new Combinations(setSize, otherCandidateValues.toList());
      for (var combination in combinations) {
        // print('For location: $location and value: $value checking combination: $combination');
        List<CellLocation> currentLocations;
        bool isValid = true;
        for (var candidate in combination) {
          if (candidateLocations[candidate].length != setSize) {
            isValid = false;
            break;
          }
          if (currentLocations == null) {
            currentLocations = new List.from(candidateLocations[candidate]);
          } else {
            if (!(const UnorderedIterableEquality().equals(candidateLocations[candidate], currentLocations))) {
              isValid = false;
              break;
            }
          }
        }
        if (isValid) {
          result = new EliminationResult()
            ..location = location
            ..reason = EliminationRule.isValueLockedInSection
            ..value = value
            ..offendingLocations = currentLocations;
          break outer;
        }
      }
    }
    return result;
  }
}
