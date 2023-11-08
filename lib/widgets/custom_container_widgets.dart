import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/custom_text_widgets.dart';

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

Container viewContentContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: child);
}

Widget viewContentLabelRow(BuildContext context,
    {required List<Widget> children}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Row(children: children));
}

Widget viewContentEntryRow(BuildContext context,
    {required List<Widget> children,
    required Color borderColor,
    required isLastEntry}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 50,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: isLastEntry
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))
              : null),
      child: Row(children: children));
}

Widget viewFlexTextCell(String text,
    {required int flex,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    BorderRadius? customBorderRadius}) {
  return Flexible(
    flex: flex,
    child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor), color: backgroundColor),
        child: ClipRRect(
          child: Center(
              child: AutoSizeText(text,
                  overflow: TextOverflow.ellipsis,
                  style: viewEntryStyle(textColor))),
        )),
  );
}

Widget viewFlexActionsCell(List<Widget> children,
    {required int flex,
    required Color backgroundColor,
    required Color borderColor,
    BorderRadius? customBorderRadius}) {
  return Flexible(
      flex: flex,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: customBorderRadius,
            color: backgroundColor),
        child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: children)),
      ));
}

Container breakdownContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.23,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 217, 217, 217)),
      child: Padding(padding: const EdgeInsets.all(11), child: child));
}

Container loginBackgroundContainer(BuildContext context,
    {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover)),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.9, child: child),
        Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: double.infinity,
            color: CustomColors.darkBlue,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(children: [
                AutoSizeText(
                  'Youth Development Affairs Office of Laguna * Copyright All Rights Reserved 2023',
                  style: whiteBoldStyle(),
                )
              ]),
            ))
      ]));
}

Container loginBoxContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      //height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: child);
}

Container registerBoxContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      //height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: child);
}
