import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';

class BookingFormScreen extends StatefulWidget {
  final Property property;

  const BookingFormScreen({super.key, required this.property});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

// NEW: State for the Terms and Conditions checkbox
bool _agreedToTerms = false;

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? selectedDate;
  String? selectedSlot;
  final List<String> timeSlots = [
    "Morning (8:00 AM - 12:00 PM)",
    "Evening (1:00 PM - 5:00 PM)",
    "Night (6:00 PM - 11:00 PM)",
    "Full Day (8:00 AM - 5:00 PM)"
  ];
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String get _calculatedPrice {
    if (selectedSlot == null) return widget.property.price;
    String rawPriceString = widget.property.price.replaceAll(RegExp(r'[^0-9]'), '');
    int basePrice = int.tryParse(rawPriceString) ?? 0;
    int finalPrice = selectedSlot!.contains('Full Day') ? (basePrice * 2) : basePrice;

    String formattedPrice = finalPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    );
    return 'LKR $formattedPrice';
  }

  Future<void> _callCouncil() async {
    final Uri url = Uri.parse('tel:${widget.property.contactNumber.replaceAll(" ", "")}');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open phone dialer")),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67E22),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitBookingRequest() async {
    // 1. NEW: VALIDATE TEXT FIELDS (Name & Phone)
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your Contact Name and Phone Number."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. NEW: VALIDATE CHECKBOX & DROPDOWNS
    if (selectedDate == null || selectedSlot == null || !_agreedToTerms) return;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22))),
    );

    try {
      final String formattedDate = selectedDate.toString().split(' ')[0];

      // Check for conflicts
      final existingBookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('property_name', isEqualTo: widget.property.name)
          .where('date', isEqualTo: formattedDate)
          .where('slot', isEqualTo: selectedSlot)
          .where('status', whereIn: ['Pending', 'Approved', 'Confirmed'])
          .get();

      if (existingBookings.docs.isNotEmpty) {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sorry, this time slot is already booked or pending approval."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 3. NEW: SAVE EVERYTHING TO FIRESTORE (including name and phone)
      final bookingData = {
        "user_id": "current_user_id",
        "property_name": widget.property.name,
        "price": _calculatedPrice,
        "date": formattedDate,
        "slot": selectedSlot,
        "contact_name": _nameController.text.trim(),     // Saves Name
        "contact_number": _phoneController.text.trim(), // Saves Phone
        "reason": _reasonController.text.trim(),
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('bookings').add(bookingData);

      if (!mounted) return;
      Navigator.of(context).pop();
      _showRequestSuccessDialog();

    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request: $e")),
      );
    }
  }

  void _showRequestSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.access_time_filled, color: Colors.blue, size: 50),
        title: const Text("Request Submitted!"),
        content: const Text("Your booking request has been sent to the Admin. You will be notified once approved to make your payment."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Booking"),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(widget.property.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.property.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_calculatedPrice, style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? "Tap to choose a date"
                          : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}",
                      style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black, fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xFFE67E22)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Time Slot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              hint: const Text("Choose a slot"),
              initialValue: selectedSlot,
              items: timeSlots.map((String slot) {
                return DropdownMenuItem<String>(value: slot, child: Text(slot));
              }).toList(),
              onChanged: (newValue) => setState(() => selectedSlot = newValue),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Need a custom time slot? Call us to arrange:",
                      style: TextStyle(color: Colors.blue.shade800, fontSize: 13),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _callCouncil,
                    icon: const Icon(Icons.phone, size: 16),
                    label: Text(widget.property.contactNumber),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade900,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  )
                ],
              ),
            ),

            const Divider(),
            const SizedBox(height: 10),

            const Text("Contact Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            const Text("Purpose of Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: "E.g., Wedding reception, Annual meeting...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CheckboxListTile(
                value: _agreedToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                activeColor: const Color(0xFFE67E22),
                title: const Text(
                  "I agree to obey the venue rules, hand over the property at the promised time, and pay for any damages caused to the facilities.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // NEW: Button is completely disabled if the checkbox is false
          onPressed: (selectedDate != null && selectedSlot != null && _agreedToTerms)
              ? _submitBookingRequest
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE67E22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
          ),
          child: Text(
            // NEW: Button text tells them exactly what to do!
              _agreedToTerms ? "Request Booking" : "Agree to Terms to Proceed",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}