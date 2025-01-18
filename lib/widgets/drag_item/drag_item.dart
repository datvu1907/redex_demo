import 'package:flutter/material.dart';
import 'package:redex_demo/models/grid_item.dart';
import 'package:redex_demo/themes/color/color.dart';

class DragItem extends StatelessWidget {
  const DragItem(
      {super.key,
      required this.width,
      required this.height,
      required this.item,
      this.onDragUpdate,
      this.onDragEnd,
      required this.top,
      required this.left,
      this.onTap});
  final double top;
  final double left;
  final double width;
  final double height;
  final GridItem item;
  final void Function(DragUpdateDetails)? onDragUpdate;
  final void Function()? onDragEnd;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: item.isAddButton
          ? SizedBox(
              width: width,
              height: height,
              child: GestureDetector(
                onTap: onTap,
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
            )
          : Draggable<int>(
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
                          // ignore: deprecated_member_use
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
                onDragUpdate?.call(details);
              },
              onDragEnd: (details) {
                onDragEnd?.call();
              },
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: Center(
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColor.primary,
                    size: 50,
                  ),
                ),
              ),
            ),
    );
  }
}
