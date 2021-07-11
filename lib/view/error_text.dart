import 'package:flutter/material.dart';
import 'package:flutter_app_components/view/refresh_button.dart';

class ErrorText extends StatelessWidget {
  final String label;
  final Future Function()? retryCallback;

  const ErrorText({
    required this.label,
    this.retryCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 2,
            ),
          ),
          if (retryCallback != null)
            RefreshButton(
              onRefresh: retryCallback,
            ),
        ],
      ),
    );
  }
}
