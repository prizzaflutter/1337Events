import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/domain/firebase/usercases/event_usecases/add_new_event_usecase.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/widgets_for_new_event/event_preview_widget.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/widgets_for_new_event/event_section_title_widget.dart';

class AddEventPageFroAdmin extends StatefulWidget {
  final UserProfile userProfile;
  final bool isClubAdmin ;
  final AddNewEventUseCase addNewEventUseCase;

  const AddEventPageFroAdmin({super.key,  required this.userProfile, required this.addNewEventUseCase,required this.isClubAdmin});

  @override
  State<AddEventPageFroAdmin> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPageFroAdmin> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _campusController = TextEditingController();
  final _placeController = TextEditingController();

  // Form data
  String _selectedTag = 'Conference';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(hours: 2));
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Available tags
  final List<String> _eventTags = [
    'Conference', 'Workshop', 'Seminar', 'Meeting', 'Social',
    'Sports', 'Cultural', 'Academic', 'Competition', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Add listeners for real-time preview updates
    _eventNameController.addListener(_updatePreview);
    _eventDescriptionController.addListener(_updatePreview);
    _campusController.addListener(_updatePreview);
    _placeController.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {}); // Trigger rebuild for real-time preview
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _campusController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(colorScheme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEventPreview(
                        context,
                        colorScheme,
                        _eventNameController,
                        _eventDescriptionController,
                        _campusController,
                        _placeController,
                        _startDate,
                        _selectedTag,
                        _selectedImage,
                      ),
                      const SizedBox(height: 30),
                      _buildFormSection(colorScheme),
                      const SizedBox(height: 40),
                      _buildActionButtons(colorScheme),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Create Event',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => _showHelpDialog(),
        ),
      ],
    );
  }

  Widget _buildFormSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(context, 'Event Details', Icons.info_outline),
        const SizedBox(height: 16),
        _buildEventImageField(colorScheme),
        const SizedBox(height: 20),
        _buildEventNameField(),
        const SizedBox(height: 20),
        _buildEventDescriptionField(),
        const SizedBox(height: 20),
        _buildTagSelection(colorScheme),
        const SizedBox(height: 30),
        buildSectionTitle(context,'Schedule', Icons.schedule),
        const SizedBox(height: 16),
        _buildDateTimeSection(colorScheme),
        const SizedBox(height: 30),

        buildSectionTitle(context,'Location', Icons.location_on),
        const SizedBox(height: 16),
        _buildLocationSection(),
      ],
    );
  }

  Widget _buildEventImageField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Image *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedImage == null
                    ? colorScheme.error
                    : colorScheme.outline,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: _selectedImage != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to add event image',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Required',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImage == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select an event image',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Image Error', 'Failed to pick image. Please try again.');
    }
  }


  Widget _buildEventNameField() {
    return TextFormField(
      controller: _eventNameController,
      decoration: InputDecoration(
        labelText: 'Event Name',
        hintText: 'Enter a compelling event name',
        prefixIcon: const Icon(Icons.event),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an event name';
        }
        if (value.length < 3) {
          return 'Event name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEventDescriptionField() {
    return TextFormField(
      controller: _eventDescriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Event Description',
        hintText: 'Describe your event in detail...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an event description';
        }
        if (value.length < 10) {
          return 'Description must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildTagSelection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _eventTags.map((tag) {
            final isSelected = _selectedTag == tag;
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedTag = tag;
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildDateTimeRow(
            'Start Date & Time',
            _startDate,
            Icons.play_arrow,
                (date) => setState(() => _startDate = date),
          ),
          const SizedBox(height: 16),
          _buildDateTimeRow(
            'End Date & Time',
            _endDate,
            Icons.stop,
                (date) => setState(() => _endDate = date),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow(String label, DateTime dateTime, IconData icon, Function(DateTime) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _selectDateTime(dateTime, onChanged),
          icon: Icon(Icons.edit_calendar, color: colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        TextFormField(
          controller: _campusController,
          decoration: InputDecoration(
            labelText: 'Campus',
            hintText: 'Enter campus name',
            prefixIcon: const Icon(Icons.school),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a campus name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _placeController,
          decoration: InputDecoration(
            labelText: 'Specific Location',
            hintText: 'Building, room number, etc.',
            prefixIcon: const Icon(Icons.place),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a specific location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Create Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel_outlined, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(DateTime currentDateTime, Function(DateTime) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (time != null && mounted) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(newDateTime);
      }
    }
  }

  void _submitForm() async{
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        _showErrorDialog('Missing Image', 'Please select an event image before creating the event.');
        return;
      }
      if (_startDate.isAfter(_endDate)) {
        _showErrorDialog('Invalid Dates', 'End date must be after start date.');
        return;
      }
      // Create NewEventModel with the form data
      NewEventModel model = NewEventModel(
        visits: [],
        status: widget.isClubAdmin ? 'pending' : 'active', // Set status based on isClubAdmin
        speaker: widget.userProfile.firstName,
        feedbacks: [],
        registeredUsers: [],
        id: DateTime.now().millisecondsSinceEpoch,
        tag: _selectedTag,
        eventName: _eventNameController.text,
        eventDescription: _eventDescriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        eventImage: _selectedImage!.path.toString(),
        location: LocationEventModel(
          campus: _campusController.text,
          place: _placeController.text,
        ),
        rate: 0.0,
      );
      await widget.addNewEventUseCase.call(model, filePath: _selectedImage!.path);
      // todo : save to firestore
      // Show success dialog
      _showSuccessDialog(model);
    }
  }

  void _showSuccessDialog(NewEventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Success!'),
          ],
        ),
        content: Text('Event "${event.eventName}" has been created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.help, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text('Help'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tips for creating a great event:'),
            SizedBox(height: 8),
            Text('• Add an attractive event image'),
            Text('• Use a clear, descriptive event name'),
            Text('• Provide detailed description'),
            Text('• Choose appropriate category'),
            Text('• Include specific location details'),
            Text('• Set realistic dates and times'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}