import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../application_management/domain/entities/managed_application.dart';
import '../bloc/schedule_editor_bloc.dart';
import '../bloc/time_restriction_bloc.dart';
import '../widgets/time_restriction_content.dart';

class TimeRestrictionPage extends StatelessWidget {
  const TimeRestrictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Restrictions'),
        actions: const [ScheduleSyncButton()],
      ),
      floatingActionButton: const AddScheduleButton(),
      body: SafeArea(
        child: BlocConsumer<TimeRestrictionBloc, TimeRestrictionState>(
          listenWhen: (previous, current) =>
              previous.actionStatus != current.actionStatus &&
              current.actionMessage != null,
          listener: (context, state) {
            final message = state.actionMessage;
            if (message == null) return;
            final failed =
                state.actionStatus == TimeRestrictionActionStatus.failure;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: failed
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              );
          },
          builder: (context, state) {
            final overview = state.overview;
            final failure = state.failure;
            if (overview != null) {
              return TimeRestrictionContent(
                overview: overview,
                isBusy: state.isActionInProgress,
              );
            }
            if (failure != null) {
              return MdmErrorView(
                failure: failure,
                onRetry: () => context.read<TimeRestrictionBloc>().add(
                  const TimeRestrictionsRequested(),
                ),
              );
            }
            return const LoadingWidget(message: 'Reading schedules');
          },
        ),
      ),
    );
  }
}

/// Manual synchronization: re-evaluate every schedule on the device now.
class ScheduleSyncButton extends StatelessWidget {
  const ScheduleSyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Synchronize now',
      icon: const Icon(Icons.sync),
      onPressed: () => context.read<TimeRestrictionBloc>().add(
        const TimeRestrictionsSyncRequested(),
      ),
    );
  }
}

/// Picks an application, then opens the editor for a new schedule.
class AddScheduleButton extends StatelessWidget {
  const AddScheduleButton({super.key});

  Future<void> _add(BuildContext context) async {
    final bloc = context.read<TimeRestrictionBloc>();
    final router = GoRouter.of(context);
    final application = await router.push<ManagedApplication>(
      AppRoutes.applicationPicker,
    );
    if (application == null) return;
    await router.push<bool>(
      AppRoutes.scheduleEditor,
      extra: ScheduleEditorArgs.create(
        packageName: application.packageName,
        applicationName: application.applicationName,
      ),
    );
    bloc.add(const TimeRestrictionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _add(context),
      icon: const Icon(Icons.add),
      label: const Text('Add schedule'),
    );
  }
}
