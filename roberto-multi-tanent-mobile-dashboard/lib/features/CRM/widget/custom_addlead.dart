import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class CustomAddlead extends StatefulWidget {
  const CustomAddlead({super.key});

  @override
  State<CustomAddlead> createState() => _CustomAddleadState();
}

class _CustomAddleadState extends State<CustomAddlead> {

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardTheme.color,
      surfaceTintColor: Colors.transparent,

      //  Responsive width
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 20,
      ),

      titlePadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: 16,
      ),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add New Lead",
                style: TextStyle(fontSize: isDesktop ? 20 : 16),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "Enter the lead details to add to your pipeline",
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: isDesktop ? 450 : double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name"),
              const SizedBox(height: 6),
              const CustomTextfield(hintText: "Enter name"),

              const SizedBox(height: 15),

              const Text("Email"),
              const SizedBox(height: 6),
              const CustomTextfield(hintText: "email@example.com"),

              const SizedBox(height: 15),

              const Text("Phone"),
              const SizedBox(height: 6),
              const CustomTextfield(hintText: "+1 234 567 8900"),

              const SizedBox(height: 15),

              const Text("Source"),
              const SizedBox(height: 6),
              const CustomTextfield(hintText: "Facebook"),

              const SizedBox(height: 15),

              const Text("Note"),
              const SizedBox(height: 6),
              const CustomTextfield(hintText: "Add notes..."),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),

      actionsPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 12,
        vertical: 10,
      ),

      actions: [
        isDesktop
            ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _buttons(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buttons(),
        ),
      ],
    );
  }

  List<Widget> _buttons() {
    return [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).cardTheme.color,
          side: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xffEEEEEE)),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Cancel",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      const SizedBox(width: 10, height: 10),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text(
          "Create",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 15),
    ];
  }
}