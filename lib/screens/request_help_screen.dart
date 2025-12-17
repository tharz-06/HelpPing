import 'package:flutter/material.dart';
import '../api_service.dart';

class RequestHelpScreen extends StatefulWidget {
  const RequestHelpScreen({super.key});

  @override
  State<RequestHelpScreen> createState() => _RequestHelpScreenState();
}

class _RequestHelpScreenState extends State<RequestHelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _urgency = 'Normal';

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await ApiService.createRequest(
        description: _descriptionController.text.trim(),
        urgency: _urgency,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent to helpers')),
      );
      _descriptionController.clear();
    } catch (e) {
      debugPrint('createRequest error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request help',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Describe what you need for the next few minutes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'What do you need help with?',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please describe your task'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _urgency,
                        decoration: const InputDecoration(
                          labelText: 'Urgency',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(18)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Normal', child: Text('Normal')),
                          DropdownMenuItem(
                              value: 'Urgent', child: Text('Urgent')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _urgency = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _submit,
                          child: const Text('Create request'),
                        ),
                      ),
                    ],
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
