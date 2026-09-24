# UI Readability and Contrast Plan

## Issues to investigate

The theme already has primitives under `lib/ui/theme/`, but some Library screens define local 12 px text, heavy font weights, and accent-colored text. Evaluate these combinations against their actual background: normal surfaces, selected surfaces, badges, buttons, and dialogs, in both light and dark themes. An animated accent can change contrast while the app is in use.

`library_text_theme.dart` still pins `libraryBody` to 13 px and `libraryMeta` / `libraryCaption` to 12 px. The repository also contains many local 10–12 px Library styles. Review those roles first; simply replacing local styles with the current tokens would preserve the same readability problem.

## Implementation sequence

1. Inventory small text and bold text on accent surfaces in Add/Edit, cards, inspector, filters, status indicators, and dialogs. Record the component, state, and effective colors, not just the values in source code.
2. Define reusable typography roles in `library_text_theme.dart`: body, label, secondary metadata, badge, and title. Avoid local values below the chosen minimum for functional text, and allow larger system text without clipping.
3. Centralize foreground color selection for accent and selected surfaces. Calculate contrast from the final foreground/background pair and choose a light or dark foreground for dynamic accents. Font weight does not compensate for insufficient contrast.
4. Extract small badge, field-label, and metadata-row widgets only where states, semantics, and accessibility rules match. Replace duplicate local styles gradually.
5. Review the main screens visually in both themes, with light and dark accents, at 100% and 150% text scale. Check focus, hover, selection, error, and disabled states.

## Completion criteria

- Functional text and controls meet the applicable WCAG AA contrast targets; decorative exceptions are identified explicitly.
- No label needed for an action becomes unreadable on a configurable accent color.
- Scaled text is not clipped in the main Add/Edit, workspace, and inspector flows.
- Replaced duplicate styles have consistent meaning and behavior wherever they are used.
