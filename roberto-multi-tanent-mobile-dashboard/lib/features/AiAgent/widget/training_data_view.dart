import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:roberto/app/app_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';

class TrainingDataView extends StatefulWidget {
  const TrainingDataView({super.key});

  @override
  State<TrainingDataView> createState() => _TrainingDataViewState();
}

class _TrainingDataViewState extends State<TrainingDataView> {

  List<String> selectedFiles = [];

  Future<void> pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        selectedFiles.add(result.files.single.name);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Texts
          Text(
            'Business Training Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide business-specific information to train your AI agent',
            style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(height: 24),

          // Business Information Textfield
          Text(
            'Business Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextfield(hintText: "Business name, location, hours of operation...",),
          const SizedBox(height: 20),

          // Product Information Upload
          _buildUploadSection(
            label: 'Product Information',
            iconText: 'upload excel',
            iconData: Icons.cloud_upload_outlined,
          ),
          const SizedBox(height: 20),

          // Policies & Guidelines Upload
          _buildUploadSection(
            label: 'Policies & Guidelines',
            iconText: 'upload pdf',
            iconData: Icons.cloud_upload_outlined,
          ),
          const SizedBox(height: 20),

          // Common FAQs Upload
          _buildUploadSection(
            label: 'Common FAQs',
            iconText: 'upload pdf',
            iconData: Icons.cloud_upload_outlined,
          ),
          const SizedBox(height: 24),

          // Save button (left aligned)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text(
              'Save Training Data',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection({
    required String label,
    required String iconText,
    required IconData iconData,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            pickFile(label);
            },
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            painter: DashedRectPainter(
              color: theme.colorScheme.primary,
              strokeWidth: 1.5,
              dashWidth: 6.0,
              dashSpace: 4.0,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    iconText,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)));

    try {
      for (final pathMetric in path.computeMetrics()) {
        bool draw = true;
        double distance = 0.0;
        while (distance < pathMetric.length) {
          double length = draw ? dashWidth : dashSpace;
          if (distance + length > pathMetric.length) {
            length = pathMetric.length - distance;
          }
          if (draw) {
            canvas.drawPath(
                pathMetric.extractPath(distance, distance + length), paint);
          }
          distance += length;
          draw = !draw;
        }
      }
    } catch (e) {
      // Fallback
       canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
