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

// Import dart:io only for non-web platforms
import 'dart:io' as io;

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key});

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> with SingleTickerProviderStateMixin {
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
    
    // Fetch latest KYC data from backend
    await kycProvider.fetchKYCData();
    
    // Load data into controllers
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
      // Use gallery for web since camera might not be available
      final pickedFile = await picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _processDocument(docType, pickedFile.path, pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _uploadDocument(String docType) async {
    setState(() => _isScanning = true);
    
    try {
      // Use file_picker which supports both images and PDFs
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true, // This ensures we get the bytes on all platforms
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file extension
        final extension = file.extension?.toLowerCase() ?? '';
        final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
        if (!supportedExtensions.contains(extension)) {
          throw Exception('Unsupported file type. Please upload JPEG, PNG, or PDF.');
        }
        
        // Use the bytes directly (works on all platforms)
        if (file.bytes == null) {
          throw Exception('Could not read file data');
        }
        
        await _processDocumentBytes(
          docType: docType,
          fileName: file.name,
          extension: extension,
          bytes: file.bytes!,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _processDocument(String docType, String filePath, XFile pickedFile) async {
    Uint8List bytes;
    final String extension = filePath.split('.').last.toLowerCase();
    
    // Check if file type is supported
    final supportedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    if (!supportedExtensions.contains(extension)) {
      throw Exception('Unsupported file type. Please upload JPEG, PNG, or PDF.');
    }
    
    if (kIsWeb) {
      // On web, read as bytes directly
      bytes = await pickedFile.readAsBytes();
    } else {
      // On mobile, use File
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
          // Store bytes for display (works on both web and mobile)
          _aadhaarImageBytes = bytes;
          if (!kIsWeb) {
            _aadhaarImagePath = fileName;
          }
          _aadhaarController.text = extracted['aadhaar_number'] ?? '';
          _nameController.text = extracted['name'] ?? _nameController.text;
          if (extracted['dob'] != null) {
            final dobParts = extracted['dob'].toString().split('/');
            if (dobParts.length == 3) {
              final birthYear = int.parse(dobParts[2]);
              _ageController.text = (DateTime.now().year - birthYear).toString();
            }
          }
          _aadhaarVerified = true;
        } else {
          // Store bytes for display (works on both web and mobile)
          _panImageBytes = bytes;
          if (!kIsWeb) {
            _panImagePath = fileName;
          }
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
    
    // Create KYCModel and set it in provider
    final kycData = KYCModel(
      uid: '', // Will be set by backend
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.kycTitle),
        bottom: isKYCVerified
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Documents', icon: Icon(Icons.document_scanner)),
                  Tab(text: 'Details', icon: Icon(Icons.person)),
                ],
              ),
      ),
      body: kycProvider.isLoading || _isScanning
          ? const Center(child: CircularProgressIndicator())
          : isKYCVerified
              ? _buildVerifiedKYCView(kycProvider)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDocumentScanTab(),
                    _buildDetailsFormTab(kycProvider),
                  ],
                ),
    );
  }

  Widget _buildDocumentScanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Your Documents',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We use AI to automatically extract information from your documents',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Aadhaar Card Scan
          _buildDocumentCard(
            title: 'Aadhaar Card',
            subtitle: 'Required for identity verification',
            icon: Icons.credit_card,
            isVerified: _aadhaarVerified,
            imagePath: kIsWeb ? null : _aadhaarImagePath,
            imageBytes: kIsWeb ? _aadhaarImageBytes : null,
            onScan: () => _scanDocument('aadhaar'),
            onUpload: () => _uploadDocument('aadhaar'),
          ),
          
          const SizedBox(height: 16),
          
          // PAN Card Scan
          _buildDocumentCard(
            title: 'PAN Card',
            subtitle: 'Required for tax purposes',
            icon: Icons.account_balance_wallet,
            isVerified: _panVerified,
            imagePath: kIsWeb ? null : _panImagePath,
            imageBytes: kIsWeb ? _panImageBytes : null,
            onScan: () => _scanDocument('pan'),
            onUpload: () => _uploadDocument('pan'),
          ),
          
          const SizedBox(height: 24),
          
          // Insurance Promo Banner
          const InsuranceBanner(),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_aadhaarVerified && _panVerified)
                  ? () => _tabController.animateTo(1)
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Details'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isVerified
            ? const BorderSide(color: AppColors.success, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isVerified ? Icons.check_circle : icon,
                    color: isVerified ? AppColors.success : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVerified)
                  const Icon(
                    Icons.verified,
                    color: AppColors.success,
                  ),
              ],
            ),
            // Show file preview (using bytes - works on both platforms)
            if (imageBytes != null) ...[
              const SizedBox(height: 16),
              _buildFilePreview(imageBytes, title == 'Aadhaar Card' ? _aadhaarImagePath : _panImagePath),
            ],
            const SizedBox(height: 8),
            // Supported formats text
            Text(
              'Supported: JPEG, PNG, PDF',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            if (!kIsWeb) ...[
              // Mobile: Show Scan and Upload buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onScan,
                      icon: Icon(isVerified ? Icons.refresh : Icons.camera_alt),
                      label: Text(isVerified ? 'Retake' : 'Scan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUpload,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Web: Show only Upload button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.upload_file),
                  label: Text(isVerified ? 'Upload New' : 'Upload Document'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Uint8List bytes, String? fileName) {
    // Check if it's a PDF by looking at file name or bytes
    final isPdf = fileName?.toLowerCase().endsWith('.pdf') ?? 
                  _isPdfBytes(bytes);
    
    if (isPdf) {
      // Show PDF icon for PDF files
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Colors.red.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              fileName ?? 'PDF Document',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    } else {
      // Show image for image files
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  bool _isPdfBytes(Uint8List bytes) {
    // PDF files start with %PDF
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && bytes[1] == 0x50 && 
           bytes[2] == 0x44 && bytes[3] == 0x46;
  }

  Widget _buildDetailsFormTab(KYCProvider kycProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _occupationController,
                    label: 'Occupation',
                    icon: Icons.work,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _incomeController,
              label: 'Annual Income (₹)',
              icon: Icons.account_balance,
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _salaryController,
              label: 'Monthly In-hand Salary (₹)',
              icon: Icons.money,
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Document Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _aadhaarController,
              label: 'Aadhaar Number',
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
              maxLength: 12,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (v!.length != 12) return 'Must be 12 digits';
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _panController,
              label: 'PAN Number',
              icon: Icons.account_balance_wallet,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (v!.length != 10) return 'Must be 10 characters';
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            if (kycProvider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kycProvider.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: kycProvider.isLoading ? null : _submitKYC,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.success,
                ),
                child: kycProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit KYC',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        counterText: maxLength != null ? '' : null,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
    );
  }

  // Build view for when KYC is already verified - Professional Fintech Style
  Widget _buildVerifiedKYCView(KYCProvider kycProvider) {
    final kycData = kycProvider.kycData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'KYC Verified',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your identity has been verified successfully',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Verified on 27 Feb 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Document Cards Section
          const Text(
            'Uploaded Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Aadhaar Card
          _buildDocumentPreviewCard(
            title: 'Aadhaar Card',
            number: _maskAadhaar(kycData.aadhaarNumber),
            icon: Icons.credit_card,
            color: Colors.orange,
            verified: true,
          ),
          const SizedBox(height: 12),
          
          // PAN Card
          _buildDocumentPreviewCard(
            title: 'PAN Card',
            number: kycData.panNumber,
            icon: Icons.account_balance_wallet,
            color: Colors.blue,
            verified: true,
          ),
          const SizedBox(height: 24),
          
          // Personal Information Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showEditKYCDialog(context, kycProvider),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Personal Details Card
          _buildInfoCard([
            _buildInfoRow('Full Name', kycData.name, Icons.person),
            _buildDivider(),
            _buildInfoRow('Age', '${kycData.age} years', Icons.cake),
            _buildDivider(),
            _buildInfoRow('Occupation', kycData.occupation, Icons.work),
            _buildDivider(),
            _buildInfoRow('Phone', kycData.phone, Icons.phone),
            _buildDivider(),
            _buildInfoRow('Email', kycData.email, Icons.email),
          ]),
          const SizedBox(height: 24),
          
          // Financial Information Section
          const Text(
            'Financial Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoCard([
            _buildInfoRow('Annual Income', '₹${_formatCurrency(kycData.annualIncome)}', Icons.account_balance_wallet),
            _buildDivider(),
            _buildInfoRow('Monthly Salary', '₹${_formatCurrency(kycData.monthlyInhandSalary)}', Icons.money),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Document Preview Card
  Widget _buildDocumentPreviewCard({
    required String title,
    required String number,
    required IconData icon,
    required Color color,
    required bool verified,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Info Card Container
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Info Row
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Divider
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 48,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }

  // Mask Aadhaar Number
  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length != 12) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(8)}';
  }

  // Format Currency
  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // Show Edit KYC Dialog
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
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
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text(
                      'Edit KYC Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Update your personal information',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Note: Document numbers cannot be changed
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Aadhaar and PAN numbers cannot be changed. Contact support for document updates.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Editable fields only
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake,
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _occupationController,
                            label: 'Occupation',
                            icon: Icons.work,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _incomeController,
                      label: 'Annual Income (₹)',
                      icon: Icons.account_balance_wallet,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _salaryController,
                      label: 'Monthly Salary (₹)',
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Error message if any
                    if (kycProvider.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kycProvider.error!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: kycProvider.isLoading
                            ? null
                            : () async {
                                // Validate form
                                if (!editFormKey.currentState!.validate()) {
                                  return;
                                }
                                
                                // Clear any previous error
                                kycProvider.clearError();
                                
                                final updatedKYC = kycData.copyWith(
                                  name: _nameController.text.trim(),
                                  age: int.tryParse(_ageController.text) ?? kycData.age,
                                  occupation: _occupationController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  email: _emailController.text.trim(),
                                  annualIncome: double.tryParse(_incomeController.text) ?? kycData.annualIncome,
                                  monthlyInhandSalary: double.tryParse(_salaryController.text) ?? kycData.monthlyInhandSalary,
                                );
                                
                                final success = await kycProvider.updateKYC(updatedKYC);
                                if (success && dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(
                                      content: Text('KYC updated successfully!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: kycProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
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