class GridItem {
  final int id;
  final int position;
  final bool isAddButton;

  const GridItem({
    required this.id,
    required this.position,
    this.isAddButton = false,
  });

  GridItem copyWith({
    int? id,
    int? position,
    bool? isAddButton,
  }) {
    return GridItem(
      id: id ?? this.id,
      position: position ?? this.position,
      isAddButton: isAddButton ?? this.isAddButton,
    );
  }

  @override
  String toString() {
    return 'GridItem(id: $id, position: $position, isAddButton: $isAddButton)';
  }
}
