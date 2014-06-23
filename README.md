NSFetchedResultsController Stress Test
======================================

Subjects a fetched results controller (with table view) to a barrage of pseudo-random changes, testing if it's coped after each iteration.

The database consists of simple objects with a single property of a number, between 0 and 99. Those numbers are displayed in a table view, in ascending order. At each iteration, some of the numbers are changed. Optionally, new objects can be inserted, and existing ones deleted, too.

The controller can be configured to:

- filter results by a predicate (ignores numbers over 49)
- split objects up into sections (by first digit)

After an iteration, the controller's objects are tested. They should:

- Be in the right order
- Match up to performing a fresh fetch request
- Be in the correct sections
- Match up across `.fetchedObjects` and the contents of each section
- Sections should be self-consistent (http://mikeabdullah.net/nsfetchedresultscontroller.html)
- When sectioned, no section should be empty
- Visible table cells should match the controller's data

Most of the above can be configured by `#define`s at the top of `FSTMasterViewController.m`.
