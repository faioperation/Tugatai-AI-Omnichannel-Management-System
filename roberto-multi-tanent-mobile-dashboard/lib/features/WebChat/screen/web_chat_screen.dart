import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/WebChat/bloc/web_chat_bloc.dart';
import 'package:roberto/features/WebChat/bloc/web_chat_event.dart';
import 'package:roberto/features/WebChat/bloc/web_chat_state.dart';
import 'package:roberto/features/WebChat/data/models/web_chat_model.dart';
import 'package:intl/intl.dart';

class WebChatScreen extends StatefulWidget {
  final String branchId;
  const WebChatScreen({super.key, required this.branchId});

  @override
  State<WebChatScreen> createState() => _WebChatScreenState();
}

class _WebChatScreenState extends State<WebChatScreen> {
  @override
  void initState() {
    super.initState();
    // For business owner, we just fetch webhooks in the bloc.
  }

  void _generateWebhook(BuildContext context) {
    final state = context.read<WebChatBloc>().state;
    if (state is WebChatLoaded) {
      final exists = state.webhooks.any((w) => w.branchId == widget.branchId);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A Webhook is already generated for this branch.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    context.read<WebChatBloc>().add(
          GenerateWebhook(
            businessId: '', // Assume backend extracts businessId from token or branch
            branchId: widget.branchId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;

    return BlocListener<WebChatBloc, WebChatState>(
      listener: (context, state) {
        if (state is WebChatOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is WebChatOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Web Chat',
                      style: TextStyle(
                        fontSize: width < 600 ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage and generate webhooks for web chat',
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _generateWebhook(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Generate Webhook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.transparent,
              ),
            ),
            child: BlocBuilder<WebChatBloc, WebChatState>(
              builder: (context, state) {
                if (state is WebChatLoading) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(),
                  ));
                } else if (state is WebChatError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (state is WebChatLoaded) {
                  final webhooks = state.webhooks;
                  return Column(
                    children: [
                      _buildTableHeader(theme),
                      if (webhooks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text("No webhooks found")),
                        )
                      else
                        ...webhooks.map((webhook) => _buildRow(webhook, theme, context)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : AppColor.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: _headerText('Business Name', theme)),
          Expanded(flex: 2, child: _headerText('Branch Name', theme)),
          Expanded(flex: 2, child: _headerText('Phone', theme)),
          Expanded(flex: 2, child: _headerText('Address', theme)),
          Expanded(flex: 3, child: _headerText('URL', theme)),
          Expanded(flex: 1, child: _headerText('Status', theme, center: true)),
        ],
      ),
    );
  }

  Widget _headerText(String text, ThemeData theme, {bool center = false}) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyMedium?.color,
      ),
    );
  }

  Widget _buildRow(WebChatWebhook webhook, ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2, 
            child: Text(webhook.businessName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 2, 
            child: Text(webhook.branchName, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 2, 
            child: Text(webhook.branchPhone, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 2, 
            child: Text(webhook.branchAddress, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 3, 
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    webhook.url,
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: webhook.url));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1, 
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: webhook.isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  webhook.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 12, 
                    color: webhook.isActive ? Colors.green : Colors.red, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


