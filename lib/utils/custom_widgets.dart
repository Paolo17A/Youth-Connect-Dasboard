import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Container bodyWidgetWhiteBG(BuildContext context, Widget child) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: child);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, Widget child) {
  return Stack(children: [
    child,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Padding horizontalPadding5Percent(BuildContext context, Widget child) {
  return Padding(
    padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05),
    child: child,
  );
}

TextStyle interSize19() {
  return GoogleFonts.inter(textStyle: const TextStyle(fontSize: 19));
}

Padding vertical10horizontal4(Widget child) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: child);
}

SizedBox imageSelectorSizedBox(BuildContext context, List<Widget> children) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: Padding(
          padding: const EdgeInsets.all(22),
          child: Wrap(
              runSpacing: MediaQuery.of(context).size.height * 0.01,
              runAlignment: WrapAlignment.center,
              children: children)));
}

SizedBox squareBox150(Widget child) {
  return SizedBox(width: 150, height: 150, child: child);
}
