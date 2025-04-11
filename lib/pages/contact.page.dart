import 'package:flutter/material.dart';
import '../widgets/base_page.dart';
import '../theme/app_theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Contact', // No need to change as it's already a proper noun
      contentPadding: 0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section with accent color
            Container(
              color: AppTheme.accentColor,
              padding: AppTheme.paddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contactez-nous',
                    style: AppTheme.headingStyle.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nous serions ravis de vous entendre !',
                    style: AppTheme.bodyTextStyle.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),
            // Contact form section
            Padding(
              padding: AppTheme.paddingMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formulaire de contact',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: AppTheme.inputDecoration(
                      'Nom',
                      'Entrez votre nom complet',
                      Icons.person,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: AppTheme.inputDecoration(
                      'Email',
                      'Entrez votre adresse email',
                      Icons.email,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 4,
                    decoration: AppTheme.inputDecoration(
                      'Message',
                      'Entrez votre message',
                      Icons.message,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: AppTheme.primaryButtonStyle,
                    child: const Text('Envoyer le message'),
                  ),
                ],
              ),
            ),
            // Contact info section
            Container(
              color: AppTheme.surfaceColor,
              padding: AppTheme.paddingMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations de contact',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(Icons.phone, '+33 1 23 45 67 89'),
                  _buildContactItem(Icons.email, 'contact@voyage.fr'),
                  _buildContactItem(
                    Icons.location_on,
                    '123 Rue de Paris, Paris, France',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTheme.bodyTextStyle)),
        ],
      ),
    );
  }
}
