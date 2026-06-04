import 'package:flutter/material.dart';

const double kLibraryDialogFooterButtonHeight = 36;
const double kLibraryDialogFooterHorizontalPadding = 10;
const double kLibraryDialogFooterVerticalPadding = 6;
const Duration kLibraryDialogTabReorderLongPressDelay =
    Duration(milliseconds: 80);

BorderRadius get kLibraryDialogFooterButtonRadius => BorderRadius.circular(3);

RoundedRectangleBorder get kLibraryDialogFooterButtonShape =>
    RoundedRectangleBorder(borderRadius: kLibraryDialogFooterButtonRadius);
