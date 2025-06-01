import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';

// Mock models - replace with your actual models
class EventModel {
  final int id;
  final String eventName;
  final String eventDescription;
  final String tag;
  final DateTime startDate;
  final DateTime endDate;
  final String eventImage;
  final String campus;
  final String place;
  final double rate;
  final bool isActive;

  EventModel({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    required this.tag,
    required this.startDate,
    required this.endDate,
    required this.eventImage,
    required this.campus,
    required this.place,
    required this.rate,
    this.isActive = true,
  });
}

class ManageEvents extends StatefulWidget {
  final UserProfile? userProfile;
  const ManageEvents({super.key, required this.userProfile});

  @override
  State<ManageEvents> createState() => _ManageEventsState();
}

class _ManageEventsState extends State<ManageEvents> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Date';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'Upcoming', 'Ended', 'Cancelled', 'Pending'];
  final List<String> _sortOptions = ['Date', 'Name', 'Rating'];

  // Mock data - replace with your actual data source
  List<EventModel>? _allEvents;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<EventModel> get _filteredEvents {
    List<EventModel> filtered = _allEvents;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
      event.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.eventDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.tag.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    switch (_selectedFilter) {
      case 'Active':
        filtered = filtered.where((event) =>
        event.isActive && event.startDate.isAfter(DateTime.now())
        ).toList();
        break;
      case 'Completed':
        filtered = filtered.where((event) =>
            event.endDate.isBefore(DateTime.now())
        ).toList();
        break;
      case 'Cancelled':
        filtered = filtered.where((event) => !event.isActive).toList();
        break;
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.eventName.compareTo(b.eventName));
        break;
      case 'Rating':
        filtered.sort((a, b) => b.rate.compareTo(a.rate));
        break;
      case 'Date':
      default:
        filtered.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
    }

    return filtered;
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSearchAndFilters(colorScheme),
                    const SizedBox(height: 16),
                    _buildStatsCards(colorScheme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildEventsList(colorScheme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEvent(),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
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
          'Manage Events',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshEvents(),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Export Events'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(ColorScheme colorScheme) {
    return Column(
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),
        // Filter and Sort Row
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(colorScheme),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSortDropdown(colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainer,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: Icon(Icons.filter_list, color: colorScheme.primary),
          isExpanded: true,
          onChanged: (value) => setState(() => _selectedFilter = value!),
          items: _filterOptions.map((filter) => DropdownMenuItem(
            value: filter,
            child: Text(filter),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildSortDropdown(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainer,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortBy,
          icon: Icon(Icons.sort, color: colorScheme.primary),
          isExpanded: true,
          onChanged: (value) => setState(() => _sortBy = value!),
          items: _sortOptions.map((sort) => DropdownMenuItem(
            value: sort,
            child: Text('Sort by $sort'),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsCards(ColorScheme colorScheme) {
    final activeEvents = _allEvents.where((e) => e.isActive && e.startDate.isAfter(DateTime.now())).length;
    final completedEvents = _allEvents.where((e) => e.endDate.isBefore(DateTime.now())).length;
    final totalEvents = _allEvents.length;

    return Row(
      children: [
        Expanded(child: _buildStatCard(colorScheme, 'Total', totalEvents.toString(), Icons.event, Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(colorScheme, 'Active', activeEvents.toString(), Icons.play_circle, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(colorScheme, 'Completed', completedEvents.toString(), Icons.check_circle, Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(ColorScheme colorScheme, String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ColorScheme colorScheme) {
    final filteredEvents = _filteredEvents;

    if (filteredEvents.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final event = filteredEvents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildEventCard(event, colorScheme),
            );
          },
          childCount: filteredEvents.length,
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, ColorScheme colorScheme) {
    final isUpcoming = event.startDate.isAfter(DateTime.now());
    final isPast = event.endDate.isBefore(DateTime.now());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewEventDetails(event),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceVariant,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.event,
                        color: colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.eventName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusChip(event, colorScheme, isUpcoming, isPast),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.tag,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.eventDescription,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Event Info Row
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${event.campus}, ${event.place}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      index < event.rate.floor() ? Icons.star : Icons.star_outline,
                      size: 14,
                      color: Colors.amber,
                    )),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.rate.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _viewEventDetails(event),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                  TextButton.icon(
                    onPressed: isUpcoming ? () => _editEvent(event) : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () => _duplicateEvent(event),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Duplicate'),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteEvent(event),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(EventModel event, ColorScheme colorScheme, bool isUpcoming, bool isPast) {
    String status;
    Color backgroundColor;
    Color textColor;

    if (!event.isActive) {
      status = 'Cancelled';
      backgroundColor = colorScheme.errorContainer;
      textColor = colorScheme.error;
    } else if (isPast) {
      status = 'Completed';
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    } else if (isUpcoming) {
      status = 'Upcoming';
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
    } else {
      status = 'Ongoing';
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Action Methods
  void _navigateToAddEvent() {
    // Navigate to AddEventPage
    print('Navigate to Add Event');
  }

  void _refreshEvents() {
    setState(() {
      // Refresh events from data source
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Events refreshed')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportEvents();
        break;
      case 'settings':
        _openSettings();
        break;
    }
  }

  void _exportEvents() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting events...')),
    );
  }

  void _openSettings() {
    // Navigate to settings
    print('Open Settings');
  }

  void _viewEventDetails(EventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventDetailsSheet(event),
    );
  }

  Widget _buildEventDetailsSheet(EventModel event) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.tag,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.eventDescription,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Start Date',
                          '${event.startDate.day}/${event.startDate.month}/${event.startDate.year} ${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}',
                          Icons.schedule, colorScheme),
                      _buildDetailRow('End Date',
                          '${event.endDate.day}/${event.endDate.month}/${event.endDate.year} ${event.endDate.hour.toString().padLeft(2, '0')}:${event.endDate.minute.toString().padLeft(2, '0')}',
                          Icons.schedule_outlined, colorScheme),
                      _buildDetailRow('Location', '${event.campus}, ${event.place}', Icons.location_on, colorScheme),
                      _buildDetailRow('Rating', '${event.rate}/5.0', Icons.star, colorScheme),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _editEvent(event);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Event'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteEvent(event);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(color: colorScheme.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent(EventModel event) {
    // Navigate to edit event page
    print('Edit event: ${event.eventName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${event.eventName}')),
    );
  }

  void _duplicateEvent(EventModel event) {
    // Create a copy of the event
    print('Duplicate event: ${event.eventName}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${event.eventName} duplicated')),
    );
  }

  void _deleteEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Event'),
          ],
        ),
        content: Text('Are you sure you want to delete "${event.eventName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allEvents.removeWhere((e) => e.id == event.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${event.eventName} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}