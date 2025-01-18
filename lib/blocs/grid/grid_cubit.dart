import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'grid_state.dart';

class GridCubit extends Cubit<GridState> {
  GridCubit()
      : super(GridState(
            items: [GridItem(id: -1, position: 0, isAddButton: true)]));

  void updateHoverPosition(int? newPosition) {
    if (state.draggingItemId == null ||
        newPosition == state.currentHoverPosition) {
      return;
    }

    final draggedItem =
        state.items.firstWhere((item) => item.id == state.draggingItemId);
    final oldPosition = draggedItem.position;

    // Create a new list with temporary positions
    final updatedItems = List<GridItem>.from(state.items);

    if (newPosition != null) {
      // Remove dragged item temporarily
      updatedItems.removeWhere((item) => item.id == state.draggingItemId);

      // Shift items between old and new positions
      for (var item in updatedItems) {
        if (!item.isAddButton) {
          // Don't move the add button
          if (oldPosition < newPosition) {
            if (item.position > oldPosition && item.position <= newPosition) {
              item = item.copyWith(position: item.position - 1);
            }
          } else {
            if (item.position >= newPosition && item.position < oldPosition) {
              item = item.copyWith(position: item.position + 1);
            }
          }
        }
      }

      // Add dragged item at new position
      updatedItems.add(draggedItem.copyWith(position: newPosition));
    }

    emit(state.copyWith(
      items: updatedItems,
      currentHoverPosition: newPosition,
    ));
  }

  void updateItemPosition(int oldPosition, int newPosition) {
    if (oldPosition == newPosition) return;

    final currentItems = List<GridItem>.from(state.items);

    // Find the item being moved
    final movingItem =
        currentItems.firstWhere((item) => item.position == oldPosition);

    // Remove the item from its current position
    currentItems.removeWhere((item) => item.position == oldPosition);

    // Shift positions of other items
    for (var item in currentItems) {
      if (!item.isAddButton) {
        // Don't adjust the add button's position
        if (oldPosition < newPosition) {
          // Moving forward: shift items in between backwards
          if (item.position > oldPosition && item.position <= newPosition) {
            item = item.copyWith(position: item.position - 1);
          }
        } else {
          // Moving backward: shift items in between forward
          if (item.position >= newPosition && item.position < oldPosition) {
            item = item.copyWith(position: item.position + 1);
          }
        }
      }
    }

    // Insert the moved item at its new position
    currentItems.add(movingItem.copyWith(position: newPosition));

    // Sort the items by position to maintain order
    currentItems.sort((a, b) => a.position.compareTo(b.position));

    emit(state.copyWith(items: currentItems));
  }

  void hoverToPosition(int dragPosition) {
    // Find item at the drag position (if any)
    final itemAtPosition = state.items
        .where((item) =>
            item.position == dragPosition && item.id != state.draggingItemId)
        .firstOrNull;

    if (itemAtPosition != null) {
      // Create a copy of current items
      final updatedItems = List<GridItem>.from(state.items);

      // Get all positions currently occupied
      final occupiedPositions = updatedItems
          .where((item) => item.id != state.draggingItemId)
          .map((item) => item.position)
          .toSet();

      // Find next available position
      int nextPosition = dragPosition + 1;
      while (occupiedPositions.contains(nextPosition)) {
        nextPosition++;
      }

      // Move items sequentially
      final itemsToMove = updatedItems
          .where((item) =>
              item.position >= dragPosition &&
              item.position < nextPosition &&
              item.id != state.draggingItemId)
          .toList();

      // Sort items in reverse order to prevent position conflicts
      itemsToMove.sort((a, b) => b.position.compareTo(a.position));

      // Move each item one position forward
      for (var item in itemsToMove) {
        final index = updatedItems.indexOf(item);
        updatedItems[index] = item.copyWith(position: item.position + 1);
      }

      emit(state.copyWith(
        items: updatedItems,
        currentHoverPosition: dragPosition,
        draggingItemId: state.draggingItemId,
      ));
    } else {
      // Just update hover position if position is empty
      emit(state.copyWith(
        currentHoverPosition: dragPosition,
        draggingItemId: state.draggingItemId,
      ));
    }
  }

  void addItem() {
    final currentItems = List<GridItem>.from(state.items);
    final newItemId = currentItems.length > 1
        ? currentItems
                .where((item) => !item.isAddButton)
                .map((e) => e.id)
                .reduce(max) +
            1
        : 1;

    // Get add button
    final addButton = currentItems.removeAt(0);

    // Get set of occupied positions
    final occupiedPositions = currentItems
        .where((item) => !item.isAddButton)
        .map((item) => item.position)
        .toSet();

    // Find the first available position after the last occupied position
    int newPosition = 1; // Start from position 1 (position 0 is for add button)

    if (occupiedPositions.isNotEmpty) {
      // Find the highest occupied position
      final maxOccupiedPosition = occupiedPositions.reduce(max);

      // Start checking from position 1 up to maxOccupiedPosition + 1
      for (int i = 1; i <= maxOccupiedPosition + 1; i++) {
        if (!occupiedPositions.contains(i)) {
          newPosition = i;
          break;
        }
      }
    }

    // Insert new item at the found position
    currentItems.add(GridItem(id: newItemId, position: newPosition));

    // Add button back at position 0
    currentItems.insert(0, addButton);

    // Sort items by position
    currentItems.sort((a, b) => a.position.compareTo(b.position));

    emit(state.copyWith(items: currentItems));
  }

  void startDragging(int itemId) {
    emit(state.copyWith(
      draggingItemId: itemId,
      currentHoverPosition: null,
    ));
  }

  void endDragging() {
    emit(state.copyWith(
      draggingItemId: null,
      currentHoverPosition: null,
    ));
  }
}
