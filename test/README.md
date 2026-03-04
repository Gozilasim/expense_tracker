# `test` Directory Guide

This directory is intended for automated tests.

## Current Status

- The existing [widget_test.dart](widget_test.dart) is still the default Flutter counter test.
- It does not match the current expense tracker UI and is unlikely to reflect real application behavior.

## Tests Worth Adding First

- Verify that adding an expense writes to the database correctly
- Verify that editing an expense updates the record correctly
- Verify that deleting an expense works as expected
- Verify month, year, and custom date-range filtering
- Verify category add, edit, and delete flows
- Verify basic backup and restore behavior

## Recommended Direction

- Use unit tests first for pure data logic
- Use widget tests for screen interaction
- Consider integration tests for backup and restore flows
