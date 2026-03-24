import 'package:flutter/material.dart';

class LogoutAlertDialog extends StatelessWidget {
  const LogoutAlertDialog({super.key});

  static const Color _goldPrimary = Color(0xFFD4A843);
  static const Color _textPrimary = Color(0xFF1A3A5C);
  static const Color _textSecondary = Color(0xFF4A6FA5);
  static const Color _cardWhite = Color(0xFFF5FAFF);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: _cardWhite,
      contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Log Out',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      content: const Text(
        'Please confirm your current count is saved, otherwise your data will be lost.\n\nAre you sure you want to log out?',
        style: TextStyle(
          color: _textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: _textSecondary.withOpacity(0.25),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
