import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/applications_bloc.dart';

/// Search field plus type and status filters for the inventory.
class ApplicationFilterBar extends StatelessWidget {
  const ApplicationFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ApplicationSearchField(),
          SizedBox(height: 12),
          ApplicationTypeSelector(),
          SizedBox(height: 8),
          ApplicationStatusSelector(),
        ],
      ),
    );
  }
}

class ApplicationSearchField extends StatelessWidget {
  const ApplicationSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (query) => context.read<ApplicationsBloc>().add(
        ApplicationsSearchChanged(query),
      ),
      textInputAction: TextInputAction.search,
      autocorrect: false,
      decoration: const InputDecoration(
        hintText: 'Search by name or package',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class ApplicationTypeSelector extends StatelessWidget {
  const ApplicationTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ApplicationsBloc,
      ApplicationsState,
      ApplicationTypeFilter
    >(
      selector: (state) => state.typeFilter,
      builder: (context, selected) => SizedBox(
        width: double.infinity,
        child: SegmentedButton<ApplicationTypeFilter>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ApplicationTypeFilter.all, label: Text('All')),
            ButtonSegment(
              value: ApplicationTypeFilter.user,
              label: Text('User'),
            ),
            ButtonSegment(
              value: ApplicationTypeFilter.system,
              label: Text('System'),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => context
              .read<ApplicationsBloc>()
              .add(ApplicationsTypeFilterChanged(selection.first)),
        ),
      ),
    );
  }
}

class ApplicationStatusSelector extends StatelessWidget {
  const ApplicationStatusSelector({super.key});

  static const Map<ApplicationStatusFilter, String> _labels = {
    ApplicationStatusFilter.any: 'Any status',
    ApplicationStatusFilter.blocked: 'Blocked',
    ApplicationStatusFilter.allowed: 'Allowed',
  };

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ApplicationsBloc,
      ApplicationsState,
      ApplicationStatusFilter
    >(
      selector: (state) => state.statusFilter,
      builder: (context, selected) => Wrap(
        spacing: 8,
        children: [
          for (final entry in _labels.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: selected == entry.key,
              onSelected: (_) => context.read<ApplicationsBloc>().add(
                ApplicationsStatusFilterChanged(entry.key),
              ),
            ),
        ],
      ),
    );
  }
}

class ApplicationSortButton extends StatelessWidget {
  const ApplicationSortButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ApplicationsBloc, ApplicationsState, ApplicationSort>(
      selector: (state) => state.sort,
      builder: (context, selected) => PopupMenuButton<ApplicationSort>(
        tooltip: 'Sort',
        icon: const Icon(Icons.sort),
        initialValue: selected,
        onSelected: (sort) =>
            context.read<ApplicationsBloc>().add(ApplicationsSortChanged(sort)),
        itemBuilder: (_) => const [
          PopupMenuItem(value: ApplicationSort.name, child: Text('Name')),
          PopupMenuItem(
            value: ApplicationSort.packageName,
            child: Text('Package name'),
          ),
          PopupMenuItem(
            value: ApplicationSort.blockedFirst,
            child: Text('Suspended first'),
          ),
        ],
      ),
    );
  }
}
