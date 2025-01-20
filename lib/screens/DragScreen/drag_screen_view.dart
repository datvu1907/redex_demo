import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:redex_demo/blocs/grid/grid_cubit.dart';
import 'package:redex_demo/models/grid_item.dart';
import 'package:redex_demo/themes/color/color.dart';
import 'package:redex_demo/widgets/drag_item/drag_item.dart';

class DragScreenView extends StatefulWidget {
  const DragScreenView({super.key});

  @override
  State<DragScreenView> createState() => _DragScreenViewState();
}

class _DragScreenViewState extends State<DragScreenView> {
  final crossAxisCount = 3;
  final spacing = 8.0;
  Timer? _hoverTimer;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridCubit, GridState>(builder: (context, state) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;
              final itemHeight = itemWidth;

              // caclulate the number of rows that can fit in the available height
              final availableHeight =
                  constraints.maxHeight - 32; // Account for padding
              final possibleRows =
                  (availableHeight / (itemHeight + spacing)).floor();
              final totalGridSpots = possibleRows * crossAxisCount;

              return SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Build list of grid drag targets
                    ..._buildGridSpots(
                        totalGridSpots: totalGridSpots,
                        itemWidth: itemWidth,
                        itemHeight: itemHeight,
                        spacing: spacing,
                        state: state,
                        context: context),

                    // Build list of draggable items
                    ..._buildDraggableItems(
                        items: state.items,
                        itemWidth: itemWidth,
                        itemHeight: itemHeight,
                        spacing: spacing,
                        context: context,
                        totalGridSpots: totalGridSpots)
                  ],
                ),
              );
            },
          ));
    });
  }

  // Build the grid targets when user can drop items to
  List<Widget> _buildGridSpots(
      {required int totalGridSpots,
      required double itemWidth,
      required double itemHeight,
      required double spacing,
      required GridState state,
      required BuildContext context}) {
    return List.generate(totalGridSpots, (index) {
      return Positioned(
        key: ValueKey('grid_spot_$index'),
        left: (index % crossAxisCount) * (itemWidth + spacing),
        top: (index ~/ crossAxisCount) * (itemHeight + spacing),
        child: DragTarget<String>(
          builder: (context, candidateData, rejectedData) {
            return Opacity(
              opacity: 0.8,
              child: Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: candidateData.isNotEmpty
                        ? Colors.grey.shade200
                        : Colors.transparent),
                child: Center(
                  child: candidateData.isNotEmpty
                      ? Icon(
                          Icons.drag_indicator,
                          color: AppColor.primary,
                          size: 50,
                        )
                      : SizedBox(),
                ),
              ),
            );
          },
          onWillAcceptWithDetails: (data) {
            // Update hover position when dragging over a new position
            context.read<GridCubit>().updateHoverPosition(index);
            return true;
          },
          onLeave: (data) {
            context.read<GridCubit>().updateHoverPosition(index);
          },
          onAcceptWithDetails: (details) {
            // print('onAcceptWithDetails: ${details.data}');
            final draggedItem =
                state.items.firstWhere((item) => item.id == details.data);
            if (index < totalGridSpots) {
              context.read<GridCubit>()
                ..updateItemPosition(draggedItem.position, index)
                ..endDragging();
            }
          },
        ),
      );
    });
  }

  // Build list of draggable items
  List<Widget> _buildDraggableItems(
      {required List<GridItem> items,
      required double itemWidth,
      required double itemHeight,
      required double spacing,
      required BuildContext context,
      required int totalGridSpots}) {
    return items.map((item) {
      final index = item.position;
      final left = (index % crossAxisCount) * (itemWidth + spacing);
      final top = (index ~/ crossAxisCount) * (itemHeight + spacing);
      if (index < totalGridSpots) {
        return DragItem(
          key: ValueKey('draggable_item_$index'),
          width: itemWidth,
          height: itemWidth,
          item: item,
          top: top,
          left: left,
          onDragUpdate: (details) {
            _hoverTimer?.cancel();
            int? dragIndex = _calculateApproximateIndex(
                details, itemWidth, itemHeight, spacing, context);
            if (dragIndex == item.position) {
              return;
            }
            if (dragIndex != null) {
              // delay to prevent flickering
              _hoverTimer = Timer(const Duration(milliseconds: 100), () {
                context.read<GridCubit>().hoverToPosition(dragIndex);
              });
            }
          },
          onDragEnd: () {
            _hoverTimer?.cancel();
          },
          onTap: () {
            context.read<GridCubit>().addItem();
          },
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  // Calculate the approximate index of the grid spot the user is hovering over
  int? _calculateApproximateIndex(DragUpdateDetails details, double width,
      double height, double spacing, BuildContext context) {
    // Get the RenderBox of the grid container
    final RenderBox? gridBox = context.findRenderObject() as RenderBox?;
    if (gridBox == null) return null;

    // Convert the global position to local position within the grid
    final localPosition = gridBox.globalToLocal(details.globalPosition);

    // Account for padding (matching your Padding widget)
    final paddedPosition = Offset(
        localPosition.dx - 8, // horizontal padding
        localPosition.dy - 16 // vertical padding
        );

    // Calculate which cell we're hovering over
    final cellX = paddedPosition.dx ~/ (width + spacing);
    final cellY = paddedPosition.dy ~/ (height + spacing);

    // Calculate the index based on position
    if (cellX >= 0 && cellX < crossAxisCount && cellY >= 0) {
      final approximateIndex = (cellY * crossAxisCount) + cellX;
      return approximateIndex;
    }
    ;
    return null;
  }
}
