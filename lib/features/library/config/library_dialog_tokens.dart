import 'package:flutter/material.dart';

const double kLibraryFormControlHeight = 40;
const double kLibraryDialogFooterButtonHeight = 36;
const double kLibraryDialogFooterHorizontalPadding = 10;
const double kLibraryDialogFooterVerticalPadding = 6;
const double kLibraryDialogTabReorderStartDistance = 16;

BorderRadius get kLibraryDialogFooterButtonRadius => BorderRadius.circular(2);

RoundedRectangleBorder get kLibraryDialogFooterButtonShape =>
    RoundedRectangleBorder(borderRadius: kLibraryDialogFooterButtonRadius);
