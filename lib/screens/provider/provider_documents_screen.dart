import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/provider_document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState extends State<ProviderDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user?.uid != null) {
      await context
          .read<DocumentProvider>()
          .loadProviderDocuments(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Business Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.providerDocuments == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = provider.providerDocuments;
          final completionPercentage = docs?.completionPercentage ?? 0;

          return RefreshIndicator(
            onRefresh: _loadDocuments,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(completionPercentage, docs),
                  const SizedBox(height: 24),
                  _buildStatusBanner(docs),
                  const SizedBox(height: 24),
                  _buildDocumentCategories(docs),
                  const SizedBox(height: 24),
                  if (docs?.isComplete == true && (docs?.verificationStatus == 'not_submitted' || docs?.verificationStatus == 'rejected'))
                    _buildSubmitButton(docs),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(double percentage, ProviderDocumentModel? docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: -90 * 3.14159 / 180,
                    endAngle: 270 * 3.14159 / 180,
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      Colors.grey[300]!,
                      Colors.grey[300]!,
                    ],
                    stops: [
                      0,
                      percentage / 100,
                      percentage / 100,
                      1,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${percentage.toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document Completion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      percentage == 100
                          ? 'All required documents uploaded'
                          : '${docs?.missingDocuments.length ?? 0} documents remaining',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (docs?.missingDocuments.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Missing Documents:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...docs!.missingDocuments.map((doc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ProviderDocumentModel? docs) {
    final status = docs?.verificationStatus ?? 'not_submitted';
    final isVerified = status == 'verified';
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    Color bgColor;
    Color iconColor;
    IconData icon;
    String title;
    String subtitle;

    if (isVerified) {
      bgColor = AppColors.success.withOpacity(0.1);
      iconColor = AppColors.success;
      icon = Icons.verified;
      title = 'Documents Verified';
      subtitle = 'Your business documents have been verified successfully';
    } else if (isPending) {
      bgColor = Colors.orange.withOpacity(0.1);
      iconColor = Colors.orange;
      icon = Icons.pending;
      title = 'Verification in Progress';
      subtitle = 'Your documents are being reviewed by our team';
    } else if (isRejected) {
      bgColor = AppColors.error.withOpacity(0.1);
      iconColor = AppColors.error;
      icon = Icons.cancel;
      title = 'Documents Rejected';
      subtitle = docs?.rejectionReason ?? 'Please re-upload the required documents';
    } else {
      bgColor = Colors.blue.withOpacity(0.1);
      iconColor = Colors.blue;
      icon = Icons.info;
      title = 'Complete Your Profile';
      subtitle = 'Upload all required documents to get verified';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCategories(ProviderDocumentModel? docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Document Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...providerDocumentCategories.map((category) {
          return _buildDocumentCategoryCard(category, docs);
        }).toList(),
      ],
    );
  }

  Widget _buildDocumentCategoryCard(
    DocumentCategory category,
    ProviderDocumentModel? docs,
  ) {
    final uploadedCount = category.documents.where((doc) {
      final uploadedDoc = _getDocumentByType(doc.key, docs);
      return uploadedDoc?.isUploaded == true;
    }).length;
    final totalCount = category.documents.length;
    final isComplete = uploadedCount == totalCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.success.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isComplete ? Icons.check_circle : Icons.folder,
            color: isComplete ? AppColors.success : AppColors.primary,
          ),
        ),
        title: Text(
          category.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$uploadedCount of $totalCount uploaded',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isComplete
                ? AppColors.success.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isComplete ? 'Complete' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isComplete ? AppColors.success : Colors.orange,
            ),
          ),
        ),
        children: category.documents.map((doc) {
          return _buildDocumentUploadTile(doc, docs);
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentUploadTile(
    DocumentRequirement doc,
    ProviderDocumentModel? docs,
  ) {
    final uploadedDoc = _getDocumentByType(doc.key, docs);
    final isUploaded = uploadedDoc?.isUploaded == true;
    final status = uploadedDoc?.status ?? 'not_uploaded';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'verified':
        statusColor = AppColors.success;
        statusIcon = Icons.verified;
        statusText = 'Verified';
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.upload_file;
        statusText = 'Upload';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.success.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isUploaded ? Icons.description : Icons.upload_file,
          color: isUploaded ? AppColors.success : Colors.grey,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              doc.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          if (doc.isRequired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'REQ',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doc.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (isUploaded && uploadedDoc?.fileName != null)
            Text(
              uploadedDoc!.fileName!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUploaded) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteDocument(doc.key),
            ),
          ] else
            ElevatedButton(
              onPressed: () => _uploadDocument(doc),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text('Upload'),
            ),
        ],
      ),
    );
  }

  BusinessDocument? _getDocumentByType(
    String type,
    ProviderDocumentModel? docs,
  ) {
    if (docs == null) return null;

    switch (type) {
      case 'certificate_of_incorporation':
        return docs.certificateOfIncorporation;
      case 'memorandum_of_association':
        return docs.memorandumOfAssociation;
      case 'articles_of_association':
        return docs.articlesOfAssociation;
      case 'partnership_deed':
        return docs.partnershipDeed;
      case 'llp_agreement':
        return docs.llpAgreement;
      case 'gst_certificate':
        return docs.gstCertificate;
      case 'pan_card':
        return docs.panCard;
      case 'tan_certificate':
        return docs.tanCertificate;
      case 'shop_act_license':
        return docs.shopActLicense;
      case 'bank_statement':
        return docs.bankStatement;
      case 'audited_financials':
        return docs.auditedFinancials;
      case 'itr_filing':
        return docs.itrFiling;
      case 'nbfc_license':
        return docs.nbfcLicense;
      case 'rbi_registration':
        return docs.rbiRegistration;
      case 'sebi_registration':
        return docs.sebiRegistration;
      case 'office_address_proof':
        return docs.officeAddressProof;
      case 'board_resolution':
        return docs.boardResolution;
      case 'authorized_signatory_proof':
        return docs.authorizedSignatoryProof;
      default:
        return null;
    }
  }

  Widget _buildSubmitButton(ProviderDocumentModel? docs) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _submitForVerification(docs),
        icon: const Icon(Icons.send),
        label: const Text('Submit for Verification'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Future<void> _uploadDocument(DocumentRequirement doc) async {
    // Show upload options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload ${doc.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              doc.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildUploadOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickAndUpload(doc, 'camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickAndUpload(doc, 'gallery'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadOption(
                    icon: Icons.folder,
                    label: 'Files',
                    onTap: () => _pickAndUpload(doc, 'files'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Supported formats: ${doc.acceptedFormats.join(", ")}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            Text(
              'Max size: ${doc.maxSizeMB}MB',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(DocumentRequirement doc, String source) async {
    Navigator.pop(context);
    
    File? file;
    final picker = ImagePicker();

    try {
      if (source == 'camera') {
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      } else if (source == 'gallery') {
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
        );
        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
      } else if (source == 'files') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: doc.acceptedFormats,
        );
        if (result != null && result.files.single.path != null) {
          file = File(result.files.single.path!);
        }
      }

      if (file != null) {
        if (!mounted) return;
        
        // Show loading snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading ${doc.name}...'),
            duration: const Duration(seconds: 2),
          ),
        );

        final authProvider = context.read<AuthProvider>();
        final docProvider = context.read<DocumentProvider>();
        
        final success = await docProvider.uploadDocument(
          companyId: authProvider.user!.uid,
          documentType: doc.key,
          documentName: doc.name,
          file: file,
        );

        if (success && mounted) {
          Helpers.showSnackBar(
            context,
            message: '${doc.name} uploaded successfully',
            isSuccess: true,
          );
        } else if (mounted) {
          Helpers.showSnackBar(
            context,
            message: docProvider.error ?? 'Upload failed',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          message: 'Error: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteDocument(String documentType) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      final docProvider = context.read<DocumentProvider>();
      final success = await docProvider.deleteDocument(
        companyId: authProvider.user!.uid,
        documentType: documentType,
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          message: 'Document deleted successfully',
          isSuccess: true,
        );
      }
    }
  }

  Future<void> _submitForVerification(ProviderDocumentModel? docs) async {
    if (docs?.isComplete != true) {
      Helpers.showSnackBar(
        context,
        message: 'Please upload at least one document first',
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit for Verification'),
        content: const Text(
          'Once submitted, your documents will be reviewed by our team. This process may take 2-3 business days. Do you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = context.read<AuthProvider>();
      final docProvider = context.read<DocumentProvider>();
      final success = await docProvider.submitForVerification(
        authProvider.user!.uid,
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          message: 'Documents submitted for verification',
          isSuccess: true,
        );
      }
    }
  }
}
