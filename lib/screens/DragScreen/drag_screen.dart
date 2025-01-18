
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:redex_demo/blocs/grid/grid_cubit.dart';
import 'package:redex_demo/screens/DragScreen/drag_screen_view.dart';


class DragScreen extends StatelessWidget {
  const DragScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: BlocProvider(
        create: (_) => GridCubit(),
        child: DragScreenView(),
      ),
    );
  }
}
