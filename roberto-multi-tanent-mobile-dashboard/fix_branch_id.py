import re

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'r') as f:
    content = f.read()

# Remove the hardcoded _branchId
content = re.sub(r"  final String _branchId = '5feaac7b-c436-4ecb-8a12-9632e4090205';\n", "", content)

# Add a helper function to get branchId
helper = """
  String _getBranchId() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      return profileState.user.branchId ?? '';
    } else if (profileState is ProfileUpdateSuccess) {
      return profileState.user.branchId ?? '';
    }
    return '';
  }
"""
content = content.replace("  int selectedIndex = 0;", helper + "  int selectedIndex = 0;")

# Replace _branchId with _getBranchId()
content = content.replace("_branchId", "_getBranchId()")

# We need to import ProfileBloc and its state
if "import 'package:roberto/features/Auth/bloc/profile_bloc.dart';" not in content:
    content = content.replace("import 'package:flutter_bloc/flutter_bloc.dart';", "import 'package:flutter_bloc/flutter_bloc.dart';\nimport 'package:roberto/features/Auth/bloc/profile_bloc.dart';\nimport 'package:roberto/features/Auth/bloc/profile_state.dart';")

with open('lib/features/Orderbooking/screen/order_booking_screen.dart', 'w') as f:
    f.write(content)

