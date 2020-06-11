import 'package:flutter/material.dart';

import 'floating_dialog.dart';

class DialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  DialogRoute({
    RouteSettings settings,
    this.builder,
    this.barrierDismissible = true,
  }) : super(settings: settings);

  @override
  final bool barrierDismissible;

  @override
  String get barrierLabel => null;

  @override
  Color get barrierColor => const Color(0x80000000);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.linear,
        ),
        child: child);
  }
}

class DialogBuilder {
  final String okLabel;
  final String cancelLabel;
  final String confirmLabel;
  final String errorLabel;
  final TextStyle cancelStyle;
  final TextStyle okStyle;
  final Widget loadingWidget;
  final TextStyle loadingMessageStyle;
  final Color contentBackgroundColor;

  DialogBuilder({
    @required this.okLabel,
    @required this.cancelLabel,
    @required this.confirmLabel,
    @required this.errorLabel,
    @required this.cancelStyle,
    @required this.okStyle,
    @required this.loadingWidget,
    @required this.loadingMessageStyle,
    @required this.contentBackgroundColor,
  });

  Route error(String message) => DialogRoute(
        builder: (context) => _createDialog(
          context: context,
          title: errorLabel,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                okLabel,
                style: okStyle,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Route confirm(String message) => DialogRoute(
        builder: (context) => _createDialog(
          context: context,
          title: confirmLabel,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                okLabel,
                style: okStyle,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Route<bool> ask({
    String title,
    String message,
  }) =>
      DialogRoute<bool>(
        builder: (context) => _createDialog(
          context: context,
          title: title ?? confirmLabel,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                cancelLabel,
                style: cancelStyle,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(
                okLabel,
                style: okStyle,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

  Route<int> pick(List<String> candidates, {String title, String message}) => DialogRoute<int>(
        builder: (context) => FloatingDialog(
          onClose: () => Navigator.of(context).pop(-1),
          title: title,
          contentBackgroundColor: contentBackgroundColor,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => const FractionallySizedBox(
              widthFactor: 0.8,
              child: Divider(),
            ),
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            itemCount: candidates.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.of(context).pop(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  candidates[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DialogTheme.of(context).contentTextStyle,
                ),
              ),
            ),
          ),
        ),
      );

  Route<T> loading<T>({
    Future<T> future,
    String message,
  }) {
    final child = WillPopScope(
      onWillPop: () async => false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          if (message != null && message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Material(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                color: const Color(0x60000000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    message,
                    style: loadingMessageStyle,
                  ),
                ),
              ),
            )
        ],
      ),
    );

    return DialogRoute(
      builder: (context) => FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            T data;

            if (snapshot.hasData) {
              data = snapshot.data;
            }

            WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pop(data));
          }

          return child;
        },
      ),
      barrierDismissible: false,
    );
  }

  AlertDialog _createDialog({
    BuildContext context,
    String title,
    String body,
    List<Widget> actions,
  }) =>
      AlertDialog(
        backgroundColor: contentBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: title?.isNotEmpty == true ? Text(title) : null,
        content: Text(
          body,
        ),
        contentTextStyle: Theme.of(context).textTheme.bodyText2.apply(fontSizeFactor: 1),
        actions: actions,
      );
}
