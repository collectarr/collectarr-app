import 'package:flutter/material.dart';

const double kLibraryDialogFooterButtonHeight = 32;
const double kLibraryDialogFooterHorizontalPadding = 10;
const double kLibraryDialogFooterVerticalPadding = 6;

BorderRadius get kLibraryDialogFooterButtonRadius => BorderRadius.circular(4);

RoundedRectangleBorder get kLibraryDialogFooterButtonShape =>
    RoundedRectangleBorder(borderRadius: kLibraryDialogFooterButtonRadius);
