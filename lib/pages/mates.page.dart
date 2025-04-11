import 'package:flutter/material.dart';
import '../widgets/base_page.dart';
import '../theme/app_theme.dart';

class MatesPage extends StatelessWidget {
  const MatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Amis",
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: AppTheme.paddingSmall,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(color: AppTheme.lightTextColor),
                ),
              ),
              title: Text(
                "Ami ${index + 1}",
                style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
              ),
              subtitle: Text(
                "Statut: Actif",
                style: TextStyle(color: AppTheme.captionColor),
              ),
              trailing: Icon(Icons.message, color: AppTheme.primaryColor),
            ),
          );
        },
      ),
    );
  }
}
