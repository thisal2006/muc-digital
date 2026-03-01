class CrematoriumBookingData {
  final DateTime? selectedDate;
  final String? timeSlot;
  final bool isResident;
  final String? relation;

  CrematoriumBookingData({
    this.selectedDate,
    this.timeSlot,
    this.isResident = false,
    this.relation,
  });
}