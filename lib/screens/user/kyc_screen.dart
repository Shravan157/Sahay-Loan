import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/api_service.dart';
import '../../core/widgets/promo_banner.dart';
import '../../models/kyc_model.dart';
import '../../providers/kyc_provider.dart';

import 'dart:io' as io;

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _salaryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();

  bool _isScanning = false;
  String? _aadhaarImagePath;
  String? _panImagePath;
  Uint8List? _aadhaarImageBytes;
  Uint8List? _panImageBytes;
  bool _aadhaarVerified = false;
  bool _panVerified = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAndLoadKYC();
  }

  Future<void> _fetchAndLoadKYC() async {
    final kycProvider = Provider.of<KYCProvider>(context, listen: false);
    await kycProvider.fetchKYCData();
    if (kycProvider.kycData != null) {
      final data = kycProvider.kycData!;
      setState(() {
        _nameController.text = data.name;
        _ageController.text = data.age.toString();
        _occupationController.text = data.occupation;
        _incomeController.text = data.annualIncome.toString();
        _salaryController.text = data.monthlyInhandSalary.toString();
        _phoneController.text = data.phone;
        _emailController.text = data.email;
        _aadhaarController.text = data.aadhaarNumber;
        _panController.text = data.panNumber;
        _aadhaarVerified = data.kycVerified;
        _panVerified = data.kycVerified;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _salaryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _scanDocument(String docType) async {
    setState(() => _isScanning = true);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        await _processDocument(docType, pickedFile.path, pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _uploadDocument(String docType) async {
    setState(() => _isScanning = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? '';
        final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
        if (!supportedExtensions.contains(extension)) {
          throw Exception('Unsupported file type. Please upload JPEG, PNG, or PDF.');
        }
        if (file.bytes == null) throw Exception('Could not read file data');
        await _processDocumentBytes(
          docType: docType,
          fileName: file.name,
          extension: extension,
          bytes: file.bytes!,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _processDocument(
      String docType, String filePath, XFile pickedFile) async {
    Uint8List bytes;
    final String extension = filePath.split('.').last.toLowerCase();
    final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    if (!supportedExtensions.contains(extension)) {
      throw Exception('Unsupported file type. Please upload JPEG, PNG, or PDF.');
    }
    if (kIsWeb) {
      bytes = await pickedFile.readAsBytes();
    } else {
      bytes = await io.File(filePath).readAsBytes();
    }
    await _processDocumentBytes(
      docType: docType,
      fileName: pickedFile.name,
      extension: extension,
      bytes: bytes,
    );
  }

  Future<void> _processDocumentBytes({
    required String docType,
    required String fileName,
    required String extension,
    required Uint8List bytes,
  }) async {
    final base64Image = base64Encode(bytes);
    final response = await ApiService().post('/ocr-scan', body: {
      'image_base64': base64Image,
      'doc_type': docType,
      'file_extension': extension,
    });

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final extracted = data['extracted'] as Map<String, dynamic>;
      setState(() {
        if (docType == 'aadhaar') {
          _aadhaarImageBytes = bytes;
          if (!kIsWeb) _aadhaarImagePath = fileName;
          _aadhaarController.text = extracted['aadhaar_number'] ?? '';
          _nameController.text = extracted['name'] ?? _nameController.text;
          if (extracted['dob'] != null) {
            final dobParts = extracted['dob'].toString().split('/');
            if (dobParts.length == 3) {
              final birthYear = int.parse(dobParts[2]);
              _ageController.text =
                  (DateTime.now().year - birthYear).toString();
            }
          }
          _aadhaarVerified = true;
        } else {
          _panImageBytes = bytes;
          if (!kIsWeb) _panImagePath = fileName;
          _panController.text = extracted['pan_number'] ?? '';
          _nameController.text = extracted['name'] ?? _nameController.text;
          _panVerified = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${docType.toUpperCase()} processed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      throw Exception(response.error ?? 'Failed to process document');
    }
  }

  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) return;
    final kycProvider = Provider.of<KYCProvider>(context, listen: false);
    final kycData = KYCModel(
      uid: '',
      name: _nameController.text,
      age: int.parse(_ageController.text),
      occupation: _occupationController.text,
      annualIncome: double.parse(_incomeController.text),
      monthlyInhandSalary: double.parse(_salaryController.text),
      phone: _phoneController.text,
      email: _emailController.text,
      aadhaarNumber: _aadhaarController.text,
      panNumber: _panController.text,
    );
    kycProvider.setKYCData(kycData);
    final success = await kycProvider.submitKYC();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC submitted successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = Provider.of<KYCProvider>(context);
    final bool isKYCVerified = kycProvider.kycData?.kycVerified ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: kycProvider.isLoading || _isScanning
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(isKYCVerified),
        ],
        body: isKYCVerified
            ? _buildVerifiedKYCView(kycProvider)
            : TabBarView(
          controller: _tabController,
          children: [
            _buildDocumentScanTab(),
            _buildDetailsFormTab(kycProvider),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(bool isKYCVerified) {
    return SliverAppBar(
      expandedHeight: isKYCVerified ? 160 : 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.kycTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
      bottom: isKYCVerified
          ? null
          : TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2.5,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
        tabs: const [
          Tab(text: 'Documents'),
          Tab(text: 'Details'),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: isKYCVerified ? -20 : 40,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: isKYCVerified ? 28 : 56),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isKYCVerified
                            ? 'Identity Verified'
                            : 'Complete Your KYC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isKYCVerified
                            ? 'Your documents are verified and secure'
                            : 'Upload documents to unlock loan features',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── DOCUMENT SCAN TAB ─────────────────────────────────────────────────────

  Widget _buildDocumentScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(Icons.electric_bolt_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI automatically extracts information from your documents',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionLabel('Identity Documents'),
          const SizedBox(height: 12),

          _buildDocumentCard(
            title: 'Aadhaar Card',
            subtitle: 'Required for identity verification',
            icon: Icons.credit_card_rounded,
            isVerified: _aadhaarVerified,
            imagePath: kIsWeb ? null : _aadhaarImagePath,
            imageBytes: kIsWeb ? _aadhaarImageBytes : null,
            onScan: () => _scanDocument('aadhaar'),
            onUpload: () => _uploadDocument('aadhaar'),
          ),

          const SizedBox(height: 14),

          _buildDocumentCard(
            title: 'PAN Card',
            subtitle: 'Required for tax verification',
            icon: Icons.account_balance_rounded,
            isVerified: _panVerified,
            imagePath: kIsWeb ? null : _panImagePath,
            imageBytes: kIsWeb ? _panImageBytes : null,
            onScan: () => _scanDocument('pan'),
            onUpload: () => _uploadDocument('pan'),
          ),

          const SizedBox(height: 24),
          const InsuranceBanner(),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_aadhaarVerified && _panVerified)
                  ? () => _tabController.animateTo(1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue to Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: (_aadhaarVerified && _panVerified)
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: (_aadhaarVerified && _panVerified)
                        ? Colors.white
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isVerified,
    String? imagePath,
    Uint8List? imageBytes,
    required VoidCallback onScan,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? const Color(0xFF22C55E).withOpacity(0.4)
              : const Color(0xFFE2E8F0),
          width: isVerified ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFF22C55E).withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVerified ? Icons.check_circle_rounded : icon,
                  color: isVerified
                      ? const Color(0xFF22C55E)
                      : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ),
            ],
          ),

          if (imageBytes != null) ...[
            const SizedBox(height: 14),
            _buildFilePreview(imageBytes,
                title == 'Aadhaar Card' ? _aadhaarImagePath : _panImagePath),
          ],

          const SizedBox(height: 14),

          // Format hint
          Text(
            'Supported: JPEG · PNG · PDF',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),

          // Action buttons
          if (!kIsWeb) ...[
            Row(
              children: [
                Expanded(
                  child: _buildOutlineButton(
                    icon: isVerified
                        ? Icons.refresh_rounded
                        : Icons.camera_alt_rounded,
                    label: isVerified ? 'Retake' : 'Scan',
                    onTap: onScan,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOutlineButton(
                    icon: Icons.upload_file_rounded,
                    label: 'Upload',
                    onTap: onUpload,
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildOutlineButton(
              icon: Icons.upload_file_rounded,
              label: isVerified ? 'Upload New' : 'Upload Document',
              onTap: onUpload,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
    return btn;
  }

  Widget _buildFilePreview(Uint8List bytes, String? fileName) {
    final isPdf = fileName?.toLowerCase().endsWith('.pdf') ?? _isPdfBytes(bytes);
    if (isPdf) {
      return Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded,
                size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 8),
            Text(
              fileName ?? 'PDF Document',
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes,
            height: 130, width: double.infinity, fit: BoxFit.cover),
      );
    }
  }

  bool _isPdfBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  // ── DETAILS FORM TAB ──────────────────────────────────────────────────────

  Widget _buildDetailsFormTab(KYCProvider kycProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Personal Information'),
            const SizedBox(height: 12),
            _buildFormCard(children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation',
                      icon: Icons.work_outline_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _incomeController,
                label: 'Annual Income (₹)',
                icon: Icons.account_balance_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _salaryController,
                label: 'Monthly In-hand Salary (₹)',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionLabel('Contact Information'),
            const SizedBox(height: 12),
            _buildFormCard(children: [
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionLabel('Document Details'),
            const SizedBox(height: 12),
            _buildFormCard(children: [
              _buildTextField(
                controller: _aadhaarController,
                label: 'Aadhaar Number',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (v!.length != 12) return 'Must be 12 digits';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _panController,
                label: 'PAN Number',
                icon: Icons.account_balance_rounded,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (v!.length != 10) return 'Must be 10 characters';
                  return null;
                },
              ),
            ]),

            if (kycProvider.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        kycProvider.error!,
                        style: const TextStyle(
                            color: Color(0xFFEF4444), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: kycProvider.isLoading ? null : _submitKYC,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: kycProvider.isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
                    : const Text(
                  'Submit KYC',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
        counterText: maxLength != null ? '' : null,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  // ── VERIFIED KYC VIEW ─────────────────────────────────────────────────────

  Widget _buildVerifiedKYCView(KYCProvider kycProvider) {
    final kycData = kycProvider.kycData!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verified status banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF22C55E).withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Color(0xFF22C55E), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KYC Verified',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your identity has been verified successfully',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          _buildSectionLabel('Uploaded Documents'),
          const SizedBox(height: 12),

          _buildDocumentPreviewCard(
            title: 'Aadhaar Card',
            number: _maskAadhaar(kycData.aadhaarNumber),
            icon: Icons.credit_card_rounded,
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _buildDocumentPreviewCard(
            title: 'PAN Card',
            number: kycData.panNumber,
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
          ),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionLabel('Personal Information'),
              GestureDetector(
                onTap: () => _showEditKYCDialog(context, kycProvider),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildInfoCard([
            _buildInfoRow('Full Name', kycData.name, Icons.person_outline_rounded),
            _buildInfoRow('Age', '${kycData.age} years', Icons.cake_outlined),
            _buildInfoRow('Occupation', kycData.occupation, Icons.work_outline_rounded),
            _buildInfoRow('Phone', kycData.phone, Icons.phone_outlined),
            _buildInfoRow('Email', kycData.email, Icons.email_outlined,
                isLast: true),
          ]),

          const SizedBox(height: 24),
          _buildSectionLabel('Financial Information'),
          const SizedBox(height: 12),

          _buildInfoCard([
            _buildInfoRow('Annual Income',
                '₹${_formatCurrency(kycData.annualIncome)}',
                Icons.account_balance_outlined),
            _buildInfoRow('Monthly Salary',
                '₹${_formatCurrency(kycData.monthlyInhandSalary)}',
                Icons.payments_outlined,
                isLast: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentPreviewCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    color: Color(0xFF22C55E), size: 13),
                SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, indent: 46, endIndent: 16, color: Color(0xFFF1F5F9)),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.4,
      ),
    );
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length != 12) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(8)}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  void _showEditKYCDialog(BuildContext context, KYCProvider kycProvider) {
    final kycData = kycProvider.kycData!;
    final editFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: editFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Edit KYC Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Update your personal information',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),

                    // Info notice
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFD97706), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aadhaar and PAN numbers cannot be changed. Contact support for document updates.',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.amber[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildTextField(
                            controller: _occupationController,
                            label: 'Occupation',
                            icon: Icons.work_outline_rounded,
                            validator: (v) =>
                            v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _incomeController,
                      label: 'Annual Income (₹)',
                      icon: Icons.account_balance_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _salaryController,
                      label: 'Monthly Salary (₹)',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),

                    if (kycProvider.error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFFEF4444).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFEF4444)
                                  .withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kycProvider.error!,
                                style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: kycProvider.isLoading
                            ? null
                            : () async {
                          if (!editFormKey.currentState!.validate())
                            return;
                          kycProvider.clearError();
                          final updatedKYC = kycData.copyWith(
                            name: _nameController.text.trim(),
                            age: int.tryParse(_ageController.text) ??
                                kycData.age,
                            occupation:
                            _occupationController.text.trim(),
                            phone: _phoneController.text.trim(),
                            email: _emailController.text.trim(),
                            annualIncome:
                            double.tryParse(_incomeController.text) ??
                                kycData.annualIncome,
                            monthlyInhandSalary: double.tryParse(
                                _salaryController.text) ??
                                kycData.monthlyInhandSalary,
                          );
                          final success =
                          await kycProvider.updateKYC(updatedKYC);
                          if (success && dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              const SnackBar(
                                content:
                                Text('KYC updated successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: kycProvider.isLoading
                            ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                            : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}