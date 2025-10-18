// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_constants.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.spacingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(),
                SizedBox(height: AppConstants.spacingLG),
                UpcomingScheduleSection(),
                SizedBox(height: AppConstants.spacingLG),
                CategoriesSection(),
                SizedBox(height: AppConstants.spacingLG),
                TopDoctorsSection(),
                SizedBox(height: AppConstants.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
