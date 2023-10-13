import 'package:flutter/material.dart';

Padding horizontalPadding5Percent(BuildContext context, Widget child) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05),
    child: child,
  );
}

Padding horizontalPadding3Percent(BuildContext context, Widget child) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.03),
    child: child,
  );
}

Padding verticalPadding5Percent(BuildContext context, Widget child) {
  return Padding(
    padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05),
    child: child,
  );
}

Padding allPadding5Percent(BuildContext context, Widget child) {
  return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: child);
}

Padding vertical10horizontal4(Widget child) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: child);
}
