import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property_model.dart';
import '../services/stripe_service.dart';

class BookingFormScreen extends StatefulWidget {
  final Property property;

  const BookingFormScreen({super.key, required this.property});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  DateTime? selectedDate;
  String? selectedSlot;
  bool _agreedToTerms = false;
  bool _isLoadingBookings = true;

  // Store booked slots. Key: Date (YYYY-MM-DD), Value: List of booked slots
  Map<String, List<String>> bookedSlots = {};

  final List<String> timeSlots = [
    "Morning (8:00 AM - 12:00 PM)",
    "Evening (1:00 PM - 5:00 PM)",
    "Night (6:00 PM - 11:00 PM)",
    "Full Day (8:00 AM - 5:00 PM)"
  ];

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExistingBookings();
  }

  Future<void> _fetchExistingBookings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('property_bookings')
          .where('property_name', isEqualTo: widget.property.name)
          .get();

      Map<String, List<String>> tempBooked = {};

      for (var doc in snapshot.docs) {
        // Keeping these safe fallbacks—they are excellent practice!
        String date = doc.data().containsKey('date') ? doc['date'] : 'NO_DATE';
        String slot = doc.data().containsKey('slot') ? doc['slot'] : 'NO_SLOT';

        if (!tempBooked.containsKey(date)) {
          tempBooked[date] = [];
        }
        tempBooked[date]!.add(slot);
      }

      setState(() {
        bookedSlots = tempBooked;
        _isLoadingBookings = false;
      });
    } catch (e) {
      debugPrint("Error fetching bookings: $e");
      setState(() => _isLoadingBookings = false);
    }
  }

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
      // This blocks the dates. Booked dates will become gray and unclickable.
      selectableDayPredicate: (DateTime day) {
        String formattedDay = day.toString().split(' ')[0];
        List<String>? slotsTaken = bookedSlots[formattedDay];

        if (slotsTaken != null) {
          if (slotsTaken.contains(timeSlots[3])) return false; // Full Day taken
          if (slotsTaken.contains(timeSlots[0]) &&
              slotsTaken.contains(timeSlots[1]) &&
              slotsTaken.contains(timeSlots[2])) {
            return false; // Morning, Evening, and Night all taken
          }
        }
        return true; // Date is available
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green, // Header, selected date, and active elements are green
              onPrimary: Colors.white,
              onSurface: Colors.black, // Available dates text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green, // "OK" and "Cancel" buttons
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedSlot = null; // Reset slot when a new valid date changes
      });
      print("DEBUG (UT-PB-05) -> setState triggered: Selected Date changed to $selectedDate");
    }
  }

  List<DropdownMenuItem<String>> _getAvailableTimeSlots() {
    if (selectedDate == null) return [];

    String formattedDay = selectedDate.toString().split(' ')[0];
    List<String> slotsTaken = bookedSlots[formattedDay] ?? [];

    return timeSlots.map((String slot) {
      bool isTaken = slotsTaken.contains(slot);

      if (slot == timeSlots[3] && (slotsTaken.contains(timeSlots[0]) || slotsTaken.contains(timeSlots[1]))) {
        isTaken = true;
      }
      if ((slot == timeSlots[0] || slot == timeSlots[1]) && slotsTaken.contains(timeSlots[3])) {
        isTaken = true;
      }

      return DropdownMenuItem<String>(
        value: slot,
        enabled: !isTaken,
        child: Text(
          isTaken ? "$slot - BOOKED" : slot,
          style: TextStyle(
            color: isTaken ? Colors.red : Colors.black,
            fontWeight: isTaken ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }).toList();
  }

  Future<void> _submitBookingRequest() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter contact details."), backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedDate == null || selectedSlot == null || !_agreedToTerms) return;

    try {
      await StripeService.makePayment(context, _calculatedPrice, () async {
        showDialog(
          context: context, barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22))),
        );


        final String formattedDate = selectedDate.toString().split(' ')[0];
        print("DEBUG (UT-PB-02) -> Formatted Date for DB: $formattedDate");
        final user = FirebaseAuth.instance.currentUser;

        final bookingData = {
          "user_id": user?.uid,
          "property_name": widget.property.name,
          "price": _calculatedPrice,
          "date": formattedDate,
          "slot": selectedSlot,
          "contact_name": _nameController.text.trim(),
          "contact_number": _phoneController.text.trim(),
          "purpose": _reasonController.text.trim(),
          "status": "Paid",
          "timestamp": FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('property_bookings').add(bookingData);

        if (!mounted) return;
        Navigator.of(context).pop();
        _showPaymentSuccessDialog();
      });
    } catch (e) {
      debugPrint("Stripe flow interrupted: $e");
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        title: const Text("Payment Successful!"),
        content: Text("Your booking for ${widget.property.name} is confirmed and paid."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("Go to Home"),
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
        title: const Text("Instant Booking"),
        backgroundColor: const Color(0xFFE67E22),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingBookings
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE67E22)))
          : SingleChildScrollView(
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
              value: selectedSlot,
              items: _getAvailableTimeSlots(),
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
          onPressed: (selectedDate != null && selectedSlot != null && _agreedToTerms)
              ? _submitBookingRequest
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE67E22),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: Text(
              _agreedToTerms ? "Pay & Book Instantly" : "Agree to Terms to Proceed",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }
}

