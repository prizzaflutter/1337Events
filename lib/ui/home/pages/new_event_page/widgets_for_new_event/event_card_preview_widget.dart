import 'dart:io';

import 'package:flutter/material.dart';

Widget buildEventCard(ColorScheme colorScheme,
    TextEditingController _eventNameController,
    TextEditingController _eventDescriptionController,
    TextEditingController _campusController,
    TextEditingController _placeController,
    DateTime _startDate,
    String _selectedTag,
    File? _selectedImage) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 400),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              color: colorScheme.surfaceVariant,
            ),
            child: _selectedImage != null
                ? ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              Icons.image_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _selectedTag,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Event Name
                Text(
                  _eventNameController.text.isEmpty
                      ? 'Event Name'
                      : _eventNameController.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _eventNameController.text.isEmpty
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                // Event Description
                Text(
                  _eventDescriptionController.text.isEmpty
                      ? 'Event description will appear here...'
                      : _eventDescriptionController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: _eventDescriptionController.text.isEmpty
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Date and Time
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year} ${_startDate.hour.toString().padLeft(2, '0')}:${_startDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _campusController.text.isEmpty && _placeController.text.isEmpty
                            ? 'Location will appear here'
                            : '${_campusController.text} ${_placeController.text}'.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: (_campusController.text.isEmpty && _placeController.text.isEmpty)
                              ? colorScheme.onSurface.withOpacity(0.5)
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Rating placeholder
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) => Icon(
                        Icons.star_outline,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.3),
                      )),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No ratings yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
