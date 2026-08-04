import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/TenantManagement/widget/custom_headder.dart';
import '../bloc/user_list_bloc.dart';
import '../bloc/user_list_event.dart';
import '../bloc/user_list_state.dart';
import '../data/models/user_list_model.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserListBloc>().add(FetchAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "All Users",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Manage and view all users in the system",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 24),
        
        BlocBuilder<UserListBloc, UserListState>(
          builder: (context, state) {
            if (state is UserListLoading) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ));
            } else if (state is UserListError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            } else if (state is UserListLoaded) {
              final users = state.users;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Users: ${users.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
                    ),
                    child: Column(
                      children: [
                        _buildTableHeader(theme),
                        if (users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: Text("No users found")),
                          )
                        else
                          ...users.map((user) => _buildRow(user, theme)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
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
      child: const Row(
        children: [
          Expanded(flex: 2, child: CustomHeadder(label: 'First Name')),
          Expanded(flex: 2, child: CustomHeadder(label: 'Last Name')),
          Expanded(flex: 2, child: CustomHeadder(label: 'Email')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Status')),
          Expanded(flex: 1, child: CustomHeadder(label: 'Verified', textAlign: TextAlign.center)),
          Expanded(flex: 1, child: CustomHeadder(label: 'Created At', textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildRow(UserModel user, ThemeData theme) {
    String formattedDate = '';
    if (user.createdAt != null) {
      try {
        final date = DateTime.parse(user.createdAt!);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (_) {}
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xffEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2, 
            child: Text(user.firstName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 2, 
            child: Text(user.lastName ?? '-', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 2, 
            child: Text(user.email, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
          ),
          Expanded(
            flex: 1, 
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.status == 'ACTIVE' 
                      ? Colors.green.withValues(alpha: 0.1) 
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.status ?? 'UNKNOWN',
                  style: TextStyle(
                    fontSize: 12, 
                    color: user.status == 'ACTIVE' ? Colors.green : Colors.orange, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1, 
            child: Icon(
              user.isVerified ? Icons.check_circle : Icons.cancel, 
              color: user.isVerified ? Colors.green : Colors.grey, 
              size: 20,
            ),
          ),
          Expanded(
            flex: 1, 
            child: Text(
              formattedDate, 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: theme.textTheme.bodySmall?.color),
            ),
          ),
        ],
      ),
    );
  }
}
