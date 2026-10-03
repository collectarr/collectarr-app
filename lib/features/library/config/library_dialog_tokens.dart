import 'package:flutter/material.dart';

const double kLibraryFormControlHeight = 34;
const double kLibraryDialogFooterButtonHeight = 32;
const double kLibraryDialogFooterHorizontalPadding = 10;
const double kLibraryDialogFooterVerticalPadding = 6;
const double kLibraryDialogTabReorderStartDistance = 16;

BorderRadius get kLibraryDialogFooterButtonRadius => BorderRadius.circular(2);

RoundedRectangleBorder get kLibraryDialogFooterButtonShape =>
    RoundedRectangleBorder(borderRadius: kLibraryDialogFooterButtonRadius);
