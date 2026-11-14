import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/schedule_editor_bloc.dart';
import '../widgets/schedule_editor_form.dart';

class ScheduleEditorPage extends StatelessWidget {
  const ScheduleEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleEditorBloc, ScheduleEditorState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus &&
          current.submitStatus == ScheduleSubmitStatus.success,
      listener: (context, state) => context.pop(true),
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.isEditingExisting ? 'Edit Schedule' : 'New Schedule',
          ),
        ),
        body: SafeArea(child: ScheduleEditorForm(state: state)),
      ),
    );
  }
}
