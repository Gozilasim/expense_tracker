# `lib/ui` Directory Guide

This directory contains screens and UI components.

## File Responsibilities

- `home_screen.dart`
  - Home screen
  - Date filtering
  - Category filtering
  - Expense list
  - Pie chart and total display

- `add_expense_screen.dart`
  - Add a new expense
  - Edit an existing expense
  - Delete a single expense

- `category_manager_screen.dart`
  - Category management
  - Data backup
  - Data restore

- `category_pie_chart.dart`
  - Category spending pie chart
  - Toggle between total spending and daily average

- `category_summary_bar.dart`
  - Category summary bar
  - Not currently used directly on the home screen; can be treated as a spare component

## Current Interaction Notes

- The home screen supports `Month`, `Year`, and `Custom` filter modes.
- The expense list supports swipe-to-delete.
- Category chips can be tapped to filter and tapped again to clear the filter.
- Editing an expense pre-fills amount, category, date, and note.
- The category management screen supports exporting `db.sqlite` and restoring from a file.

## Maintenance Notes

- Some screen files already carry multiple responsibilities; consider extracting the filter bar, list items, and category filter row into separate widgets.
- `home_screen.dart` holds a fair amount of presentation and state logic already, so it should be split before further expansion.
- Database restore is a high-risk action; later improvements could include file validation, format checks, and clearer success handling.
