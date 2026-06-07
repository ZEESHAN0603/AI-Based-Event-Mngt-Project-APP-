import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/blog_service.dart';
import '../../widgets/synora_header.dart';

/// Category filter chips shown on the Blogs page.
const _kCategories = [
  {'label': 'All', 'value': ''},
  {'label': '💍 Wedding', 'value': 'wedding'},
  {'label': '🎂 Birthday', 'value': 'birthday'},
  {'label': '💼 Corporate', 'value': 'corporate'},
  {'label': '🎨 Decoration', 'value': 'decoration'},
  {'label': '🍽️ Catering', 'value': 'catering'},
  {'label': '🎉 Events', 'value': 'events'},
];

class IdeasBlogsScreen extends StatefulWidget {
  const IdeasBlogsScreen({super.key});

  @override
  State<IdeasBlogsScreen> createState() => _IdeasBlogsScreenState();
}

class _IdeasBlogsScreenState extends State<IdeasBlogsScreen> {
  List<BlogArticle> _articles = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs({String? category}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cat = category ?? _selectedCategory;
      final articles = await BlogService.getBlogs(
        category: cat.isEmpty ? null : cat,
      );
      if (mounted) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(String value) {
    if (_selectedCategory == value) return;
    setState(() => _selectedCategory = value);
    _fetchBlogs(category: value);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open article link.')),
        );
      }
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          const SynoraHeader(
            title: 'Ideas & Blogs',
            subtitle: 'Get inspired for your next event',
          ),

          // ── Category filter chips ────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _kCategories[index];
                final isSelected = _selectedCategory == cat['value'];
                return FilterChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  onSelected: (_) => _onCategorySelected(cat['value']!),
                  selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.primaryColor
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.primaryColor
                        : Colors.grey.withValues(alpha: 0.4),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchBlogs(),
              child: _buildBody(theme, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading latest articles...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (_articles.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildArticleCard(_articles[index], theme, isDark),
    );
  }

  Widget _buildArticleCard(
      BlogArticle article, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () => _openUrl(article.url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Article Image ─────────────────────────────────────
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  article.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(theme),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _imagePlaceholder(theme);
                  },
                ),
              )
            else
              _imagePlaceholder(theme),

            // ── Article Content ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + Date row
                  Row(
                    children: [
                      if (article.source != null &&
                          article.source!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            article.source!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (article.publishedAt != null)
                        Text(
                          _formatDate(article.publishedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      const Spacer(),
                      Icon(Icons.open_in_new_rounded,
                          size: 16, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),

                  // Description
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(ThemeData theme) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: theme.primaryColor.withValues(alpha: 0.08),
        child: Icon(
          Icons.article_rounded,
          size: 48,
          color: theme.primaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper_outlined,
                size: 72, color: theme.primaryColor.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            const Text(
              'No articles found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different category or pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _fetchBlogs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 72, color: Colors.red.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            const Text(
              'Could not load articles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchBlogs,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
