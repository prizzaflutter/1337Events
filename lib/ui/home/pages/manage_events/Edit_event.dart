import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/ui/view_models/event_cubit/event_cubit.dart';

class EditEventPage extends StatefulWidget {
  final NewEventModel event;

  const EditEventPage({
    super.key,
    required this.event,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  late TextEditingController _eventTagController;
  late TextEditingController _eventImageController;
  late TextEditingController _campusController;
  late TextEditingController _placeController;
  late TextEditingController _capacityController;

  // Date and time variables
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;

  bool _isLoading = false;
  bool _hasChanges = false;

  // Campus options
  final List<String> _campusOptions = [
    'Khouribga',
    'Ben Guerir',
    'Tetouan',
    'Med',
    'Benguerir',
    'Other'
  ];

  // Tag options
  final List<String> _tagOptions = [
    'Workshop',
    'Conference',
    'Competition',
    'Social',
    'Academic',
    'Sports',
    'Cultural',
    'Technology',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    final event = widget.event;
    _eventNameController = TextEditingController(text: event.eventName);
    _eventDescriptionController = TextEditingController(text: event.eventDescription);
    _eventTagController = TextEditingController(text: event.tag);
    _eventImageController = TextEditingController(text: event.eventImage ?? '');
    _campusController = TextEditingController(text: event.location.campus);
    _placeController = TextEditingController(text: event.location.place);
    // _capacityController = TextEditingController(text: event.eventCapacity.toString());
    _capacityController = TextEditingController(text: "30");


    _startDate = event.startDate;
    _startTime = TimeOfDay.fromDateTime(event.startDate);
    _endDate = event.endDate;
    _endTime = TimeOfDay.fromDateTime(event.endDate);

    // Add listeners to track changes
    _eventNameController.addListener(_onFieldChanged);
    _eventDescriptionController.addListener(_onFieldChanged);
    _eventTagController.addListener(_onFieldChanged);
    _eventImageController.addListener(_onFieldChanged);
    _campusController.addListener(_onFieldChanged);
    _placeController.addListener(_onFieldChanged);
    _capacityController.addListener(_onFieldChanged);
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventTagController.dispose();
    _eventImageController.dispose();
    _campusController.dispose();
    _placeController.dispose();
    _capacityController.dispose();
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
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventImageSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildBasicInfoSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildDateTimeSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildLocationSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildCapacitySection(colorScheme),
                      const SizedBox(height: 32),
                      _buildActionButtons(colorScheme),
                      const SizedBox(height: 100), // Bottom padding for FAB
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
          'Edit Event',
          style: TextStyle(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildEventImageSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.image, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Event Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Image preview
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceVariant,
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _eventImageController.text.isNotEmpty
                    ? Image.network(
                  _eventImageController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(colorScheme),
                )
                    : _buildImagePlaceholder(colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 8),
        Text(
          'Add Event Image',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name *',
                hintText: 'Enter event name',
                prefixIcon: const Icon(Icons.event),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Event name is required';
                }
                if (value.trim().length < 3) {
                  return 'Event name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tagOptions.contains(_eventTagController.text)
                  ? _eventTagController.text
                  : 'Other',
              decoration: InputDecoration(
                labelText: 'Event Tag *',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              items: _tagOptions.map((tag) => DropdownMenuItem(
                value: tag,
                child: Text(tag),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  _eventTagController.text = value;
                  _onFieldChanged();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an event tag';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Event Description *',
                hintText: 'Describe your event...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Event description is required';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Date & Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    'Start Date',
                    _startDate,
                    _startTime,
                    Icons.play_arrow,
                        () => _selectStartDateTime(),
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeField(
                    'End Date',
                    _endDate,
                    _endTime,
                    Icons.stop,
                        () => _selectEndDateTime(),
                    colorScheme,
                  ),
                ),
              ],
            ),
            if (_endDate.isBefore(_startDate) ||
                (_endDate.isAtSameMomentAs(_startDate) &&
                    _endTime.hour * 60 + _endTime.minute <= _startTime.hour * 60 + _startTime.minute))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'End date/time must be after start date/time',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
      String label,
      DateTime date,
      TimeOfDay time,
      IconData icon,
      VoidCallback onTap,
      ColorScheme colorScheme,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
          color: colorScheme.surfaceContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${time.format(context)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _campusOptions.contains(_campusController.text)
                  ? _campusController.text
                  : 'Other',
              decoration: InputDecoration(
                labelText: 'Campus *',
                prefixIcon: const Icon(Icons.school),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              items: _campusOptions.map((campus) => DropdownMenuItem(
                value: campus,
                child: Text(campus),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  _campusController.text = value;
                  _onFieldChanged();
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a campus';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _placeController,
              decoration: InputDecoration(
                labelText: 'Specific Location *',
                hintText: 'e.g., Room 101, Auditorium A',
                prefixIcon: const Icon(Icons.place),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Location is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Event Capacity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Maximum Participants *',
                hintText: 'Enter number of participants',
                prefixIcon: const Icon(Icons.group),
                suffixText: 'people',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Capacity is required';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Please enter a valid capacity';
                }
                if (capacity > 10000) {
                  return 'Capacity cannot exceed 10,000';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveEvent,
            icon: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.save),
            label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : () => _showDiscardDialog(colorScheme),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Event handling methods
  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _startTime,
      );

      if (time != null) {
        setState(() {
          _startDate = date;
          _startTime = time;
          _onFieldChanged();
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _endTime,
      );

      if (time != null) {
        setState(() {
          _endDate = date;
          _endTime = time;
          _onFieldChanged();
        });
      }
    }
  }


  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date/time
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date/time must be after start date/time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedEvent = widget.event.copyWith(
        eventName: _eventNameController.text.trim(),
        eventDescription: _eventDescriptionController.text.trim(),
        tag: _eventTagController.text.trim(),
        location: widget.event.location.copyWith(
          campus: _campusController.text.trim(),
          place: _placeController.text.trim(),
        ),
        startDate: startDateTime,
        endDate: endDateTime,
      );

      // Call your EventCubit update method
      await context.read<EventCubit>().updateEvent(widget.event.id.toString(), updatedEvent, false);

      if (mounted) {
        Navigator.pop(context, updatedEvent);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDiscardDialog(ColorScheme colorScheme) {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Discard Changes'),
          ],
        ),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}