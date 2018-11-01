library flutter_object_form_field;

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef String InputValueToString<T>(T entity);
typedef Future<T> ValuePicker<T>(T currentValue);

/// Form field that works with any object. Whenever tapped on, pickValue
/// function provided is invoked and the value of the field is correctly
/// updated. When displaying the object, objectToString function provided is
/// used.
class ObjectFormField<T> extends FormField<T> {
  final ValueNotifier<T> controller;
  final InputValueToString<T> objectToString;
  final ValuePicker<T> pickValue;
  final InputDecoration decoration;
  final TextStyle style;
  final TextAlign textAlign;
  final bool showResetButton;

  ObjectFormField({
    Key key,
    @Required() this.pickValue,
    this.controller,
    T initialValue,
    this.decoration = const InputDecoration(),
    this.style,
    this.textAlign = TextAlign.start,
    bool autoValidate = false,
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    bool enabled = true,
    this.showResetButton = true,
    this.objectToString,
  })  : assert(initialValue == null || controller == null),
        assert(textAlign != null),
        assert(autoValidate != null),
        super(
          key: key,
          initialValue:
              controller != null ? controller.value : (initialValue ?? null),
          onSaved: onSaved,
          validator: validator,
          autovalidate: autoValidate,
          enabled: enabled,
          builder: (FormFieldState<T> field) {},
        );

  @override
  FormFieldState<T> createState() {
    return _ObjectFormFieldState<T>();
  }
}

class _ObjectFormFieldState<T> extends FormFieldState<T> {
  Set<InteractiveInkFeature> _splashes;
  InteractiveInkFeature _currentSplash;

  ValueNotifier<T> _controller;

  ValueNotifier<T> get _effectiveController => widget.controller ?? _controller;

  @override
  ObjectFormField<T> get widget => super.widget;

  String get valueAsString => widget.objectToString == null
      ? value?.toString()
      : widget.objectToString(value);

  InputDecoration _getEffectiveDecoration() {
    return (widget.decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(context).inputDecorationTheme)
        .copyWith(
          enabled: widget.enabled,
          errorText: errorText,
        );
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = ValueNotifier<T>(widget.initialValue);
    } else {
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(ObjectFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null)
        _controller = ValueNotifier<T>(oldWidget.controller.value);
      if (widget.controller != null) {
        setValue(widget.controller.value);
        if (oldWidget.controller == null) _controller = null;
      }
    }
  }

  InteractiveInkFeature _createInkFeature(TapDownDetails details) {
    final MaterialInkController inkController = Material.of(context);
    final BuildContext editableContext = context;
    final RenderBox referenceBox =
        InputDecorator.containerOf(editableContext) ??
            editableContext.findRenderObject();
    final Offset position = referenceBox.globalToLocal(details.globalPosition);
    final Color color = Theme.of(context).splashColor;

    InteractiveInkFeature splash;
    void handleRemoved() {
      if (_splashes != null) {
        assert(_splashes.contains(splash));
        _splashes.remove(splash);
        if (_currentSplash == splash) _currentSplash = null;
      } // else we're probably in deactivate()
    }

    splash = Theme.of(context).splashFactory.create(
          controller: inkController,
          referenceBox: referenceBox,
          position: position,
          color: color,
          containedInkWell: true,
          borderRadius: BorderRadius.zero,
          onRemoved: handleRemoved,
          textDirection: Directionality.of(context),
        );

    return splash;
  }

  void _handleTapDown(TapDownDetails details) {
    _startSplash(details);
  }

  void _handleTap() {
    _confirmCurrentSplash();
    widget.pickValue(_effectiveController.value).then((newValue) {
      _effectiveController.value = newValue;
      didChange(newValue);
    });
  }

  void _handleTapCancel() {
    _cancelCurrentSplash();
  }

  void _startSplash(TapDownDetails details) {
    final InteractiveInkFeature splash = _createInkFeature(details);
    _splashes ??= HashSet<InteractiveInkFeature>();
    _splashes.add(splash);
    _currentSplash = splash;
  }

  void _confirmCurrentSplash() {
    _currentSplash?.confirm();
    _currentSplash = null;
  }

  void _cancelCurrentSplash() {
    _currentSplash?.cancel();
  }

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveInkFeature> splashes = _splashes;
      _splashes = null;
      for (InteractiveInkFeature splash in splashes) splash.dispose();
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasDirectionality(context));
    final ThemeData themeData = Theme.of(context);
    final TextStyle style = widget.style ?? themeData.textTheme.subhead;

    var stringValue = valueAsString;

    Widget child = RepaintBoundary(
      child: Text(
        stringValue ?? '',
        style: style,
        textAlign: widget.textAlign,
      ),
    );

    if (widget.decoration != null) {
      child = AnimatedBuilder(
        animation: _effectiveController,
        builder: (BuildContext context, Widget child) {
          return InputDecorator(
            decoration: _getEffectiveDecoration(),
            baseStyle: style,
            textAlign: widget.textAlign,
            isEmpty: stringValue == null,
            child: child,
          );
        },
        child: child,
      );
    }

    var children = <Widget>[
      IgnorePointer(
        ignoring: !(widget.enabled ?? widget.decoration?.enabled ?? true),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTap: _handleTap,
          onLongPress: _handleTap,
          onTapCancel: _handleTapCancel,
          child: child,
        ),
      ),
    ];

    if (widget.showResetButton && value != null) {
      children.add(
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            _effectiveController.value = null;
            didChange(null);
          },
        ),
      );
    }

    return Stack(
      alignment: const Alignment(1.0, 0),
      children: children,
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController.value = widget.initialValue;
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.value != value)
      didChange(_effectiveController.value);
  }
}
