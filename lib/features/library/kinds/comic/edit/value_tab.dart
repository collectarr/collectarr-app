import 'package:collectarr_app/features/library/edit/fields/edit_layout_widgets.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_value_fields.dart';
import 'package:collectarr_app/features/library/edit/fields/edit_summary_widgets.dart';
import 'package:collectarr_app/features/library/ui/primitives/library_selection_fields.dart';
import 'package:collectarr_app/features/library/kinds/comic/edit/host.dart';
import 'package:collectarr_app/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

extension ComicValueTab on ComicEditHost {
  Widget buildComicValueTab() {
    return EditTabShell(
      children: [
        EditSection(
          title: 'Value',
          accent: comicAccent,
          child: Column(
            children: [
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicPriceController,
                  label: 'Price paid',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryCurrencyField(controller: comicCurrencyController),
                LibraryEditTextField(
                  controller: comicMarketValueController,
                  label: 'My value',
                  validator: optionalMoneyValidator,
                ),
              ]),
              const SizedBox(height: 10),
              LibraryEditResponsiveRow(children: [
                LibraryEditTextField(
                  controller: comicPurchaseStoreController,
                  label: 'Purchase store',
                ),
                LibraryDateFieldButton(
                  label: 'Purchase date',
                  value: parseDate(comicPurchaseDateController.text),
                  onChanged: (value) {
                    comicMutateState(() {
                      comicPurchaseDateController.text =
                          value == null ? '' : formatDate(value);
                    });
                  },
                ),
              ]),
              const SizedBox(height: 10),
              LibrarySwitchField(
                label: 'Mark as sold',
                value: comicSoldAt != null,
                onChanged: (value) {
                  comicMutateState(() {
                    comicSoldAt = value ? DateTime.now() : null;
                  });
                },
              ),
              if (comicSoldAt != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 4),
                    child: Text(
                      'Sold on ${formatDate(comicSoldAt!)}',
                      style: TextStyle(
                        color: appPalette(comicContext).textMuted,
                      ),
                    ),
                  ),
                ),
              if (comicSoldAt != null) ...[
                const SizedBox(height: 12),
                LibraryEditResponsiveRow(children: [
                  LibraryEditTextField(
                    controller: comicSellPriceController,
                    label: 'Price sold',
                    validator: optionalMoneyValidator,
                  ),
                  LibraryDateFieldButton(
                    label: 'Sold date',
                    value: comicSoldAt,
                    onChanged: (value) =>
                        comicMutateState(() => comicSoldAt = value),
                  ),
                  LibraryEditTextField(
                    controller: comicSoldToController,
                    label: 'Sold to',
                  ),
                ]),
                const SizedBox(height: 12),
                SoldSummaryPanel(
                  pricePaidCents: parseMoneyCents(comicPriceController.text),
                  sellPriceCents:
                      parseMoneyCents(comicSellPriceController.text),
                  currency: comicCurrencyController.text,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
