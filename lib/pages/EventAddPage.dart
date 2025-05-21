import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cs_projesi/providers/auth_provider.dart';
import 'package:cs_projesi/firebase/firebase_service.dart';
import 'package:cs_projesi/models/event.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';

class EventAddPage extends ConsumerStatefulWidget {
  const EventAddPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EventAddPage> createState() => _EventAddPageState();
}

class _EventAddPageState extends ConsumerState<EventAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _whereController = TextEditingController();
  final _bringController = TextEditingController();
  final _goalController = TextEditingController();
  final _whenController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  File? _pickedImage;
  LatLng? _pickedLatLng;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _whereController.dispose();
    _bringController.dispose();
    _goalController.dispose();
    _whenController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File image, String eventId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('event_photos').child('$eventId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickLocationOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (context) => const _MapLocationPicker()),
    );
    if (result != null) {
      setState(() => _pickedLatLng = result);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a location on the map.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) throw Exception('Not logged in');
      final now = DateTime.now();
      final eventId = 'map_${now.microsecondsSinceEpoch}';
      String? photoUrl;
      if (_pickedImage != null) {
        photoUrl = await _uploadImage(_pickedImage!, eventId);
      }
      final event = Event(
        id: eventId,
        createdBy: user.uid,
        location: _locationController.text.trim(),
        coordinates: _pickedLatLng!,
        date: _selectedDate ?? now,
        descriptionMini: _titleController.text.trim(),
        eventPhotoPath: photoUrl ?? 'assets/nature_photos/orman_photo.jpg',
        descriptionLarge: _descController.text.trim(),
        where: _whereController.text.trim(),
        bring: _bringController.text.trim(),
        goal: _goalController.text.trim(),
        when: _whenController.text.trim(),
        createdAt: now,
      );
      await FirebaseService().createEvent(event);
      await FirebaseService().updateProfile(user.uid, {'hasEvent': true});
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage == null
                    ? Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(child: Text('Tap to pick event photo')),
                      )
                    : Image.file(_pickedImage!, height: 150, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickLocationOnMap,
                      icon: const Icon(Icons.map),
                      label: const Text('Pick Location on Map'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_pickedLatLng != null)
                    Text('Lat: ${_pickedLatLng!.latitude.toStringAsFixed(4)}, Lng: ${_pickedLatLng!.longitude.toStringAsFixed(4)}'),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whereController,
                decoration: const InputDecoration(labelText: 'Where (details)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bringController,
                decoration: const InputDecoration(labelText: 'What to bring'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Goal'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whenController,
                decoration: const InputDecoration(labelText: 'When (details)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'No date selected'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!)),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLocationPicker extends StatefulWidget {
  const _MapLocationPicker({Key? key}) : super(key: key);

  @override
  State<_MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<_MapLocationPicker> {
  LatLng? _picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(41.0082, 28.9784),
          initialZoom: 11.0,
          onTap: (tapPos, latlng) {
            setState(() => _picked = latlng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          if (_picked != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _picked!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: _picked != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _picked);
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
} 