import 'package:sudoku_core/sudoku_core.dart';

enum EliminationRule { valueInSameRow, valueInSameColumn, valueInSameSection, valueLockedByOtherSection }

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
        sections = board.sections {}

  List<EliminationResult> evaluate(CellLocation location, {bool useAdvancedRules: false}) {
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
      }
      if (result != null) {
        results.add(result);
      }
    }
    return results;
  }

  EliminationResult hasValueInSameRow(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations = board.sameRowLocations(location)
      .where((loc) => board.elementAt(loc).value == value).toList();

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..reason = EliminationRule.valueInSameRow
        ..value = value
        ..locations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult hasValueInSameColumn(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations = board.sameColumnLocations(location)
      .where((loc) => board.elementAt(loc).value == value);

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..reason = EliminationRule.valueInSameColumn
        ..value = value
        ..locations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult hasValueInSameSection(int value, CellLocation location) {
    EliminationResult result;
    List<CellLocation> sameValueLocations = board.sameSectionLocations(location)
      .where((loc) => board.elementAt(loc).value == value);

    if (sameValueLocations?.length > 0) {
      result = new EliminationResult()
        ..reason = EliminationRule.valueInSameSection
        ..value = value
        ..locations = [sameValueLocations.first];
    }
    return result;
  }

  EliminationResult isValueLockedByOtherSection(int value, CellLocation location) {
    EliminationResult result;
    List<int> relatedSectionIdices = board.sameRowSectionIndices(location);
    List<Map<CellLocation, SudokuCell>> relatedSections = relatedSectionIdices.map((i) => board.sectionsAsMap[i]);
    for (var section in relatedSections) {
      List<CellLocation> sameCandidates = [];
      for (var loc in section.keys) {
        if ((section[loc].candidates ?? new Set()).contains(value)) {
          sameCandidates.add(loc);
        }
      }
      if (sameCandidates.isNotEmpty && sameCandidates.every((loc) => loc.y == location.y)) {
        result = new EliminationResult()
          ..reason = EliminationRule.valueLockedByOtherSection
          ..value = value
          ..locations = sameCandidates;
        break;
      }
    }
    if (result == null) {
      relatedSectionIdices = board.sameColumnSectionIndices(location);
      relatedSections = relatedSectionIdices.map((i) => board.sectionsAsMap[i]);
      for (var section in relatedSections) {
        List<CellLocation> sameCandidates = [];
        for (var loc in section.keys) {
          if ((section[loc].candidates ?? new Set()).contains(value)) {
            sameCandidates.add(loc);
          }
        }
        if (sameCandidates.isNotEmpty && sameCandidates.every((loc) => loc.x == location.x)) {
          result = new EliminationResult()
            ..reason = EliminationRule.valueLockedByOtherSection
            ..value = value
            ..locations = sameCandidates;
          break;
        }
      }
    }
    return result;
  }

  EliminationResult isValueLockedInSection(int value, CellLocation location) {
    EliminationResult result;
    var sectionLocations = board.sameSectionLocations(location);
    Map<int, List<CellLocation>> candidateLocations = {};

    return result;
  }
}
