import 'package:collectarr_app/features/library/edit/edit_dialog_widgets.dart';
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

Widget buildLibraryEditValueTab({
  required BuildContext context,
  required Color accent,
  required LibraryEditResponsiveFieldsBuilder buildResponsiveFields,
  required LibraryEditFieldBuilder buildField,
  required LibraryEditDatePickerFieldBuilder buildDatePickerField,
  required TextEditingController priceController,
  required TextEditingController currencyController,
  required TextEditingController purchaseDateController,
  required TextEditingController purchaseStoreController,
  required TextEditingController marketValueController,
  required TextEditingController sellPriceController,
  required VoidCallback onPickPurchaseDate,
  required String? collectionStatus,
  required ValueChanged<String?> onCollectionStatusChanged,
  required DateTime? lastBagBoardDate,
  required ValueChanged<DateTime?> onLastBagBoardDateChanged,
}) {
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
              buildField(controller: currencyController, label: 'Currency'),
            ]),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onPickPurchaseDate,
              icon: const Icon(Icons.event),
              label: Text(
                purchaseDateController.text.isEmpty
                    ? 'Set purchase date'
                    : 'Purchase date: ${purchaseDateController.text}',
              ),
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
        title: 'Collection status',
        accent: accent,
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: collectionStatus,
              isExpanded: true,
              dropdownColor: appPalette(context).panelRaised,
              borderRadius: kEditMenuBorderRadius,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('In collection')),
                DropdownMenuItem(value: 'for_sale', child: Text('For sale')),
                DropdownMenuItem(value: 'on_order', child: Text('On order')),
              ],
              onChanged: onCollectionStatusChanged,
            ),
            const SizedBox(height: 10),
            buildDatePickerField(
              label: 'Last bag & board date',
              value: lastBagBoardDate,
              onChanged: onLastBagBoardDateChanged,
            ),
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
                  : '\$${priceController.text}',
            ),
            ValueContextChip(
              icon: Icons.sell_outlined,
              label: 'Sell',
              value: sellPriceController.text.isEmpty
                  ? '—'
                  : '\$${sellPriceController.text}',
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
              label: 'Market value',
              value: marketValueController.text.isEmpty
                  ? '—'
              : '\$${marketValueController.text}',
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildLibraryEditSoldTab({
  required BuildContext context,
  required Color accent,
  required LibraryEditResponsiveFieldsBuilder buildResponsiveFields,
  required LibraryEditFieldBuilder buildField,
  required DateTime? soldAt,
  required ValueChanged<bool> onSoldChanged,
  required VoidCallback onPickSoldDate,
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
            SwitchListTile(
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
            if (soldAt != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onPickSoldDate,
                icon: const Icon(Icons.event),
                label: Text('Sold date: ${formatDate(soldAt)}'),
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