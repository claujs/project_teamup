import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(usersNotifierProvider.notifier).loadUsers();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(usersNotifierProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshUsers();
    }
  }

  Future<void> _refreshUsers() async {
    await ref.read(usersNotifierProvider.notifier).loadUsers(refresh: true);
  }

  void _onSearchChanged(String query) {
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
                      AppStrings.errorLoadingTeam,
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
                        AppStrings.tryAgainButton,
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
                  _generateJobInfo(user.id),
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
              _generateJobInfo(user.id),
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

  String _generateJobInfo(int userId) {
    // Generate deterministic job info based on user ID
    final jobTitles = AppStrings.jobTitles;
    final departments = AppStrings.departments;

    final jobIndex = userId % jobTitles.length;
    final deptIndex = userId % departments.length;

    return '${jobTitles[jobIndex]} - ${departments[deptIndex]}';
  }
}
