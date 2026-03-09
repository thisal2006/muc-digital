/*
import 'package:flutter/material.dart';
import 'crematorium_booking_data.dart';                    // ← Import the model
import 'crematorium_document_upload_screen.dart';          // ← For navigation

class CrematoriumEligibilityScreen extends StatefulWidget {
  final CrematoriumBookingData bookingData;  // ← This field receives the data

  const CrematoriumEligibilityScreen({
    super.key,
    required this.bookingData,  // ← Required named parameter
  });

  @override
  State<CrematoriumEligibilityScreen> createState() => _CrematoriumEligibilityScreenState();
}

class _CrematoriumEligibilityScreenState extends State<CrematoriumEligibilityScreen> {
  bool _isResident = false;
  String? _relation;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eligibility Check')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Please confirm eligibility for crematorium booking',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              CheckboxListTile(
                title: const Text('Deceased was a resident of Maharagama'),
                value: _isResident,
                onChanged: (value) {
                  setState(() => _isResident = value ?? false);
                },
              ),

              const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Relation to deceased',
                border: OutlineInputBorder(),
              ),
              initialValue: _relation,  // ← FIXED HERE
              items: ['Immediate family', 'Relative', 'Friend', 'Other']
                  .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                  .toList(),
              onChanged: (value) => setState(() => _relation = value),
              validator: (value) => value == null ? 'Required' : null,
            ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _isResident) {
                    // Create updated data with eligibility info
                    final updatedData = CrematoriumBookingData(
                      selectedDate: widget.bookingData.selectedDate,
                      timeSlot: widget.bookingData.timeSlot,
                      isResident: _isResident,
                      relation: _relation,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrematoriumDocumentUploadScreen(
                          bookingData: updatedData,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please complete eligibility requirements')),
                    );
                  }
                },
                child: const Text('Next: Upload Documents'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
