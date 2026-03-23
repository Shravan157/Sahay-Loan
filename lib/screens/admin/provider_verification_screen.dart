import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/sahay_logo.dart';
import '../../models/provider_document_model.dart';
import '../../providers/document_provider.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProviderDocumentModel? _selectedProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPendingVerifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingVerifications() async {
    await context.read<DocumentProvider>().getPendingVerifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Verification'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Verified'),
            Tab(text: 'Rejected'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingVerifications,
          ),
        ],
      ),
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProviderList('pending'),
              _buildProviderList('verified'),
              _buildProviderList('rejected'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProviderList(String status) {
    return Consumer<DocumentProvider>(
      builder: (context, provider, child) {
        final filteredList = provider.pendingVerifications
            .where((p) => p.verificationStatus == status)
            .toList();
            
        if (filteredList.isEmpty) {
          return Center(
            child: Text('No $status providers'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return _buildProviderCard(filteredList[index]);
          },
        );
      },
    );
  }

  Widget _buildProviderCard(ProviderDocumentModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [Helpers.getCardShadow()],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.business, color: AppColors.primary),
        ),
        title: Text(
          provider.companyId, // We should show company name here, but id is unique
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${provider.verificationStatus.toUpperCase()}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip('DOCS', provider.verificationStatus),
                const SizedBox(width: 8),
                Text('Completion: ${provider.completionPercentage.toInt()}%'),
              ],
            ),
          ],
        ),
        children: [
          _buildDocumentVerificationSection(provider),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    Color color;
    IconData icon;
    switch (status) {
      case 'verified':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentVerificationSection(ProviderDocumentModel provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Verification',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...providerDocumentCategories.map((category) {
            return _buildDocumentCategoryVerification(category, provider);
          }).toList(),
          const SizedBox(height: 24),
          _buildActionButtons(provider),
        ],
      ),
    );
  }

  Widget _buildDocumentCategoryVerification(DocumentCategory category, ProviderDocumentModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...category.documents.map((doc) {
            return _buildDocumentVerificationTile(doc, provider);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentVerificationTile(DocumentRequirement doc, ProviderDocumentModel provider) {
    final uploadedDoc = _getDocumentByType(doc.key, provider);
    final isUploaded = uploadedDoc?.isUploaded ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  isUploaded ? 'File: ${uploadedDoc?.fileName}' : 'Not uploaded',
                  style: TextStyle(fontSize: 12, color: isUploaded ? AppColors.primary : Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (isUploaded)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppColors.primary),
                  onPressed: () => _viewDocument(doc, provider),
                  tooltip: 'View Document',
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: AppColors.success),
                  onPressed: () => _verifyDocument(doc, provider, true),
                  tooltip: 'Approve',
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.error),
                  onPressed: () => _rejectDocument(doc, provider),
                  tooltip: 'Reject',
                ),
              ],
            ),
        ],
      ),
    );
  }

  BusinessDocument? _getDocumentByType(String type, ProviderDocumentModel provider) {
    switch (type) {
      case 'certificate_of_incorporation': return provider.certificateOfIncorporation;
      case 'memorandum_of_association': return provider.memorandumOfAssociation;
      case 'articles_of_association': return provider.articlesOfAssociation;
      case 'partnership_deed': return provider.partnershipDeed;
      case 'llp_agreement': return provider.llpAgreement;
      case 'gst_certificate': return provider.gstCertificate;
      case 'pan_card': return provider.panCard;
      case 'tan_certificate': return provider.tanCertificate;
      case 'shop_act_license': return provider.shopActLicense;
      case 'bank_statement': return provider.bankStatement;
      case 'audited_financials': return provider.auditedFinancials;
      case 'itr_filing': return provider.itrFiling;
      case 'nbfc_license': return provider.nbfcLicense;
      case 'rbi_registration': return provider.rbiRegistration;
      case 'sebi_registration': return provider.sebiRegistration;
      case 'office_address_proof': return provider.officeAddressProof;
      case 'board_resolution': return provider.boardResolution;
      case 'authorized_signatory_proof': return provider.authorizedSignatoryProof;
      default: return null;
    }
  }

  Widget _buildActionButtons(ProviderDocumentModel provider) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateFinalStatus(provider, 'verified'),
            icon: const Icon(Icons.check_circle),
            label: const Text('Approve Company'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateFinalStatus(provider, 'rejected'),
            icon: const Icon(Icons.cancel),
            label: const Text('Reject All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateFinalStatus(ProviderDocumentModel provider, String status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status == 'verified' ? 'Approve' : 'Reject'} Provider'),
        content: Text('Are you sure you want to $status this lending partner?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'verified' ? AppColors.success : AppColors.error,
            ),
            child: Text(status == 'verified' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<DocumentProvider>().verifyCompany(
            companyId: provider.companyId,
            status: status,
          );
      if (success && mounted) {
        Helpers.showSnackBar(context, message: 'Provider status updated to $status', isSuccess: true);
      }
    }
  }

  void _viewDocument(DocumentRequirement doc, ProviderDocumentModel provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    doc.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.document_scanner, size: 100, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _verifyDocument(doc, provider, true);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _rejectDocument(doc, provider);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyDocument(DocumentRequirement doc, ProviderDocumentModel provider, bool approved) async {
    final docProvider = context.read<DocumentProvider>();
    final success = await docProvider.verifyDocument(
      companyId: provider.companyId,
      documentType: doc.key,
      isApproved: approved,
    );

    if (success && mounted) {
      Helpers.showSnackBar(
        context,
        message: '${doc.name} ${approved ? 'approved' : 'rejected'} successfully',
        isSuccess: true,
      );
    }
  }

  Future<void> _rejectDocument(DocumentRequirement doc, ProviderDocumentModel provider) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please provide a reason for rejecting ${doc.name}:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final docProvider = context.read<DocumentProvider>();
      final success = await docProvider.verifyDocument(
        companyId: provider.companyId,
        documentType: doc.key,
        isApproved: false,
        rejectionReason: reasonController.text,
      );

      if (success && mounted) {
        Helpers.showSnackBar(
          context,
          message: '${doc.name} rejected',
          isSuccess: true,
        );
      }
    }
  }

  // End of _ProviderVerificationScreenState
}
