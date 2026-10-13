import 'music_disc_format_family.dart';

final class MusicDiscCapabilities {
  const MusicDiscCapabilities({
    required this.supportsColor,
    required this.supportsVinylWeight,
    required this.supportsRpm,
    required this.supportsGenericMatrix,
    required this.supportsSideMatrices,
  });

  final bool supportsColor;
  final bool supportsVinylWeight;
  final bool supportsRpm;
  final bool supportsGenericMatrix;
  final bool supportsSideMatrices;

  static MusicDiscCapabilities forFamily(MusicDiscFormatFamily family) =>
      switch (family) {
        MusicDiscFormatFamily.vinyl => const MusicDiscCapabilities(
            supportsColor: true,
            supportsVinylWeight: true,
            supportsRpm: true,
            supportsGenericMatrix: true,
            supportsSideMatrices: true,
          ),
        MusicDiscFormatFamily.opticalDisc => const MusicDiscCapabilities(
            supportsColor: true,
            supportsVinylWeight: false,
            supportsRpm: false,
            supportsGenericMatrix: true,
            supportsSideMatrices: false,
          ),
        MusicDiscFormatFamily.tape => const MusicDiscCapabilities(
            supportsColor: true,
            supportsVinylWeight: false,
            supportsRpm: false,
            supportsGenericMatrix: true,
            supportsSideMatrices: false,
          ),
        MusicDiscFormatFamily.digital => const MusicDiscCapabilities(
            supportsColor: false,
            supportsVinylWeight: false,
            supportsRpm: false,
            supportsGenericMatrix: false,
            supportsSideMatrices: false,
          ),
        MusicDiscFormatFamily.other => const MusicDiscCapabilities(
            supportsColor: true,
            supportsVinylWeight: true,
            supportsRpm: true,
            supportsGenericMatrix: true,
            supportsSideMatrices: true,
          ),
      };
}
