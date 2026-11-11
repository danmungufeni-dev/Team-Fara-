enum ResolutionStrategy {
  smartMerge,
  keepLocal,
  acceptRemote,
}

class ConflictAttribute {
  final String fieldName;
  final String label;
  final String remoteValue;
  final String localValue;
  final String selectedValue;

  const ConflictAttribute({
    required this.fieldName,
    required this.label,
    required this.remoteValue,
    required this.localValue,
    required this.selectedValue,
  });

  ConflictAttribute copyWith({String? selectedValue}) {
    return ConflictAttribute(
      fieldName: fieldName,
      label: label,
      remoteValue: remoteValue,
      localValue: localValue,
      selectedValue: selectedValue ?? this.selectedValue,
    );
  }
}

class SyncConflict {
  final String id;
  final String hubId;
  final String hubName;
  final String remoteUser;
  final DateTime remoteTime;
  final String localUser;
  final DateTime localTime;
  final List<ConflictAttribute> attributes;
  final ResolutionStrategy activeStrategy;
  final bool isResolved;

  const SyncConflict({
    required this.id,
    required this.hubId,
    required this.hubName,
    required this.remoteUser,
    required this.remoteTime,
    required this.localUser,
    required this.localTime,
    required this.attributes,
    this.activeStrategy = ResolutionStrategy.smartMerge,
    this.isResolved = false,
  });

  SyncConflict copyWith({
    List<ConflictAttribute>? attributes,
    ResolutionStrategy? activeStrategy,
    bool? isResolved,
  }) {
    return SyncConflict(
      id: id,
      hubId: hubId,
      hubName: hubName,
      remoteUser: remoteUser,
      remoteTime: remoteTime,
      localUser: localUser,
      localTime: localTime,
      attributes: attributes ?? this.attributes,
      activeStrategy: activeStrategy ?? this.activeStrategy,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
