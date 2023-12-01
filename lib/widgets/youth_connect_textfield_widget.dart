import 'package:flutter/material.dart';

class YouthConnectTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final TextInputType textInputType;
  final Icon? displayPrefixIcon;
  final Function? onSubmit;
  final bool enabled;
  const YouthConnectTextField(
      {super.key,
      required this.text,
      required this.controller,
      required this.textInputType,
      required this.displayPrefixIcon,
      this.onSubmit,
      this.enabled = true});

  @override
  State<YouthConnectTextField> createState() => _YouthConnectTextFieldState();
}

class _YouthConnectTextFieldState extends State<YouthConnectTextField> {
  late bool isObscured;

  @override
  void initState() {
    super.initState();
    isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        enabled: widget.enabled,
        controller: widget.controller,
        obscureText: isObscured,
        cursorColor: Colors.black,
        onSubmitted: (value) {
          if (widget.onSubmit != null) widget.onSubmit!();
        },
        style: TextStyle(color: Colors.black.withOpacity(0.9)),
        decoration: InputDecoration(
            alignLabelWithHint: true,
            labelText: widget.text,
            labelStyle: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontStyle: FontStyle.italic),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: Colors.white.withOpacity(0.4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 3.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            prefixIcon: widget.displayPrefixIcon,
            suffixIcon: widget.textInputType == TextInputType.visiblePassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black.withOpacity(0.6),
                    ))
                : null),
        keyboardType: widget.textInputType,
        maxLines: widget.textInputType == TextInputType.multiline ? 4 : 1);
  }
}
