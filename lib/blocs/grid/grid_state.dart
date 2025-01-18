part of 'grid_cubit.dart';

class GridItem {
  final int id;
  final bool isAddButton;
  final int position;

  GridItem({
    required this.id,
    required this.position,
    this.isAddButton = false,
  });

  GridItem copyWith({int? position}) {
    return GridItem(
      id: id,
      position: position ?? this.position,
      isAddButton: isAddButton,
    );
  }
}

class GridState extends Equatable {
  final List<GridItem> items;
  final int? draggingItemId;
  final int? currentHoverPosition;

  const GridState({
    required this.items,
    this.draggingItemId,
    this.currentHoverPosition,
  });

  GridState copyWith({
    List<GridItem>? items,
    int? draggingItemId,
    int? currentHoverPosition,
  }) {
    return GridState(
      items: items ?? this.items,
      draggingItemId: draggingItemId ?? this.draggingItemId,
      currentHoverPosition: currentHoverPosition,
    );
  }

  @override
  List<Object?> get props => [items, draggingItemId, currentHoverPosition];
}
