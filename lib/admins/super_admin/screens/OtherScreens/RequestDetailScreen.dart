import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Requestdetailscreen extends StatefulWidget {
  final Map<String, dynamic> requester;

  const Requestdetailscreen({
    super.key,
    required this.requester,
  });

  @override
  State<Requestdetailscreen> createState() => _RequestdetailscreenState();
}

class _RequestdetailscreenState extends State<Requestdetailscreen> {
  late final TextEditingController _commissionRateController;
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commissionRateController = TextEditingController(
      text: widget.requester['commission_rate']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _commissionRateController.dispose();
    super.dispose();
  }

  // -------------------- HELPERS --------------------

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return "${parsed.day}/${parsed.month}/${parsed.year}";
  }

  // -------------------- SUPABASE UPDATE --------------------

  Future<void> _updateStatus(String status) async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _supabase
          .from('sellers')
          .update({
        'status': status, // must be lowercase
        'commission_rate':
        double.tryParse(_commissionRateController.text) ?? 0.0,
      })
          .eq('id', widget.requester['id']);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -------------------- CONFIRMATION --------------------

  Future<void> _confirmAndUpdate(String status) async {
    if (status == 'suspended') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirm Action'),
          content:
          const Text('Are you sure you want to decline/suspend this seller?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    _updateStatus(status);
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        title: const Text(
          'Request Details',
          style: TextStyle(fontFamily: 'poppins', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(
              'Business Information',
              [
                _row('Store Name', widget.requester['company_name']),
                _row('GST Number', widget.requester['gst_no']),
                _row('Address', widget.requester['address']),
                _row('Pincode', widget.requester['pincode']),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              'Owner Information',
              [
                _row('Name', widget.requester['seller_name']),
                _row('Email', widget.requester['seller_email']),
                _row('Phone', widget.requester['mobile_no']),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              'Banking Details',
              [
                _row('Account No', widget.requester['account_no']),
                _row('IFSC Code', widget.requester['ifsc_code']),
              ],
            ),
            const SizedBox(height: 16),
            _section(
              'Documents & Metadata',
              [
                _row(
                  'Document Type',
                  widget.requester['document_type'],
                ),
                _row(
                  'Created At',
                  _formatDate(widget.requester['created_at']),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _adminActions(),
          ],
        ),
      ),
    );
  }

  // -------------------- WIDGETS --------------------

  Widget _adminActions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administration Action',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commissionRateController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*'),
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Commission Rate (%)',
                border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.percent),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmAndUpdate('suspended'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmAndUpdate('approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF915F41),
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
