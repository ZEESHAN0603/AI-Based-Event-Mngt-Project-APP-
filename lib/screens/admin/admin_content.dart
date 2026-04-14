import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/design_system.dart';
import '../../widgets/synora_header.dart';
import 'package:intl/intl.dart';

class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final contents = adminProvider.contents;

    return Scaffold(
      body: Column(
        children: [
          const SynoraHeader(
            title: 'Content Moderation',
            subtitle: 'Review and approve platform content',
          ),
          Expanded(
            child: contents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.article_outlined, size: 64),
                        const SizedBox(height: 16),
                        const Text('No content found', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: contents.length,
                      itemBuilder: (context, index) {
                        final item = contents[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildContentCard(context, item, adminProvider),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddContentModal(context, adminProvider);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, AdminContent item, AdminProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (item.isApproved ? Colors.teal : Colors.orange).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.isApproved ? Icons.verified_rounded : Icons.pending_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.source_rounded, size: 14),
                const SizedBox(width: 6),
                Text('Source: ${item.source}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today_rounded, size: 14),
                const SizedBox(width: 6),
                Text(DateFormat('MMM dd, yyyy').format(item.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!item.isApproved)
                  _actionButton('Approve', Icons.check_circle_outline, Colors.teal, () => provider.updateContentStatus(item.id, true)),
                _actionButton('Remove', Icons.delete_outline_rounded, Colors.red, () => provider.removeContent(item.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: AnimatedPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContentModal(BuildContext context, AdminProvider provider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final sourceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: GlassCard(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add News / Blog', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildTextField('Title', titleController),
              const SizedBox(height: 16),
              _buildTextField('Description', descController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Source', sourceController),
              const SizedBox(height: 32),
              AnimatedPressable(
                onTap: () {
                  if (titleController.text.isNotEmpty) {
                    provider.addContent(
                      titleController.text,
                      descController.text,
                      sourceController.text,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content added successfully!')));
                  }
                },
                child: GlassCard(
                  opacity: 1.0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: Text('Submit Content', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
