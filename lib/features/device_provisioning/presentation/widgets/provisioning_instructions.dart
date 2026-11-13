import 'package:flutter/material.dart';

import '../../../../core/widgets/section_card.dart';

/// Development (ADB) provisioning procedure. The command is supplied by the
/// native layer so it always names the real receiver component.
class ProvisioningInstructions extends StatelessWidget {
  const ProvisioningInstructions({required this.adbCommand, super.key});

  static const String verifyCommand = 'adb shell dpm list-owners';

  final String adbCommand;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Provision as Device Owner (development)',
      children: [
        const InstructionStep(
          number: 1,
          text:
              'Use a dedicated test device. Factory reset it, or use a fresh '
              'emulator image.',
        ),
        const InstructionStep(
          number: 2,
          text:
              'Finish the setup wizard without adding any account. Android '
              'refuses to set a Device Owner while an account exists on the '
              'device.',
        ),
        const InstructionStep(
          number: 3,
          text: 'Enable Developer options and USB debugging.',
        ),
        const InstructionStep(
          number: 4,
          text: 'Install this app, then run from the connected computer:',
        ),
        CommandBlock(command: adbCommand),
        const InstructionStep(
          number: 5,
          text: 'Verify the result, then re-check the status on this screen:',
        ),
        const CommandBlock(command: verifyCommand),
        const SizedBox(height: 8),
        Text(
          'The app cannot grant itself Device Owner. Provisioning must be '
          'performed from outside the app.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class InstructionStep extends StatelessWidget {
  const InstructionStep({required this.number, required this.text, super.key});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$number.',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class CommandBlock extends StatelessWidget {
  const CommandBlock({required this.command, super.key});

  final String command;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 24, top: 4, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        command,
        style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}
