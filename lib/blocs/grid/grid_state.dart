part of 'grid_cubit.dart';

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
