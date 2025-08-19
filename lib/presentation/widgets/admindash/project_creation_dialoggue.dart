import 'package:delemon/core/service/project_service.dart';
import 'package:delemon/data/models/project_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProjectCreationDialog extends StatefulWidget {
  final VoidCallback onProjectCreated;
  final Function(String) onError;

  const ProjectCreationDialog({
    super.key,
    required this.onProjectCreated,
    required this.onError,
  });

  static void show({
    required BuildContext context,
    required VoidCallback onProjectCreated,
    required Function(String) onError,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: ProjectCreationDialog(
            onProjectCreated: onProjectCreated,
            onError: onError,
          ),
        ),
      ),
    );
  }

  @override
  State<ProjectCreationDialog> createState() => _ProjectCreationDialogState();
}

class _ProjectCreationDialogState extends State<ProjectCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _projectService = ProjectService();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildNameField(),
          const SizedBox(height: 12),
          _buildDescriptionField(),
          const SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Create New Project", style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: "Project Name *",
        hintText: "Enter project name",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.folder_outlined),
      ),
      validator: (name) {
        if (name == null || name.trim().isEmpty) {
          return 'Project name is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descController,
      decoration: InputDecoration(
        labelText: "Description",
        hintText: "Enter project description (optional)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.description_outlined),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSave,
        child: const Text("Save Project"),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final newProject = ProjectModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      archived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: '',
    );

    try {
      await _projectService.createProject(newProject);
      Navigator.pop(context);
      widget.onProjectCreated();
    } catch (e) {
      widget.onError(e.toString());
    }
  }
}