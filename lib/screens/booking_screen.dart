import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_bit/models/service_model.dart';
import 'package:handy_bit/services/firestore_services.dart';
import 'package:handy_bit/services/locator.dart';
import 'package:handy_bit/providers/auth_provider.dart';

class BookingScreen extends StatefulWidget {
  final ServiceProvider provider;

  const BookingScreen({Key? key, required this.provider}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = locator<FirestoreService>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedAddress = 'Home - 123 Main St, New York';
  bool _isUrgent = false;
  String _specialInstructions = '';
  int _estimatedHours = 1;
  bool _isLoading = false;

  final List<String> _addresses = [
    'Home - 123 Main St, New York',
    'Office - 456 Business Ave, Manhattan',
    'Apartment - 789 Park Blvd, Brooklyn'
  ];

  /// Calculate total price dynamically (Requirement #7)
  double get _totalPrice {
    double basePrice = widget.provider.price * _estimatedHours;
    double urgentFee = _isUrgent ? (basePrice * 0.5) : 0.0; // 50% extra for urgent
    return basePrice + urgentFee;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Confirm booking and save to Firestore (Requirement #7)
  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select date and time for your booking');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      _showErrorDialog('Please log in to book a service');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the first service from the provider's services list
      final selectedService = widget.provider.services.isNotEmpty
          ? widget.provider.services.first
          : widget.provider.profession;

      // Save booking to Firestore (Requirement #5)
      final bookingId = await _firestoreService.createBooking(
        userId: currentUser.uid,
        providerId: widget.provider.id,
        providerName: widget.provider.name,
        service: selectedService,
        date: _selectedDate,
        time: _selectedTime.format(context),
        address: _selectedAddress,
        urgent: _isUrgent,
        specialInstructions: _specialInstructions,
        totalPrice: _totalPrice,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showBookingConfirmation(bookingId);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorDialog('Error creating booking: $e');
      }
    }
  }

  void _showBookingConfirmation(String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your service has been booked successfully.'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Booking ID: ${bookingId.substring(0, 8)}...'),
                  Text('Provider: ${widget.provider.name}'),
                  Text('Service: ${widget.provider.profession}'),
                  Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  Text('Time: ${_selectedTime.format(context)}'),
                  Text('Total: \$${_totalPrice.toStringAsFixed(2)}'),
                  if (_isUrgent)
                    Text(
                      'Type: Urgent Service',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // goes back one screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
            ),
            child: Text('Back'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Book Service'),
          backgroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double basePrice = widget.provider.price * _estimatedHours;
    double urgentFee = _isUrgent ? basePrice * 0.5 : 0;
    double total = _totalPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Book Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProviderInfo(),
              SizedBox(height: 24),
              _buildServiceDetails(),
              SizedBox(height: 24),
              _buildEstimatedHours(),
              SizedBox(height: 24),
              _buildDateTimeSection(),
              SizedBox(height: 24),
              _buildAddressSection(),
              SizedBox(height: 24),
              _buildSpecialInstructions(),
              SizedBox(height: 24),
              _buildUrgentServiceOption(),
              SizedBox(height: 32),
              _buildPriceBreakdown(basePrice, urgentFee, total),
              SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(total),
    );
  }

  Widget _buildEstimatedHours() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _estimatedHours > 1
                    ? () => setState(() => _estimatedHours--)
                    : null,
                icon: Icon(Icons.remove_circle_outline),
                color: Color(0xFF2563EB),
              ),
              Text(
                '$_estimatedHours hours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: () => setState(() => _estimatedHours++),
                icon: Icon(Icons.add_circle_outline),
                color: Color(0xFF2563EB),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: Color(0xFF2563EB),
              size: 32,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.provider.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.provider.profession,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    _buildRatingStars(widget.provider.rating),
                    SizedBox(width: 6),
                    Text(
                      '${widget.provider.rating} (${widget.provider.reviewCount} reviews)',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.provider.services.map((service) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  service,
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date & Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTimeSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Color(0xFF64748B)),
                SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Color(0xFF64748B)),
                SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAddress,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAddress = newValue!;
                  });
                },
                items: _addresses.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                isExpanded: true,
                icon: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              _showAddAddressDialog();
            },
            icon: Icon(Icons.add, color: Color(0xFF2563EB), size: 20),
            label: Text(
              'Add New Address',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Instructions (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: TextEditingController(text: _specialInstructions),
              onChanged: (value) {
                setState(() {
                  _specialInstructions = value;
                });
              },
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special requirements or instructions...',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontFamily: 'Inter',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentServiceOption() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(0xFFDC2626).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emergency, color: Color(0xFFDC2626), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Urgent Service',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '50% extra for immediate response (within 30 mins)',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isUrgent,
            onChanged: (value) {
              setState(() {
                _isUrgent = value;
              });
            },
            activeColor: Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(double basePrice, double urgentFee, double total) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 16),
          _buildPriceRow('Base Service Fee ($_estimatedHours hrs)', '\$${basePrice.toStringAsFixed(2)}'),
          if (_isUrgent) _buildPriceRow('Urgent Service Fee (50%)', '\$${urgentFee.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          Divider(color: Color(0xFFE2E8F0)),
          SizedBox(height: 8),
          _buildPriceRow('Total Amount', '\$${total.toStringAsFixed(2)}', isTotal: true),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payment will be processed after service completion',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2563EB),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Color(0xFF1E293B) : Color(0xFF64748B),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'Inter',
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Color(0xFF059669) : Color(0xFF1E293B),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Inter',
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 56,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Color(0xFFF59E0B),
          size: 16,
        );
      }),
    );
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Address Name (e.g., Home, Office)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address added successfully'),
                  backgroundColor: Color(0xFF059669),
                ),
              );
            },
            child: Text('Save Address'),
          ),
        ],
      ),
    );
  }
}