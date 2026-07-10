import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../services/localization_service.dart';

class LogoutAlertDialog extends StatelessWidget {
  const LogoutAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isMalayalam = loc.currentLangCode == 'ml';
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.cardWhite,
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
            Text(
              loc.tr('logout'),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: isMalayalam ? 16 : 20,
              ),
            ),
          ],
        ),
      ),
      content: Text(
        loc.tr('logout_confirmation'),
        style: const TextStyle(
          color: AppColors.textSecondary,
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
                        color: AppColors.textSecondary.withOpacity(0.25),
                      ),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    loc.tr('cancel'),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMalayalam ? 12 : 15,
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
                  child: Text(
                    loc.tr('logout'),
                    style: TextStyle(
                      fontSize: isMalayalam ? 12 : 15,
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

