import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
import 'package:collectarr_app/features/library/config/library_entry_helpers.dart'
    show formatMoney;
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

typedef LibraryEditResponsiveFieldsBuilder = Widget Function(
  List<Widget> children,
);

typedef LibraryEditFieldBuilder = Widget Function({
  required TextEditingController controller,
  required String label,
  String? hint,
  String? Function(String?)? validator,
});

typedef LibraryEditDatePickerFieldBuilder = Widget Function({
  required String label,
  required DateTime? value,
  required ValueChanged<DateTime?> onChanged,
});

class LibraryEditValueTab extends StatelessWidget {
  const LibraryEditValueTab({
    super.key,
    required this.accent,
    required this.buildResponsiveFields,
    required this.buildField,
    required this.buildDatePickerField,
    required this.priceController,
    required this.currencyController,
    required this.purchaseDateController,
    required this.purchaseStoreController,
    required this.marketValueController,
    required this.sellPriceController,
    required this.lastBagBoardDate,
    required this.onLastBagBoardDateChanged,
    this.isGameKind = false,
    this.gameCompleteness,
    this.onGameCompletenessChanged,
    this.gameHasBox = false,
    this.onGameHasBoxChanged,
    this.gameHasManual = false,
    this.onGameHasManualChanged,
    this.gamePriceChartingId,
    this.onGamePriceChartingIdChanged,
    this.gameCoreRegion,
    this.onGameCoreRegionChanged,
    this.gameValueIsLocked = false,
    this.onGameValueIsLockedChanged,
  });

  final Color accent;
  final LibraryEditResponsiveFieldsBuilder buildResponsiveFields;
  final LibraryEditFieldBuilder buildField;
  final LibraryEditDatePickerFieldBuilder buildDatePickerField;
  final TextEditingController priceController;
  final TextEditingController currencyController;
  final TextEditingController purchaseDateController;
  final TextEditingController purchaseStoreController;
  final TextEditingController marketValueController;
  final TextEditingController sellPriceController;
  final DateTime? lastBagBoardDate;
  final ValueChanged<DateTime?> onLastBagBoardDateChanged;
  final bool isGameKind;
  final String? gameCompleteness;
  final ValueChanged<String?>? onGameCompletenessChanged;
  final bool gameHasBox;
  final ValueChanged<bool>? onGameHasBoxChanged;
  final bool gameHasManual;
  final ValueChanged<bool>? onGameHasManualChanged;
  final String? gamePriceChartingId;
  final ValueChanged<String?>? onGamePriceChartingIdChanged;
  final String? gameCoreRegion;
  final ValueChanged<String?>? onGameCoreRegionChanged;
  final bool gameValueIsLocked;
  final ValueChanged<bool>? onGameValueIsLockedChanged;

  @override
  Widget build(BuildContext context) {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Purchase',
          accent: accent,
          child: Column(
            children: [
              buildResponsiveFields([
                buildField(
                  controller: priceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
                LibraryCurrencyField(controller: currencyController),
              ]),
              const SizedBox(height: 10),
              buildDatePickerField(
                label: 'Purchase date',
                value: parseDate(purchaseDateController.text),
                onChanged: (picked) {
                  purchaseDateController.text =
                      picked == null ? '' : formatDate(picked);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: purchaseStoreController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Store',
                  hintText: 'Where you bought it',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              buildField(
                controller: marketValueController,
                label: 'Estimated market value',
                validator: optionalMoneyValidator,
              ),
            ],
          ),
        ),
        EditSection(
          title: 'Collection',
          accent: accent,
          child: Column(
            children: [
              buildDatePickerField(
                label: 'Last bag & board date',
                value: lastBagBoardDate,
                onChanged: onLastBagBoardDateChanged,
              ),
              if (isGameKind) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: gameCompleteness,
                  isExpanded: true,
                  dropdownColor: appPalette(context).panelRaised,
                  borderRadius: kEditMenuBorderRadius,
                  decoration: const InputDecoration(
                    labelText: 'Completeness',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('CIB')),
                    DropdownMenuItem(value: 'na', child: Text('N/A')),
                    DropdownMenuItem(value: 'loose', child: Text('Loose')),
                    DropdownMenuItem(value: 'cib', child: Text('CIB')),
                    DropdownMenuItem(value: 'new', child: Text('New')),
                    DropdownMenuItem(value: 'graded', child: Text('Graded')),
                  ],
                  onChanged: onGameCompletenessChanged,
                ),
                const SizedBox(height: 10),
                buildResponsiveFields([
                  Material(
                    type: MaterialType.transparency,
                    child: CheckboxListTile(
                      value: gameHasBox,
                      onChanged: onGameHasBoxChanged == null
                          ? null
                          : (value) => onGameHasBoxChanged!(value ?? false),
                      dense: true,
                      title: const Text('Has box'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: CheckboxListTile(
                      value: gameHasManual,
                      onChanged: onGameHasManualChanged == null
                          ? null
                          : (value) => onGameHasManualChanged!(value ?? false),
                      dense: true,
                      title: const Text('Has manual'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                buildResponsiveFields([
                  TextFormField(
                    initialValue: gamePriceChartingId,
                    onChanged: onGamePriceChartingIdChanged,
                    decoration: const InputDecoration(
                      labelText: 'PriceCharting ID',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: gameCoreRegion,
                    isExpanded: true,
                    dropdownColor: appPalette(context).panelRaised,
                    borderRadius: kEditMenuBorderRadius,
                    decoration: const InputDecoration(
                      labelText: 'Core region',
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Auto')),
                      DropdownMenuItem(value: 'us', child: Text('US')),
                      DropdownMenuItem(value: 'eu', child: Text('EU')),
                    ],
                    onChanged: onGameCoreRegionChanged,
                  ),
                ]),
                const SizedBox(height: 10),
                Material(
                  type: MaterialType.transparency,
                  child: SwitchListTile(
                    value: gameValueIsLocked,
                    onChanged: onGameValueIsLockedChanged,
                    dense: true,
                    title: const Text('Lock value'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ],
          ),
        ),
        EditSection(
          title: 'Value summary',
          accent: accent,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ValueContextChip(
                icon: Icons.payments_outlined,
                label: 'Paid',
                value: priceController.text.isEmpty
                    ? '—'
                    : formatMoney(
                        parseMoneyCents(priceController.text),
                        currencyController.text,
                      ),
              ),
              ValueContextChip(
                icon: Icons.sell_outlined,
                label: 'Sell',
                value: sellPriceController.text.isEmpty
                    ? '—'
                    : formatMoney(
                        parseMoneyCents(sellPriceController.text),
                        currencyController.text,
                      ),
              ),
              ValueContextChip(
                icon: Icons.calendar_month_outlined,
                label: 'Purchased',
                value: purchaseDateController.text.isEmpty
                    ? '—'
                    : purchaseDateController.text,
              ),
              ValueContextChip(
                icon: Icons.trending_up_outlined,
                label: 'Manual estimate',
                value: marketValueController.text.isEmpty
                    ? '—'
                    : formatMoney(
                        parseMoneyCents(marketValueController.text),
                        currencyController.text,
                      ),
              ),
              ValueContextChip(
                icon: Icons.shield_outlined,
                label: 'Insurance',
                value: marketValueController.text.isEmpty &&
                        priceController.text.isEmpty
                    ? '—'
                    : formatMoney(
                        parseMoneyCents(marketValueController.text.isEmpty
                            ? priceController.text
                            : marketValueController.text),
                        currencyController.text,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildLibraryEditSoldTab({
  required BuildContext context,
  required Color accent,
  required LibraryEditResponsiveFieldsBuilder buildResponsiveFields,
  required LibraryEditFieldBuilder buildField,
  required LibraryEditDatePickerFieldBuilder buildDatePickerField,
  required DateTime? soldAt,
  required ValueChanged<bool> onSoldChanged,
  required ValueChanged<DateTime?> onSoldDateChanged,
  required TextEditingController sellPriceController,
  required TextEditingController soldToController,
  required TextEditingController priceController,
  required TextEditingController currencyController,
}) {
  return EditTabShell(
    children: [
      EditSection(
        title: 'Sold Status',
        accent: accent,
        child: Column(
          children: [
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                value: soldAt != null,
                onChanged: onSoldChanged,
                title: const Text('Mark as sold'),
                subtitle: soldAt != null
                    ? Text(
                        'Sold on ${formatDate(soldAt)}',
                        style: TextStyle(color: appPalette(context).textMuted),
                      )
                    : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (soldAt != null) ...[
              const SizedBox(height: 12),
              buildDatePickerField(
                label: 'Sold date',
                value: soldAt,
                onChanged: onSoldDateChanged,
              ),
              const SizedBox(height: 12),
              buildResponsiveFields([
                buildField(
                  controller: sellPriceController,
                  label: 'Sell price',
                  validator: optionalMoneyValidator,
                ),
                buildField(controller: soldToController, label: 'Sold to'),
              ]),
            ],
          ],
        ),
      ),
      if (soldAt != null)
        EditSection(
          title: 'Profit / Loss',
          accent: accent,
          child: SoldSummaryPanel(
            pricePaidCents: parseMoneyCents(priceController.text),
            sellPriceCents: parseMoneyCents(sellPriceController.text),
            currency: currencyController.text,
          ),
        ),
    ],
  );
}
