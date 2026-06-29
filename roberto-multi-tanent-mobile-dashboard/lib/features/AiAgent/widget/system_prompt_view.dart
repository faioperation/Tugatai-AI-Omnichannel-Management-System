import 'package:flutter/material.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_state.dart';

class SystemPromptView extends StatefulWidget {
  final String businessId;
  final VoidCallback? onNext;
  const SystemPromptView({super.key, required this.businessId, this.onNext});

  @override
  State<SystemPromptView> createState() => _SystemPromptViewState();
}

class _SystemPromptViewState extends State<SystemPromptView> {
  final TextEditingController _promptController = TextEditingController();
  String? _trainingId;

  @override
  void initState() {
    super.initState();
    final state = context.read<AgentTrainingBloc>().state;
    if (state is SingleAgentTrainingLoaded) {
      _promptController.text = state.training.systemPrompt;
      _trainingId = state.training.id;
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _savePrompt() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prompt cannot be empty')));
      return;
    }

    if (_trainingId != null) {
      context.read<AgentTrainingBloc>().add(
        UpdateAgentTrainingRequested(
          id: _trainingId!,
          data: {'systemPrompt': prompt},
        ),
      );
    } else {
      context.read<AgentTrainingBloc>().add(
        CreateAgentTrainingRequested(
          businessId: widget.businessId,
          systemPrompt: prompt,
        ),
      );
    }
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AgentTrainingBloc, AgentTrainingState>(
      listener: (context, state) {
        if (state is SingleAgentTrainingLoaded) {
          if (_promptController.text.isEmpty) {
            _promptController.text = state.training.systemPrompt;
          }
          _trainingId = state.training.id;
        } else if (state is AgentTrainingOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AgentTrainingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerTheme.color!,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Texts
            Text(
              'System Prompt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Define how your AI agent should behave and respond to customers',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Content Box Title
            Text(
              'System Instructions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // TextField
            CustomTextfield(
              hintText: 'Enter system prompt...',
              controller: _promptController,
              maxLines: 6,
            ),
            const SizedBox(height: 8),

            // Caption below textfield
            Text(
              "This prompt defines the AI's personality, knowledge, and behavior",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Next button (left aligned)
            ElevatedButton.icon(
              onPressed: _savePrompt,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
