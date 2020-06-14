import 'package:flutter/material.dart';

import 'dialog_route.dart';
import 'floating_dialog.dart';

class DialogBuilder extends StatefulWidget {
  final String okLabel;
  final String cancelLabel;
  final String confirmTitle;
  final String errorTitle;
  final String pickTitle;
  final String askTitle;
  final TextStyle cancelStyle;
  final TextStyle okStyle;
  final Widget loadingWidget;
  final TextStyle loadingMessageStyle;
  final Widget child;

  const DialogBuilder({
    this.okLabel,
    this.cancelLabel,
    this.confirmTitle,
    this.errorTitle,
    this.pickTitle,
    this.askTitle,
    this.cancelStyle,
    this.okStyle,
    this.loadingWidget,
    this.loadingMessageStyle,
    this.child,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DialogBuilderState();
}

class DialogBuilderState extends State<DialogBuilder> {
  String get okLabel => widget.okLabel ?? "OK";
  String get cancelLabel => widget.cancelLabel ?? "Cancel";
  String get errorTitle => widget.errorTitle ?? "Error";
  String get confirmTitle => widget.confirmTitle ?? "Confirm";
  String get pickTitle => widget.pickTitle ?? "Select one";
  String get askTitle => widget.askTitle ?? "Ask";

  Route error(
    String message,
  ) =>
      DialogRoute(
        builder: (context) => _createDialog(
          context: context,
          title: errorTitle,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                okLabel,
                style: widget.okStyle,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  Route confirm(
    String message,
  ) =>
      DialogRoute(
        builder: (context) => _createDialog(
          context: context,
          title: confirmTitle,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                okLabel,
                style: widget.okStyle,
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
          title: title ?? askTitle,
          body: message,
          actions: [
            FlatButton(
              child: Text(
                cancelLabel,
                style: widget.cancelStyle,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text(
                okLabel,
                style: widget.okStyle,
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

  Route<int> pick(
    List<String> candidates, {
    String title,
    String message,
  }) =>
      DialogRoute<int>(
        builder: (context) => FloatingDialog(
          onClose: () => Navigator.of(context).pop(-1),
          title: title ?? pickTitle,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => const Divider(height: 12),
            itemCount: candidates.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.of(context).pop(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  candidates[index],
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
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

          return WillPopScope(
            onWillPop: () async => false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.loadingWidget ?? CircularProgressIndicator(),
                const SizedBox(height: 16),
                if (message != null && message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Material(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      color: (DialogTheme.of(context).backgroundColor ?? Theme.of(context).dialogBackgroundColor).withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        child: Text(
                          message,
                          style: widget.loadingMessageStyle,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
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
        title: title?.isNotEmpty == true ? Text(title) : null,
        content: Text(
          body,
        ),
        actions: actions,
      );

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
