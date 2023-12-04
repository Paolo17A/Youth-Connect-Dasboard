import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:ywda_dashboard/utils/color_util.dart';
import 'package:ywda_dashboard/widgets/custom_padding_widgets.dart';

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
    padding: const EdgeInsets.all(15),
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
            padding: const EdgeInsets.all(5),
            child: AutoSizeText(addLabel,
                style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
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
        height: MediaQuery.of(context).size.height * 0.1,
        child: ElevatedButton(
          onPressed: () => onPress(),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          child: vertical10horizontal4(
            Row(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                  child: displayIcon),
              VerticalDivider(),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.08,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: 25,
                      child: Center(
                        child: AutoSizeText(demographic,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                textStyle: blackBoldStyle(size: 25))),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AutoSizeText(count,
                            maxLines: 2,
                            style: GoogleFonts.inter(
                                textStyle: blackThinStyle(size: 20))),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        )),
  );
}

Widget orgDashboardWidget(BuildContext context,
    {required String label,
    required String buttonLabel,
    required Widget displayIcon,
    required Function onPress,
    bool willHideButton = false}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.height * 0.13,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Transform.scale(scale: 1.3, child: displayIcon)),
          VerticalDivider(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.13,
            child: allPadding8Pix(
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AutoSizeText(label,
                      textAlign: TextAlign.center,
                      minFontSize: 13,
                      maxFontSize: 18,
                      style: GoogleFonts.inter(textStyle: blackBoldStyle())),
                  if (!willHideButton)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.07,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => onPress(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.mercury,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                        child: Center(
                          child: AutoSizeText(buttonLabel,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ),
                      ),
                    )
                  else
                    SizedBox(height: 45)
                ],
              ),
            ),
          ),
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

Widget semiCirclePercentWidget(
    BuildContext context, double percentValue, String label) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      ClipRRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.5,
          child: ClipRRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              widthFactor: 0.5,
              child: SfRadialGauge(
                //backgroundColor: Colors.green,
                axes: [
                  RadialAxis(
                    showLabels: false,
                    showTicks: false,
                    startAngle: 180,
                    endAngle: 0,
                    radiusFactor: 0.4,
                    canScaleToFit: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.2,
                      color: Colors.yellow.withOpacity(0.65),
                      thicknessUnit: GaugeSizeUnit.factor,
                      cornerStyle: CornerStyle.startCurve,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: percentValue * 100,
                        cornerStyle: CornerStyle.bothCurve,
                        color: Color.fromARGB(255, 230, 215, 84),
                        width: 0.2,
                        sizeUnit: GaugeSizeUnit.factor,
                      )
                    ],
                    annotations: [
                      GaugeAnnotation(
                          widget: Text(
                              '${(percentValue * 100).toStringAsFixed(2)}%\n',
                              style: blackBoldStyle()))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.09,
          child: AutoSizeText('$label\n\n', style: blackBoldStyle()))
    ],
  );
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
