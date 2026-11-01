import 'package:collectarr_app/features/library/kinds/comic/edit/grading_options.dart';
import 'package:collectarr_app/features/library/kinds/comic/data/custom_label_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A slab label type and the colours its label is printed in.
typedef ComicSlabLabel = ({
  String name,
  Color start,
  Color end,
  Color bar,
  bool lightBackground,
});

ComicSlabLabel _label(String name, int start, int end, int bar,
        {bool lightBackground = false}) =>
    (
      name: name,
      start: Color(start),
      end: Color(end),
      bar: Color(bar),
      lightBackground: lightBackground,
    );

ComicSlabLabel _blue(String name, int bar) =>
    _label(name, 0xffdde4f4, 0xff90b2de, bar);

ComicSlabLabel _gold(String name, int bar) =>
    _label(name, 0xfffff5dd, 0xfffddd97, bar, lightBackground: true);

/// The reference's slab label types in its order, each with the label's
/// background gradient and the bar along its top.
final List<ComicSlabLabel> comicSlabLabels = [
  _blue('Universal Grade', 0xff2f73b7),
  _gold('Signature Series', 0xfff4c246),
  _label('Qualified Grade', 0xffdce6dc, 0xff86ae8c, 0xff357846),
  _label('Restored Grade', 0xffe2deed, 0xffa08dc5, 0xff564293),
  _label('Pedigree Grade', 0xffe0c59a, 0xff9f8965, 0xff242022),
  _blue('Conserved Grade', 0xff6c6e6f),
  _gold('Signature Series Qualified', 0xff357846),
  _gold('Signature Series Restored', 0xff574393),
  _gold('Signature Series Conserved', 0xff6c6e6f),
  _gold('CGC x JSA Authentic Autograph', 0xff000000),
  _blue('CBCS Certified', 0xff2f73b7),
  _gold('CBCS Authentic Signature', 0xfff4c246),
  _gold('CBCS Verified Signature', 0xfff4c246),
  _blue('CBCS Restored Grade', 0xff2f73b7),
  _label(
      'CBCS Verified Red Label (legacy)', 0xfff1d5dd, 0xffcb5d65, 0xffdb3330),
];

/// The label a slab is drawn with; a slab without a known label type gets
/// the Universal Grade label, as in the reference.
ComicSlabLabel comicSlabLabel(String? labelType) {
  final name = labelType?.trim().toLowerCase();
  return comicSlabLabels.firstWhere((label) => label.name.toLowerCase() == name,
      orElse: () => comicSlabLabels.first);
}

LinearGradient comicSlabLabelGradient(ComicSlabLabel label) =>
    LinearGradient(colors: [label.start, label.end]);

/// The reference's 62 px slab label scaled to a cover this wide.
double _slabScale(double width) => (width / 340).clamp(0.12, 1.0);

const _slabBorder = Color(0xffc2d8e6);

/// A slabbed comic's cover in its case: the slab label with the grade,
/// grading company and the user's Custom Label image above the cover, and
/// the case's light blue frame around it.
class ComicSlab extends StatelessWidget {
  const ComicSlab({
    required this.child,
    this.grade,
    this.gradingCompany,
    this.labelType,
    this.customLabel,
    super.key,
  });

  final Widget child;
  final String? grade;
  final String? gradingCompany;
  final String? labelType;
  final String? customLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final scale = _slabScale(constraints.maxWidth);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SlabLabel(
                scale: scale,
                label: comicSlabLabel(labelType),
                grade: comicGradeCode(grade),
                gradingCompany: gradingCompany?.trim() ?? '',
                customLabel: customLabel,
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(7 * scale),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xffe1f1ff), Color(0xffd5f4ff)]),
                    border: Border(
                      left: BorderSide(color: _slabBorder),
                      right: BorderSide(color: _slabBorder),
                      bottom: BorderSide(color: _slabBorder),
                    ),
                  ),
                  child: child,
                ),
              ),
            ],
          );
        },
      );
}

class _SlabLabel extends StatelessWidget {
  const _SlabLabel({
    required this.scale,
    required this.label,
    required this.grade,
    required this.gradingCompany,
    required this.customLabel,
  });

  final double scale;
  final ComicSlabLabel label;
  final String? grade;
  final String gradingCompany;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final edge = (6 * scale).clamp(0.0, 3.0);
    return Container(
      height: 62 * scale,
      decoration: BoxDecoration(
        gradient: comicSlabLabelGradient(label),
        border: Border.all(color: _slabBorder),
      ),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 10 * scale,
            child: ColoredBox(color: label.bar)),
        Positioned.fill(
          top: 10 * scale,
          child: Center(
            child: Text(gradingCompany,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                    fontSize: 46 * scale,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: label.lightBackground
                        ? const Color(0x1c000000)
                        : const Color(0x38ffffff))),
          ),
        ),
        if (comicCustomLabelKey(customLabel) != null)
          Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: _SlabCustomLabelImage(customLabel!)),
        if (grade case final grade?)
          Positioned(
            top: 5 * scale,
            left: 7 * scale,
            width: 70 * scale,
            height: 53 * scale,
            child: _SlabGrade(
                scale: scale, edge: edge, bar: label.bar, grade: grade),
          ),
      ]),
    );
  }
}

/// The image the user loaded for the slab's Custom Label, at the label's
/// right edge and full height; nothing until one is loaded.
class _SlabCustomLabelImage extends ConsumerWidget {
  const _SlabCustomLabelImage(this.label);

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(comicCustomLabelImageProvider(label)).value) {
        final image? =>
          Image.memory(image, fit: BoxFit.fitHeight, gaplessPlayback: true),
        null => const SizedBox.shrink(),
      };
}

/// The white grade box: the bar colour edges its left and bottom, a perfect
/// 10 is printed in gold and a text grade such as NG or ART is narrowed.
class _SlabGrade extends StatelessWidget {
  const _SlabGrade({
    required this.scale,
    required this.edge,
    required this.bar,
    required this.grade,
  });

  final double scale;
  final double edge;
  final Color bar;
  final String grade;

  @override
  Widget build(BuildContext context) {
    final number = double.tryParse(grade);
    final text = number == 10 ? '10' : grade;
    final widthFactor = number != null
        ? 1.0
        : text.length > 2
            ? .75
            : .85;
    final radius = BorderRadius.circular(10 * scale);
    return Container(
      padding: EdgeInsets.only(left: edge, bottom: edge),
      decoration: BoxDecoration(color: bar, borderRadius: radius),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(widthFactor, 1.15, 1),
            child: Text(text,
                style: TextStyle(
                    fontSize: 40 * scale,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color:
                        number == 10 ? const Color(0xffd3a63d) : Colors.black)),
          ),
        ),
      ),
    );
  }
}
