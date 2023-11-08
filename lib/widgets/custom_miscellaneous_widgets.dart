import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_text_widgets.dart';

Widget viewContentUnavailable(BuildContext context, {required String text}) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.65,
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 38,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
      ),
    ),
  );
}

Widget viewHeaderAddButton(
    {required Function addFunction, required String addLabel}) {
  return Padding(
    padding: const EdgeInsets.all(25),
    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
          onPressed: () {
            addFunction();
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 88, 147, 201),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: AutoSizeText(addLabel,
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold))),
          ))
    ]),
  );
}

Widget analyticReportWidget(BuildContext context,
    {required String count,
    required String demographic,
    required Widget displayIcon,
    required Function onPress}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.height * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Row(children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AutoSizeText(count,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 40)),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.07,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => onPress(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    child: Center(
                      child: AutoSizeText(demographic,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Transform.scale(scale: 2, child: displayIcon))
        ])),
  );
}

Widget percentBarWidget(
    BuildContext context, Color barColor, double percentage, String label) {
  double baseBarWidth = MediaQuery.of(context).size.width * 0.1;
  return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: baseBarWidth,
          child: Stack(
            children: [
              Container(
                height: 20,
                width: baseBarWidth,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.5)),
              ),
              Container(
                height: 20,
                width: baseBarWidth * percentage,
                color: barColor,
              ),
            ],
          ),
        ),
        SizedBox(
          width: baseBarWidth,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: AutoSizeText(
                '${(percentage * 100).toStringAsFixed(1)}%\t $label',
                maxLines: 2,
                style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 17))),
          ),
        )
      ]));
}

Widget registerHeader() {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(children: [
        Text('REGISTRATION',
            style: GoogleFonts.poppins(textStyle: blackBoldStyle(size: 30)))
      ]),
      Divider(thickness: 2)
    ]),
  );
}
