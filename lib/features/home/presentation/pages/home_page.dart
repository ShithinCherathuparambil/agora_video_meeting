import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Text(AppConstants.appName),
        backgroundColor: AppTheme.white,
        elevation: 1,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppTheme.mediumGray),
                          const SizedBox(width: 12),
                          Text(state.user.displayName),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: AppTheme.red),
                          SizedBox(width: 12),
                          Text('Sign Out'),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: AppTheme.primaryYellow,
                      child: Text(
                        state.user.displayName.isNotEmpty
                            ? state.user.displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthAuthenticated) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${state.user.displayName}!',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppTheme.darkGray,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ready to start your next meeting?',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppTheme.mediumGray),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 32),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Action Cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.video_call,
                        title: 'Start Meeting',
                        subtitle: 'Begin a new video call',
                        onTap: () {
                          // TODO: Navigate to start meeting
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Start Meeting - Coming Soon!'),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.group_add,
                        title: 'Join Meeting',
                        subtitle: 'Enter meeting ID',
                        onTap: () {
                          context.go('/join-meeting');
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.schedule,
                        title: 'Schedule',
                        subtitle: 'Plan future meetings',
                        onTap: () {
                          // TODO: Navigate to schedule meeting
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Schedule Meeting - Coming Soon!'),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.history,
                        title: 'History',
                        subtitle: 'View past meetings',
                        onTap: () {
                          // TODO: Navigate to meeting history
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meeting History - Coming Soon!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, size: 30, color: AppTheme.darkGray),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
