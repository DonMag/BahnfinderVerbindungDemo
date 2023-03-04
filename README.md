# BahnfinderVerbindungDemo

When run, app will look like this:

![Screen Shot 2023-03-04 at 00 26 26](https://user-images.githubusercontent.com/9865951/222877685-96b86ac8-ba05-4384-b0e0-2dcd799383b1.png)

We can set a specific "Query Date / Time" so we can get "Live Delays"

When viewing a "Live" query, there will be a "Save" button on the navigation bar to save the current query results. I did this to make it easier in development ... we can use the "Last Saved" data so we get the same output each time. Makes it easier to confirm that values are being set correctly. 

It is rarely, if ever, a good idea to add/remove subviews inside `cellForRowAt`. Instead, add the UI elements to the cell class and show/hide them as needed. For complex cells, split them out into multiple cell classes.

So, we created 5 cell classes:

![Screen Shot 2023-03-04 at 00 31 37](https://user-images.githubusercontent.com/9865951/222877918-e41a81a3-0106-4de4-be59-8488e1e16812.png)

- `BahnfinderDepartureCell`
  - this will always be the FIRST Row in the table
- `BahnfinderArrivalCell`
  - this will always be the LAST Row in the table
- `BahnfinderConnectionCell`
  - this cell has "Top" and "Bottom" times and "bracket" line views
- `BahnfinderWalkCell`
  - the "Individual Leg" cell
- `BahnfinderDetailCell`
  - this cell has the "Intermediate Stops" table

The yellow "spacer" cells are not used at run-time... I added them to make it easier to separate the cells while working on them in Storyboard.

In `cellForRowAt` I tried to arrange the code logically... so the first thing is to determine what "type" of row is needed:

		var rowType: RowType = .detail
		
		// let's first figure out which type of row we're on
		if indexPath.row % 2 == 0 {
			if indexPath.row == 0 {
				rowType = .departure
			} else if arrayIndex == resultLegArray[selectedIndex][0].count {
				rowType = .arrival
			} else {
				rowType = .connection
			}
		}

then we use `if rowType ==` blocks to dequeue the correct cell class and fill the data.



  
