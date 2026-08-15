# Responsive Layout

- Compact width: single-column cards and bottom navigation where useful.
- Medium width: two-column home/catalog and centered gameplay board.
- Expanded width: navigation rail with content constrained to readable width.
- Landscape: board and controls may sit side by side when controls retain 48-pixel targets.
- Foldables: avoid placing primary controls across a display feature; consume Flutter display-feature information when hardware testing becomes available.

No screen assumes a fixed phone height. Scroll containers wrap long content, safe areas protect cutouts, and boards size from the smaller available axis.
