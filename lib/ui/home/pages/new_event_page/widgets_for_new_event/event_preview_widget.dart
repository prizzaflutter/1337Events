
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/widgets_for_new_event/event_card_preview_widget.dart';
import 'package:the_elsewheres/ui/home/pages/new_event_page/widgets_for_new_event/event_section_title_widget.dart';
Widget buildEventPreview(BuildContext context,ColorScheme colorScheme,  TextEditingController _eventNameController,
    TextEditingController _eventDescriptionController,
    TextEditingController _campusController,
    TextEditingController _placeController,
    DateTime _startDate,
    String _selectedTag,
    File? _selectedImage) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildSectionTitle(context,'Event Preview', Icons.preview),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.1),
              colorScheme.secondaryContainer.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is how your event will appear to users:',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            buildEventCard(colorScheme,
              _eventNameController,
              _eventDescriptionController,
              _campusController,
              _placeController,
              _startDate,
              _selectedTag,
              _selectedImage,
            ),
          ],
        ),
      ),
    ],
  );
}
