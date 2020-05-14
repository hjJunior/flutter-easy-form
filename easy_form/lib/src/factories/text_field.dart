import 'package:flutter/material.dart';

class TextFieldFactory {
  static TextField copyFromWith(
    TextField textField, {
    @required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      focusNode: textField.focusNode,
      decoration: textField.decoration,
      keyboardType: textField.keyboardType,
      textInputAction: textField.textInputAction,
      textCapitalization: textField.textCapitalization,
      style: textField.style,
      strutStyle: textField.strutStyle,
      textAlign: textField.textAlign,
      textAlignVertical: textField.textAlignVertical,
      textDirection: textField.textDirection,
      autofocus: textField.autofocus,
      obscureText: textField.obscureText,
      autocorrect: textField.autocorrect,
      smartDashesType: textField.smartDashesType,
      smartQuotesType: textField.smartQuotesType,
      enableSuggestions: textField.enableSuggestions,
      maxLines: textField.maxLines,
      minLines: textField.minLines,
      expands: textField.expands,
      readOnly: textField.readOnly,
      toolbarOptions: textField.toolbarOptions,
      showCursor: textField.showCursor,
      maxLength: textField.maxLength,
      maxLengthEnforced: textField.maxLengthEnforced,
      onChanged: textField.onChanged,
      onEditingComplete: textField.onEditingComplete,
      onSubmitted: textField.onSubmitted,
      inputFormatters: textField.inputFormatters,
      enabled: textField.enabled,
      cursorWidth: textField.cursorWidth,
      cursorRadius: textField.cursorRadius,
      cursorColor: textField.cursorColor,
      selectionHeightStyle: textField.selectionHeightStyle,
      selectionWidthStyle: textField.selectionWidthStyle,
      keyboardAppearance: textField.keyboardAppearance,
      scrollPadding: textField.scrollPadding,
      enableInteractiveSelection: textField.enableInteractiveSelection,
      dragStartBehavior: textField.dragStartBehavior,
      onTap: textField.onTap,
      buildCounter: textField.buildCounter,
      scrollPhysics: textField.scrollPhysics,
      scrollController: textField.scrollController,
    );
  }
}
