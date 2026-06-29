import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roberto/features/Auth/widget/custom_textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_bloc.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_event.dart';
import 'package:roberto/features/AiAgent/bloc/agent_training_state.dart';
import 'package:printing/printing.dart';

class TrainingDataView extends StatefulWidget {
  final String businessId;
  const TrainingDataView({super.key, required this.businessId});

  @override
  State<TrainingDataView> createState() => _TrainingDataViewState();
}

class _TrainingDataViewState extends State<TrainingDataView> {
  final TextEditingController _businessInfoController = TextEditingController();
  Map<String, List<PlatformFile>> uploadedFiles = {
    'Product Information': [],
    'Policies & Guidelines': [],
    'Common FAQs': [],
  };
  String? _trainingId;

  @override
  void initState() {
    super.initState();
    final state = context.read<AgentTrainingBloc>().state;
    if (state is SingleAgentTrainingLoaded) {
      _businessInfoController.text = state.training.businessInformation ?? '';
      _trainingId = state.training.id;
    }
  }

  @override
  void dispose() {
    _businessInfoController.dispose();
    super.dispose();
  }

  Future<void> pickFile(String label) async {
    if ((uploadedFiles[label] ?? []).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only upload one file for $label.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null) {
      setState(() {
        uploadedFiles[label]?.add(result.files.single);
      });
    }
  }

  void _saveTrainingData() {
    final businessInfo = _businessInfoController.text.trim();
    if (businessInfo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business information cannot be empty')),
      );
      return;
    }

    if (_trainingId != null) {
      context.read<AgentTrainingBloc>().add(
        UpdateAgentTrainingRequested(
          id: _trainingId!,
          data: {
            'businessInformation': businessInfo,
          }, // File upload not supported in PATCH right now
        ),
      );
    } else {
      context.read<AgentTrainingBloc>().add(
        CreateAgentTrainingRequested(
          businessId: widget.businessId,
          systemPrompt:
              '', // This will be set from system prompt tab, but if creating from here, we might need to handle empty.
          businessInformation: businessInfo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AgentTrainingBloc, AgentTrainingState>(
      listener: (context, state) {
        if (state is SingleAgentTrainingLoaded) {
          if (_businessInfoController.text.isEmpty) {
            _businessInfoController.text =
                state.training.businessInformation ?? '';
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
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
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
            CustomTextfield(
              hintText: "Business name, location, hours of operation...",
              controller: _businessInfoController,
              maxLines: 4,
            ),
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
              onPressed: _saveTrainingData,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text(
                'Save Training Data',
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
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String label,
    required String iconText,
    required IconData iconData,
  }) {
    final theme = Theme.of(context);
    final files = uploadedFiles[label] ?? [];

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
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.map((file) => _buildFileItem(file)),
        ],
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    return InkWell(
      onTap: () => _showFilePreview(file),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.insert_drive_file,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  for (var key in uploadedFiles.keys) {
                    uploadedFiles[key]?.remove(file);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePreview(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    Widget previewContent;
    
    Future<Uint8List> getBytes() async {
      if (file.bytes != null) return file.bytes!;
      if (!kIsWeb && file.path != null) {
        return await File(file.path!).readAsBytes();
      }
      throw Exception('Cannot read file data');
    }

    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
      previewContent = FutureBuilder<Uint8List>(
        future: getBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.contain);
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading image'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else if (ext == 'pdf') {
      previewContent = PdfPreview(
        build: (format) => getBytes(),
        allowPrinting: false,
        allowSharing: false,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      );
    } else if (ext == 'txt' || ext == 'csv' || ext == 'md') {
      previewContent = FutureBuilder<Uint8List>(
        future: getBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(utf8.decode(snapshot.data!, allowMalformed: true)),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading text'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      previewContent = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Preview not available for this file type.'),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      file.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: previewContent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
    );

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
              pathMetric.extractPath(distance, distance + length),
              paint,
            );
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
