import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';

void showYouthInformationDialog(
    BuildContext context, DocumentSnapshot youthDoc, String orgName) {
  showDialog(
      context: context,
      builder: (context) {
        final youthData = youthDoc.data() as Map<dynamic, dynamic>;
        String formattedName =
            '${youthData['firstName']} ${youthData['lastName']}';
        String city = youthData['city'];
        String gender = youthData['gender'];
        String civilStatus = youthData['civilStatus'];
        String school = youthData['school'];
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: () => GoRouter.of(context).pop(),
                      child: Text(
                        'X',
                        style: blackBoldStyle(),
                      ))
                ]),
                AutoSizeText(
                  'YOUTH DETAILS',
                  style: blackBoldStyle(size: 35),
                ),
                Divider(thickness: 2),
                allPadding20Pix(Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(10)),
                        child: allPadding8Pix(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText('Name: $formattedName',
                                style: blackThinStyle(size: 26)),
                            AutoSizeText('City: $city',
                                style: blackThinStyle(size: 26)),
                            AutoSizeText('Gender: $gender',
                                style: blackThinStyle(size: 26)),
                            AutoSizeText('Civil Status: $civilStatus',
                                style: blackThinStyle(size: 26)),
                            AutoSizeText('School: $school',
                                style: blackThinStyle(size: 26)),
                          ],
                        ))),
                    Gap(20),
                    AutoSizeText('Organization: $orgName',
                        style: blackThinStyle(size: 26)),
                  ],
                ))
              ],
            ),
          ),
        ));
      });
}
