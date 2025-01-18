import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:redex_demo/blocs/grid/grid_cubit.dart';
import 'package:redex_demo/themes/color/color.dart';

class DragScreen extends StatefulWidget {
  const DragScreen({super.key});

  @override
  State<DragScreen> createState() => _DragScreenState();
}

class _DragScreenState extends State<DragScreen> {
  final crossAxisCount = 3;
  final spacing = 8.0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: BlocProvider(
        create: (_) => GridCubit(),
        child: BlocBuilder<GridCubit, GridState>(builder: (context, state) {
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth -
                          (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;
                  final itemHeight = itemWidth;

                  // caclulate the number of rows that can fit in the available height
                  final availableHeight =
                      constraints.maxHeight - 32; // Account for padding
                  final possibleRows =
                      (availableHeight / (itemHeight + spacing)).floor();
                  final totalGridSpots = possibleRows * crossAxisCount;

                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.red,
                    child: Stack(
                      children: [
                        ...List.generate(totalGridSpots, (index) {
                          return Positioned(
                            left: (index % crossAxisCount) *
                                (itemWidth + spacing),
                            top: (index ~/ crossAxisCount) *
                                (itemHeight + spacing),
                            child: DragTarget<int>(
                              builder: (context, candidateData, rejectedData) {
                                return Opacity(
                                  opacity: 0.6,
                                  child: Container(
                                    width: itemWidth,
                                    height: itemHeight,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: candidateData.isNotEmpty
                                            ? AppColor.white
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
                                print('onWillAcceptWithDetails: ${data.data}');
                                // Update hover position when dragging over a new position
                                context
                                    .read<GridCubit>()
                                    .updateHoverPosition(index);
                                return true;
                              },
                              onLeave: (data) {
                                print('onLeave: ${data}');
                                context
                                    .read<GridCubit>()
                                    .updateHoverPosition(index);
                              },
                              onAcceptWithDetails: (details) {
                                // print('onAcceptWithDetails: ${details.data}');
                                final draggedItem = state.items.firstWhere(
                                    (item) => item.id == details.data);
                                if (index < totalGridSpots) {
                                  context.read<GridCubit>()
                                    ..updateItemPosition(
                                        draggedItem.position, index)
                                    ..endDragging();
                                }
                              },
                            ),
                          );
                        }),

                        // Draggable items
                        ...state.items.map((item) {
                          final index = item.position;
                          if (index < totalGridSpots) {
                            return Positioned(
                              left: (index % crossAxisCount) *
                                  (itemWidth + spacing),
                              top: (index ~/ crossAxisCount) *
                                  (itemHeight + spacing),
                              child: item.isAddButton
                                  ? _buildAddButton(
                                      context, itemWidth, itemHeight, item)
                                  : _buildDraggableItem(
                                      context, itemWidth, itemHeight, item),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  );
                },
              ));
        }),
      ),
    );
  }

  Widget _buildAddButton(
      BuildContext context, double width, double height, GridItem item) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => context.read<GridCubit>().addItem(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_circle_outline_outlined,
            size: 50,
            color: AppColor.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableItem(
      BuildContext context, double width, double height, GridItem item) {
    return Draggable<int>(
      data: item.id,
      feedback: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(12),

          /// This is the widget that will be dragged
          width: width - 24,
          height: height - 24,
          decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]),
          child: Center(
            child: Icon(
              Icons.drag_indicator,
              color: AppColor.primary,
              size: 46,
            ),
          )),
      childWhenDragging: SizedBox(
        width: width,
        height: height,
      ),
      onDragUpdate: (details) {
        int? dragIndex = _calculateApproximateIndex(
            details, width, height, spacing, context);
        if (dragIndex != null) {
          // context.read<GridCubit>().updateHoverPosition(nextIndex);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ]),
        child: Center(
          // child: Icon(
          //   Icons.drag_indicator,
          //   color: AppColor.primary,
          //   size: 50,
          // ),
          child: Text(
            'Item ${item.id}',
          ),
        ),
      ),
    );
  }

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
      print('approximateIndex $approximateIndex');
      // context.read<GridCubit>().updateHoverPosition(approximateIndex);

      print('Hovering over index: $approximateIndex (x: $cellX, y: $cellY)');
      return approximateIndex;
    }
    ;
  }
}
