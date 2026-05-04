import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/repair_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_widgets.dart';
import '../../widgets/job_card.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context),
      body: GradientBlobBackground(
        child: Consumer<RepairProvider>(
          builder: (context, repairProvider, _) {
            final filteredJobs = _getFilteredJobs(repairProvider);

            return RefreshIndicator(
              onRefresh: () async {
                // Refresh by triggering a rebuild
                setState(() {});
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Space for AppBar
                    SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          10,
                    ),

                    // Stats Row
                    _buildStatsRow(context, repairProvider),

                    const SizedBox(height: 12),

                    // Search Bar
                    _buildSearchBar(context),

                    const SizedBox(height: 12),

                    // Filter Chips
                    _buildFilterChips(context),

                    const SizedBox(height: 12),

                    // Jobs List or Empty State
                    if (filteredJobs.isEmpty)
                      _buildEmptyState(context)
                    else
                      _buildJobsList(context, filteredJobs),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/new-job');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.4),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JTC Repair Lab',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            AppDateUtils.formatDateFull(DateTime.now()),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag),
          onPressed: () {
            Navigator.of(context).pushNamed('/borrow-list');
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, RepairProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          StatCard(
            label: 'Pending',
            value: provider.pendingCount.toString(),
            color: Color(AppConstants.warningColor),
            icon: Icons.pending_actions,
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Done Today',
            value: provider.doneTodayCount.toString(),
            color: Color(AppConstants.successColor),
            icon: Icons.check_circle,
          ),
          const SizedBox(width: 12),
          StatCard(
            label: 'Total Jobs',
            value: provider.totalCount.toString(),
            color: Color(AppConstants.primaryColor),
            icon: Icons.work,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name, phone, or model...',
            prefixIcon: Icon(
              Icons.search,
              color: Color(AppConstants.primaryColor),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['all', 'pending', 'done', 'issue_found'];
    final filterLabels = {
      'all': 'All',
      'pending': 'Pending',
      'done': 'Done',
      'issue_found': 'Issue Found',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GlassChip(
              label: filterLabels[filter]!,
              isSelected: isSelected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_rounded,
                size: 64,
                color: Color(AppConstants.primaryColor).withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No repair jobs yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Color(AppConstants.textSecondary),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to add your first job',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, List jobs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(job: jobs[index]),
        );
      },
    );
  }

  List _getFilteredJobs(RepairProvider provider) {
    List jobs = provider.filterByStatus(
      _selectedFilter == 'all' ? null : _selectedFilter,
    );

    if (_searchQuery.isNotEmpty) {
      jobs = provider.searchJobs(_searchQuery);
    }

    return jobs;
  }
}
