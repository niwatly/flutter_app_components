import 'package:flutter/material.dart';
import 'package:flutter_app_components/view/check_box_text.dart';
import 'package:provider/provider.dart';

import 'floating_dialog.dart';

class DialogBuilder extends StatefulWidget {
  final String? okLabel;
  final String? cancelLabel;
  final String? confirmTitle;
  final String? errorTitle;
  final String? pickTitle;
  final String? askTitle;
  final TextStyle? cancelStyle;
  final TextStyle? okStyle;
  final Widget? loadingWidget;
  final TextStyle? loadingMessageStyle;
  final Color? loadingMessageBackgroundColor;
  final String? doNotShowAgainMessage;

  final Widget? child;

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
    this.loadingMessageBackgroundColor,
    this.doNotShowAgainMessage,
    this.child,
    Key? key,
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
  String get doNotShowAgainMessage => widget.doNotShowAgainMessage ?? "Do not show again";

  Route error(
    String message,
  ) =>
      DialogRoute(
        context: context,
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
        context: context,
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

  Route<bool> confirmWithDoNotShowAgain(
    String message, {
    String? title,
  }) =>
      DialogRoute<bool>(
        context: context,
        builder: (context) => ChangeNotifierProvider<_CheckBoxNotifier>(
          create: (context) => _CheckBoxNotifier(false),
          builder: (context, _) => AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0.0),
            title: Text(title ?? confirmTitle),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    message,
                  ),
                ),
                const SizedBox(height: 36),
                CheckBoxText(
                  checkBoxValue: context.watch<_CheckBoxNotifier>().value,
                  onChanged: (v) => context.read<_CheckBoxNotifier>().value = v ?? false,
                  label: doNotShowAgainMessage,
                  affinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            actions: [
              FlatButton(
                child: Text(
                  okLabel,
                  style: widget.okStyle,
                ),
                onPressed: () => Navigator.of(context).pop(context.read<_CheckBoxNotifier>().value),
              ),
            ],
          ),
        ),
      );

  Route<bool> ask({
    String? title,
    String? message,
  }) =>
      DialogRoute<bool>(
        context: context,
        builder: (context) => _createDialog(
          context: context,
          title: title ?? askTitle,
          body: message!,
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
    String? title,
    String? message,
  }) =>
      DialogRoute<int>(
        context: context,
        builder: (context) => FloatingDialog(
          onClose: () => Navigator.of(context).pop(-1),
          title: title ?? pickTitle,
          showCloseButton: false,
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

  Route loading<T>({
    Future<T>? future,
    String? message,
  }) {
    return DialogRoute(
      context: context,
      builder: (context) => FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            WidgetsBinding.instance!.addPostFrameCallback((_) => Navigator.of(context).pop());
          }

          final color = widget.loadingMessageBackgroundColor ?? (DialogTheme.of(context).backgroundColor ?? Theme.of(context).dialogBackgroundColor).withOpacity(0.8);

          return WillPopScope(
            onWillPop: () async => false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.loadingWidget ?? const CircularProgressIndicator(),
                const SizedBox(height: 16),
                if (message != null && message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Material(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      color: color,
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
    BuildContext? context,
    String? title,
    required String body,
    List<Widget>? actions,
  }) =>
      AlertDialog(
        title: title?.isNotEmpty == true ? Text(title!) : null,
        content: Text(
          body,
        ),
        actions: actions,
      );

  @override
  Widget build(BuildContext context) {
    return widget.child!;
  }
}

class _CheckBoxNotifier = ValueNotifier<bool> with Type;
