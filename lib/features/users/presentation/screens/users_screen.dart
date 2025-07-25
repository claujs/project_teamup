import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/users_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../users_notifier.dart';
import '../../../../core/utils/responsive_utils.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Carregar dados iniciais de forma segura
    Future.microtask(() {
      if (mounted) {
        ref.read(usersNotifierProvider.notifier).loadUsers();
      }
    });

    // Adicionar listener para scroll de forma otimizada
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!mounted || _isLoadingMore) return;

    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      ref.read(usersNotifierProvider.notifier).loadMore().then((_) {
        if (mounted) {
          _isLoadingMore = false;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshUsers();
    }
  }

  Future<void> _refreshUsers() async {
    if (!mounted) return;
    await ref.read(usersNotifierProvider.notifier).loadUsers(refresh: true);
  }

  void _onSearchChanged(String query) {
    if (!mounted) return;
    ref.read(usersNotifierProvider.notifier).searchUsers(query);
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersNotifierProvider);
    final isTablet = context.isTabletOrLarger;

    return Scaffold(
      body: Column(
        children: [
          ResponsiveContainer(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 0 : 16,
                vertical: 16,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchUsers,
                  prefixIcon: Icon(Icons.search, size: isTablet ? 24 : 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, size: isTablet ? 24 : 20),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                    horizontal: 16,
                  ),
                ),
                style: TextStyle(fontSize: isTablet ? 18 : 16),
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          Expanded(
            child: usersState.when(
              initial: () => Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                child: UsersSkeleton(itemCount: isTablet ? 12 : 8),
              ),
              loading: () => Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                child: UsersSkeleton(itemCount: isTablet ? 12 : 8),
              ),
              loaded: (users) => users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: isTablet ? 80 : 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.noUsersFound,
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshUsers,
                      child: ResponsiveBuilder(
                        mobile: _buildMobileLayout(users),
                        tablet: _buildTabletLayout(users),
                      ),
                    ),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isTablet ? 80 : 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.errorLoadingTeam,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: isTablet ? 28 : null),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 18 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: isTablet
                          ? ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            )
                          : null,
                      onPressed: () => ref
                          .read(usersNotifierProvider.notifier)
                          .loadUsers(refresh: true),
                      child: Text(
                        AppLocalizations.of(context)!.tryAgainButton,
                        style: TextStyle(fontSize: isTablet ? 18 : 16),
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

  Widget _buildMobileLayout(List<dynamic> users) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserCard(
          user: user,
          onTap: () => context.push('/user/${user.id}'),
          isTablet: false,
        );
      },
    );
  }

  Widget _buildTabletLayout(List<dynamic> users) {
    final isLandscape = context.isLandscape;
    final crossAxisCount = isLandscape ? 3 : 2;

    return ResponsiveContainer(
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isLandscape ? 1.4 : 1.3,
        ),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _UserCard(
            user: user,
            onTap: () => context.push('/user/${user.id}'),
            isTablet: true,
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback onTap;
  final bool isTablet;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: CachedNetworkImageProvider(user.avatar),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _generateJobInfo(context, user.id),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('Ver Perfil'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: CachedNetworkImageProvider(user.avatar),
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Text(
              _generateJobInfo(context, user.id),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: onTap,
        ),
        onTap: onTap,
      ),
    );
  }

  String _generateJobInfo(BuildContext context, int userId) {
    // Generate deterministic job info based on user ID
    final l10n = AppLocalizations.of(context)!;
    final jobTitles = [
      l10n.jobTitleFrontend,
      l10n.jobTitleBackend,
      l10n.jobTitleUxUi,
      l10n.jobTitleProductManager,
      l10n.jobTitleDevOps,
      l10n.jobTitleDataScientist,
      l10n.jobTitleQa,
      l10n.jobTitleTechLead,
    ];
    final departments = [
      l10n.departmentTech,
      l10n.departmentProduct,
      l10n.departmentDesign,
      l10n.departmentEngineering,
      l10n.departmentData,
      l10n.departmentQuality,
    ];

    final jobIndex = userId % jobTitles.length;
    final deptIndex = userId % departments.length;

    return '${jobTitles[jobIndex]} - ${departments[deptIndex]}';
  }
}
