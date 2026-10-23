import 'dart:math' as math;

import 'package:collectarr_app/core/localization/app_formats.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Reference pie colors, in rank order.
const statsChartPalette = [
  Color(0xFFD43D51),
  Color(0xFFE1604E),
  Color(0xFFEA8150),
  Color(0xFFF0A059),
  Color(0xFFF3BE6A),
  Color(0xFFD7BC50),
  Color(0xFFB4BC3C),
  Color(0xFF88BC32),
  Color(0xFF4BBA38),
];

/// Reference colors of fixed segments, such as completeness tiers or a
/// yes/no split, in segment order.
const statsSegmentPalette = [
  Color(0xFFF28B8B),
  Color(0xFF7ABEF7),
  Color(0xFFA6DA8A),
  Color(0xFFEFD75C),
  Color(0xFFBDBDBD),
];

/// Colors for fixed segment [labels], in order.
Map<String, Color> statsSegmentColors(List<String> labels) => {
      for (var i = 0; i < labels.length; i++)
        labels[i]: statsSegmentPalette[i % statsSegmentPalette.length]
    };

/// The reference's statistics box: white with a #DDD frame in the light skin.
BoxDecoration statsPanelDecoration(BuildContext context) => BoxDecoration(
      color: appManagementPanelColor(context),
      border: appPalette(context).isDark
          ? null
          : Border.all(color: appPalette(context).divider),
    );

/// A titled statistics panel.
class StatsSection extends StatelessWidget {
  const StatsSection({super.key, required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Container(
          decoration: statsPanelDecoration(context),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            child,
          ])));
}

/// The untitled summary panel at the top of a statistics tab.
class StatsSummaryPanel extends StatelessWidget {
  const StatsSummaryPanel({super.key, required this.lines});
  final List<Widget> lines;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
          decoration: statsPanelDecoration(context),
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            for (var i = 0; i < lines.length; i++) ...[
              if (i > 0) const SizedBox(height: 14),
              lines[i],
            ],
          ])));
}

/// Sections in two columns on wide pages, filled left to right, as in the
/// reference; one column on narrow pages.
class StatsTwoColumns extends StatelessWidget {
  const StatsTwoColumns({super.key, required this.sections});
  final List<Widget> sections;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 800
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var column = 0; column < 2; column++) ...[
                if (column == 1) const SizedBox(width: 32),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      for (var i = column; i < sections.length; i += 2)
                        sections[i]
                    ])),
              ],
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: sections));
}

/// A summary line with bold figures between regular words.
class StatsSummaryLine extends StatelessWidget {
  const StatsSummaryLine(
      {super.key, required this.parts, required this.fontSize});
  final List<(String, bool)> parts;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Text.rich(
      TextSpan(children: [
        for (final (text, bold) in parts)
          TextSpan(
              text: text,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      ]),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize));
}

/// Reference legend: a 40 x 12 swatch and the label.
class StatsLegend extends StatelessWidget {
  const StatsLegend({super.key, required this.colors});
  final Map<String, Color> colors;
  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: 16, runSpacing: 6, children: [
        for (final MapEntry(key: label, value: color) in colors.entries)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 12, color: color),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
      ]);
}

/// One row of a ranked item list: a 90 px image, a blue title, optional
/// lines below it, a bottom line and an optional trailing figure.
class StatsItemTile extends StatelessWidget {
  const StatsItemTile({
    super.key,
    required this.image,
    required this.title,
    this.lines = const [],
    this.bottom,
    this.trailing,
    this.onTap,
  });
  final Widget image;
  final String title;
  final List<Widget> lines;
  final Widget? bottom;
  final Widget? trailing;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: appManagementPanelColor(context),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 3,
                  offset: Offset(0, 1)),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 90, child: image),
                      const SizedBox(width: 7),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: appPalette(context).itemTitle)),
                            ...lines,
                            const Spacer(),
                            if (bottom != null) bottom!,
                          ])),
                      const SizedBox(width: 8),
                      if (trailing != null) trailing!,
                    ]),
              ),
            ),
          ),
        ),
      );
}

/// The grey value badge at the bottom right of a ranked row.
class StatsValueBadge extends StatelessWidget {
  const StatsValueBadge(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Align(
      alignment: Alignment.bottomRight,
      child: Container(
          color: const Color(0xFF777777),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700))));
}

/// Money totals per currency joined with "+"; no amounts read as zero, as
/// in the reference.
String formatStatsMoneyTotals(Map<String?, int> totals) {
  if (totals.isEmpty) {
    return AppFormats.current.formatMoney(0, AppFormats.current.currency);
  }
  final currencies = totals.keys.toList()
    ..sort((a, b) => (a ?? '').compareTo(b ?? ''));
  return currencies
      .map((currency) => AppFormats.current.formatMoney(
          totals[currency], currency ?? AppFormats.current.currency))
      .join(' + ');
}

/// A pie with its legend; counts are in the tooltip.
class StatsPieChart extends StatelessWidget {
  const StatsPieChart({
    super.key,
    required this.values,
    required this.emptyLabel,
    this.colorsByLabel = const {},
    this.ranked = true,
    this.valueLabel,
  });
  final Map<String, num> values;
  final String emptyLabel;
  final Map<String, Color> colorsByLabel;

  /// Largest slice first; otherwise the given order, as for fixed categories.
  final bool ranked;
  final String Function(num value)? valueLabel;
  @override
  Widget build(BuildContext context) {
    final slices = values.entries.where((e) => e.value > 0).toList();
    if (ranked) slices.sort((a, b) => b.value.compareTo(a.value));
    final total = slices.fold<num>(0, (n, e) => n + e.value);
    if (total == 0) return Text(emptyLabel);
    final colors = [
      for (var i = 0; i < slices.length; i++)
        colorsByLabel[slices[i].key] ??
            statsChartPalette[i % statsChartPalette.length]
    ];
    final legend = ranked
        ? {for (var i = 0; i < slices.length; i++) slices[i].key: colors[i]}
        : colorsByLabel;
    return Column(children: [
      StatsLegend(colors: legend),
      const SizedBox(height: 12),
      LayoutBuilder(
          builder: (context, constraints) => SizedBox(
                height: math.min(420, constraints.maxWidth),
                width: math.min(420, constraints.maxWidth),
                child: Tooltip(
                    message: [
                      for (final e in slices)
                        '${e.key}: ${valueLabel?.call(e.value) ?? e.value} '
                            '(${(e.value / total * 100).toStringAsFixed(1)}%)'
                    ].join('\n'),
                    child: CustomPaint(
                        painter: _PiePainter(
                            [for (final e in slices) e.value], colors))),
              )),
    ]);
  }
}

class _PiePainter extends CustomPainter {
  const _PiePainter(this.values, this.colors);
  final List<num> values;
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<num>(0, (a, b) => a + b);
    final side = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
        center: size.center(Offset.zero), width: side, height: side);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter oldDelegate) =>
      !listEquals(values, oldDelegate.values) ||
      !listEquals(colors, oldDelegate.colors);
}

/// Bars ranked by value, or a year area chart with empty years filled in.
class StatsSeriesChart extends StatelessWidget {
  const StatsSeriesChart({
    super.key,
    required this.values,
    required this.accent,
    required this.emptyLabel,
    required this.valueLabel,
    this.axisLabel = statsPlainAxisLabel,
    this.chronological = false,
  });
  final Map<String, num> values;
  final Color accent;
  final String emptyLabel;
  final String Function(num value) valueLabel;

  /// Value axis ticks; a bare number unless the chart shows money.
  final String Function(num value) axisLabel;
  final bool chronological;
  @override
  Widget build(BuildContext context) {
    var entries = values.entries.toList();
    if (chronological) {
      final years = entries
          .map((e) => int.tryParse(e.key))
          .whereType<int>()
          .toList()
        ..sort();
      if (years.isNotEmpty) {
        entries = [
          for (var year = years.first; year <= years.last; year++)
            MapEntry('$year', values['$year'] ?? 0),
          if (values['Unknown'] case final count?) MapEntry('Unknown', count)
        ];
      }
    } else {
      entries.sort((a, b) => b.value.compareTo(a.value));
    }
    if (entries.isEmpty) return Text(emptyLabel);
    final ticks = statsAxisTicks([for (final e in entries) e.value]);
    return _ScrollingPlot(
        count: entries.length,
        labels: [for (final e in entries) e.key],
        tooltips: [for (final e in entries) '${e.key}: ${valueLabel(e.value)}'],
        ticks: ticks,
        tickLabel: axisLabel,
        painter: (gridColor) => _SeriesPainter(
            ticks: ticks,
            values: [for (final e in entries) e.value],
            accent: accent,
            area: chronological,
            gridColor: gridColor));
  }
}

/// Bars split into fixed segments, such as completeness tiers per platform.
class StatsStackedBarChart extends StatelessWidget {
  const StatsStackedBarChart({
    super.key,
    required this.values,
    required this.segmentColors,
    required this.emptyLabel,
    required this.valueLabel,
    this.axisLabel = statsPlainAxisLabel,
  });

  /// Bar label to segment amounts; segments follow [segmentColors] order.
  final Map<String, Map<String, num>> values;
  final Map<String, Color> segmentColors;
  final String emptyLabel;
  final String Function(num value) valueLabel;

  /// Value axis ticks; a bare number unless the chart shows money.
  final String Function(num value) axisLabel;
  @override
  Widget build(BuildContext context) {
    num total(Map<String, num> segments) =>
        segments.values.fold<num>(0, (a, b) => a + b);
    final bars = values.entries.where((e) => total(e.value) > 0).toList()
      ..sort((a, b) => total(b.value).compareTo(total(a.value)));
    if (bars.isEmpty) return Text(emptyLabel);
    final segments = segmentColors.keys.toList();
    final ticks = statsAxisTicks([for (final bar in bars) total(bar.value)]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: StatsLegend(colors: segmentColors)),
      const SizedBox(height: 12),
      _ScrollingPlot(
          count: bars.length,
          labels: [for (final bar in bars) bar.key],
          tooltips: [
            for (final bar in bars)
              [
                bar.key,
                for (final segment in segments)
                  if ((bar.value[segment] ?? 0) > 0)
                    '$segment: ${valueLabel(bar.value[segment]!)}'
              ].join('\n')
          ],
          ticks: ticks,
          tickLabel: axisLabel,
          painter: (gridColor) => _StackedPainter(
              ticks: ticks,
              bars: [
                for (final bar in bars)
                  [for (final segment in segments) bar.value[segment] ?? 0]
              ],
              colors: segmentColors.values.toList(),
              gridColor: gridColor)),
    ]);
  }
}

/// A tick as a bare number, as the reference's count axes show it.
String statsPlainAxisLabel(num value) => value == value.roundToDouble()
    ? value.round().toString()
    : value.toString();

/// Rounded axis ticks from 0, about five steps of 1, 2 or 5 x 10^n, as the
/// reference charts use; whole-number data never gets fractional steps.
List<num> statsAxisTicks(List<num> values) {
  final maximum = values.isEmpty ? 0 : values.reduce(math.max);
  final whole = values.every((value) => value == value.roundToDouble());
  if (maximum <= 0) return const [0, 1];
  final rough = maximum / 5;
  final magnitude =
      math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
  final normalized = rough / magnitude;
  var step = (normalized <= 1
          ? 1
          : normalized <= 2
              ? 2
              : normalized <= 5
                  ? 5
                  : 10) *
      magnitude;
  if (whole && step < 1) step = 1;
  final top = (maximum / step).ceil() * step;
  final wholeSteps = step == step.roundToDouble();
  return [
    for (var tick = 0.0; tick <= top + step / 2; tick += step)
      wholeSteps ? tick.round() : tick
  ];
}

class _ScrollingPlot extends StatelessWidget {
  const _ScrollingPlot({
    required this.count,
    required this.labels,
    required this.tooltips,
    required this.ticks,
    required this.tickLabel,
    required this.painter,
  });
  final int count;
  final List<String> labels;
  final List<String> tooltips;
  final List<num> ticks;
  final String Function(num value) tickLabel;
  final CustomPainter Function(Color gridColor) painter;

  static const _axisWidth = 72.0;

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 350,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // The value axis stays in place while wide charts scroll.
        SizedBox(
            width: _axisWidth,
            child: Column(children: [
              Expanded(
                  child: LayoutBuilder(
                      builder: (context, axis) => Stack(children: [
                            for (var i = 0; i < ticks.length; i++)
                              Positioned(
                                  right: 6,
                                  top: axis.maxHeight *
                                          (1 - i / (ticks.length - 1)) -
                                      7,
                                  child: Text(tickLabel(ticks[i]),
                                      style: const TextStyle(fontSize: 11))),
                          ]))),
              const SizedBox(height: 50),
            ])),
        Expanded(child: _plot(context)),
      ]));

  Widget _plot(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, count * 54.0);
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
                width: width,
                child: Column(children: [
                  Expanded(
                      child: Stack(children: [
                    Positioned.fill(
                        child: CustomPaint(
                            painter: painter(appPalette(context).divider))),
                    Positioned.fill(
                        child: Row(children: [
                      for (final tooltip in tooltips)
                        Expanded(
                            child: Tooltip(
                                message: tooltip,
                                child: const SizedBox.expand()))
                    ])),
                  ])),
                  SizedBox(
                      height: 50,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final label in labels)
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(label,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              const TextStyle(fontSize: 11))))
                          ])),
                ])));
      });
}

/// Bars take 80 % of their slot, at most 160 px, centred in it.
double _barWidth(double step) => math.min(step * .8, 160);

double _barLeft(int index, double step) =>
    index * step + (step - _barWidth(step)) / 2;

/// Lines at each tick and between category slots, as in the reference.
void _paintGrid(
    Canvas canvas, Size size, Color color, List<num> ticks, int slots) {
  final grid = Paint()
    ..color = color
    ..strokeWidth = 1;
  for (var i = 0; i < ticks.length; i++) {
    final y = size.height * (1 - i / (ticks.length - 1));
    canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
  }
  for (var i = 0; i <= slots; i++) {
    final x = size.width * i / slots;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
  }
}

class _SeriesPainter extends CustomPainter {
  const _SeriesPainter(
      {required this.ticks,
      required this.values,
      required this.accent,
      required this.area,
      required this.gridColor});
  final List<num> ticks;
  final List<num> values;
  final Color accent;
  final bool area;
  final Color gridColor;
  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size, gridColor, ticks, values.length);
    final maximum = ticks.last;
    final step = size.width / values.length;
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset((i + .5) * step,
            size.height * (1 - values[i] / (maximum > 0 ? maximum : 1)))
    ];
    if (area) {
      final path = Path()..moveTo(points.first.dx, size.height);
      for (final point in points) {
        path.lineTo(point.dx, point.dy);
      }
      path
        ..lineTo(points.last.dx, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = accent.withValues(alpha: .45));
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
          line,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      for (final point in points) {
        canvas.drawCircle(point, 3, Paint()..color = accent);
      }
    } else {
      for (var i = 0; i < points.length; i++) {
        final left = _barLeft(i, step);
        canvas.drawRect(
            Rect.fromLTRB(
                left, points[i].dy, left + _barWidth(step), size.height),
            Paint()..color = accent.withValues(alpha: .65));
      }
    }
  }

  @override
  bool shouldRepaint(_SeriesPainter old) =>
      !listEquals(values, old.values) ||
      !listEquals(ticks, old.ticks) ||
      accent != old.accent ||
      area != old.area ||
      gridColor != old.gridColor;
}

class _StackedPainter extends CustomPainter {
  const _StackedPainter(
      {required this.ticks,
      required this.bars,
      required this.colors,
      required this.gridColor});
  final List<num> ticks;
  final List<List<num>> bars;
  final List<Color> colors;
  final Color gridColor;
  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size, gridColor, ticks, bars.length);
    final maximum = ticks.last;
    final step = size.width / bars.length;
    for (var i = 0; i < bars.length; i++) {
      var bottom = size.height;
      for (var s = 0; s < bars[i].length; s++) {
        final height = size.height * bars[i][s] / maximum;
        if (height <= 0) continue;
        final left = _barLeft(i, step);
        canvas.drawRect(
            Rect.fromLTRB(
                left, bottom - height, left + _barWidth(step), bottom),
            Paint()..color = colors[s]);
        bottom -= height;
      }
    }
  }

  @override
  bool shouldRepaint(_StackedPainter old) =>
      bars.length != old.bars.length ||
      !listEquals(ticks, old.ticks) ||
      !listEquals(colors, old.colors) ||
      gridColor != old.gridColor ||
      [for (var i = 0; i < bars.length; i++) !listEquals(bars[i], old.bars[i])]
          .any((changed) => changed);
}
