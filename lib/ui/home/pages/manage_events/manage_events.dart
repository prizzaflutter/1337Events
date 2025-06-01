import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:the_elsewheres/domain/Oauth/models/user_profile.dart';
import 'package:the_elsewheres/domain/firebase/model/new_event_model.dart';
import 'package:the_elsewheres/ui/home/pages/manage_events/Edit_event.dart';
import 'package:the_elsewheres/ui/view_models/event_cubit/event_cubit.dart';

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

  final List<String> _filterOptions = ['All', 'Upcoming', 'Ended', 'Cancelled', 'Active'];
  final List<String> _sortOptions = ['Date', 'Name', 'Campus'];

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

    // Start listening to events when the widget initializes
    context.read<EventCubit>().listenToEventsForStaff();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<NewEventModel> _filterAndSortEvents(List<NewEventModel> events) {
    List<NewEventModel> filtered = List.from(events);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
      event.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.eventDescription.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.tag.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply status filter
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Upcoming':
        filtered = filtered.where((event) =>
            event.startDate.isAfter(now)
        ).toList();
        break;
      case 'Ended':
        filtered = filtered.where((event) =>
            event.endDate.isBefore(now)
        ).toList();
        break;
      case 'Active':
        filtered = filtered.where((event) =>
        event.startDate.isBefore(now) && event.endDate.isAfter(now)
        ).toList();
        break;
    // Add more filters as needed
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.eventName.compareTo(b.eventName));
        break;
      case 'Campus':
        filtered.sort((a, b) => a.location.campus.compareTo(b.location.campus));
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
                    // Stats cards will be built inside BlocBuilder to access events
                    BlocBuilder<EventCubit, EventState>(
                      builder: (context, state) {
                        if (state is StaffListenEventSuccessState) {
                          return _buildStatsCards(colorScheme, state.events);
                        }
                        return _buildStatsCards(colorScheme, []);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Events list with BlocBuilder
            BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                return _buildEventsListWithState(colorScheme, state);
              },
            ),
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

  Widget _buildStatsCards(ColorScheme colorScheme, List<NewEventModel> events) {
    final now = DateTime.now();
    final activeEvents = events.where((e) =>
    e.startDate.isBefore(now) && e.endDate.isAfter(now)
    ).length;
    final upcomingEvents = events.where((e) => e.startDate.isAfter(now)).length;
    final completedEvents = events.where((e) => e.endDate.isBefore(now)).length;
    final totalEvents = events.length;

    // Create a list of stat data
    final List<StatCardData> statsData = [
      StatCardData('Total', totalEvents.toString(), Icons.event, Colors.blue),
      StatCardData('Active', activeEvents.toString(), Icons.play_circle, Colors.green),
      StatCardData('Upcoming', upcomingEvents.toString(), Icons.schedule, Colors.orange),
      StatCardData('Completed', completedEvents.toString(), Icons.check_circle, Colors.grey),
    ];

    return SizedBox(
      height: 110.h, // Fixed height for the grid
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 100,
          crossAxisCount: 1, // 2 columns
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 10/6, // Adjust the aspect ratio as needed
        ),
        itemCount: statsData.length,
        itemBuilder: (context, index) {
          final stat = statsData[index];
          return _buildStatCard(
            colorScheme,
            stat.title,
            stat.value,
            stat.icon,
            stat.iconColor,
          );
        },
      ),
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

  Widget _buildEventsListWithState(ColorScheme colorScheme, EventState state) {
    if (state is StaffListenEventLoadingState) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (state is StaffListenEventErrorState) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading events',
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<EventCubit>().listenToEventsForStaff(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is StaffListenEventSuccessState) {
      final filteredEvents = _filterAndSortEvents(state.events);
      return _buildEventsList(colorScheme, filteredEvents);
    }

    // Initial state or unknown state
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.event_note,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading events...',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList(ColorScheme colorScheme, List<NewEventModel> events) {
    if (events.isEmpty) {
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
            final event = events[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildEventCard(event, colorScheme),
            );
          },
          childCount: events.length,
        ),
      ),
    );
  }

  Widget _buildEventCard(NewEventModel event, ColorScheme colorScheme) {
    final now = DateTime.now();
    final isUpcoming = event.startDate.isAfter(now);
    final isPast = event.endDate.isBefore(now);
    final isActive = event.startDate.isBefore(now) && event.endDate.isAfter(now);

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
                      child: event.eventImage != null && event.eventImage!.isNotEmpty
                          ? Image.network(
                        event.eventImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.event,
                          color: colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                      )
                          : Icon(
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
                            _buildStatusChip(colorScheme, isUpcoming, isPast, isActive),
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
                      '${event.location.campus}, ${event.location.place}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
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
                    onPressed: !isUpcoming ? () => _editEvent(event) : null,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
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

  Widget _buildStatusChip(ColorScheme colorScheme, bool isUpcoming, bool isPast, bool isActive) {
    String status;
    Color backgroundColor;
    Color textColor;

    if (isPast) {
      status = 'Completed';
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    } else if (isActive) {
      status = 'Active';
      backgroundColor = Colors.blue.shade100;
      textColor = Colors.blue.shade700;
    } else if (isUpcoming) {
      status = 'Upcoming';
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
    } else {
      status = 'Scheduled';
      backgroundColor = colorScheme.surfaceVariant;
      textColor = colorScheme.onSurfaceVariant;
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
    context.go('/home/add-event', extra: widget.userProfile);
    print('Navigate to Add Event');
  }

  void _refreshEvents() {
    context.read<EventCubit>().listenToEventsForStaff();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing events...')),
    );
  }


  void _exportEvents() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting events...')),
    );
  }



  void _viewEventDetails(NewEventModel event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEventDetailsSheet(event),
    );
  }

  Widget _buildEventDetailsSheet(NewEventModel event) {
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
                      _buildDetailRow('Location', '${event.location.campus}, ${event.location.place}', Icons.location_on, colorScheme),
                      // todo : should i set event.capaity peaope insted of 10
                      _buildDetailRow('Capacity', '10 people', Icons.people, colorScheme),
                      if (event.eventImage != null && event.eventImage!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Event Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                event.eventImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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

  void _editEvent(NewEventModel event) {
    // Navigate to edit event page
    print('Edit event: ${event.eventName}');
    // context.go('/edit-event', extra: event);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return EditEventPage(
        event: event,
      );
    }));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing ${event.eventName}')),
    );
  }


  void _deleteEvent(NewEventModel event) {
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
              // Call your EventCubit delete method here
              context.read<EventCubit>().deleteEvent(event.id.toString());
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


// todo: this is for my stat card data: gridview .builder
class StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  StatCardData(this.title, this.value, this.icon, this.iconColor);
}