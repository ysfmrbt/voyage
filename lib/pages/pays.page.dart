import 'package:flutter/material.dart';
import '../widgets/base_page.dart';
import '../theme/app_theme.dart';

class PaysPage extends StatelessWidget {
  const PaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pays = [
      {"nom": "France", "capitale": "Paris"},
      {"nom": "Espagne", "capitale": "Madrid"},
      {"nom": "Italie", "capitale": "Rome"},
      {"nom": "Allemagne", "capitale": "Berlin"},
    ];

    return BasePage(
      title: "Pays",
      body: ListView.builder(
        itemCount: pays.length,
        itemBuilder: (context, index) {
          return Card(
            margin: AppTheme.paddingSmall,
            child: ListTile(
              title: Text(
                pays[index]["nom"]!,
                style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
              ),
              subtitle: Text(
                "Capitale: ${pays[index]["capitale"]}",
                style: TextStyle(color: AppTheme.captionColor),
              ),
              leading: Icon(Icons.flag, color: AppTheme.primaryColor),
              trailing: Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
            ),
          );
        },
      ),
    );
  }
}
