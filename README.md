aws_summarizer
==============

Amazon AWS monthly billing report summarizer.

Uses Amazon's detailed monthly csv billing file as input.

Generates a summary including:
 - Counts the unique types of EC2 instances and their description
 - Total cost by day, by tag. (i.e. on March 3rd, Environment = Production cost $100.00)
 - Instances that changed tags during the month, and the timestamps when and how they changed.

Installation
==============
This app has been tested and runs on MRI `ruby-2.1.0`. It will probably work on older versions but this has not been tested.

```
git clone git@github.com:michaelirey/aws_summarizer.git
cd aws_summarizer
bundle
```

Usage
==============
```
ruby ./summarizer.rb <file_name>
```


Design Notes
==============
First thought was to load all the data into some kind of database, so the data would be easier to work with. However, this has a couple drawbacks. First, it creates a dependency in order to use this program. The other drawback is performance. The data has to be extracted from the CSV file. So reading it from the input file, writing it to a database, then reading it back again has overhead that could be avoided. Conclusion - no database is used to generate the summary.

This application is broken into logical parts (classes):
 - BillingLineItem - Represents a single row in the CSV
 - BillingHour - A collection of relevant data for each hour, since the CSV is hour by hour.
 - BillingDay - A collection of BillingHours which helps facilitate the daily summary.
 - TagChanges - Used to detect instances which change tags through out the month.
 - ReportHelper - General helper class which handles determining new days, hours, etc...
 - Analyzer - The main workhorse, which process the CSV file line by line.


Additional Notes
==============
Unique instances are determined by 'UsageType' which starts with 'BoxUsage'.

When grouping by tags for the given day, resources without tags are not included in the summary report.

When detecting if a resource has changed tags the following assumptions were made:
 - The 'ResourceId' is used as the key to match against corresponding tag values.
 - Sometimes non-unique 'ResouceId' values will be present in the same hour, or future hours. So a tag is NOT considered changed if any tags were changed and all the new tag values are not present.

This is app is optimized for time not space.

Big-O notation: 
Not quite sure if this is exactly correct but I believe it is O(n^3)
Where the time complexity will increase by a cube of 3 when each instance, tag, and tag values are all increased.

 - Best Case: 1 instance, 1 tag, 1 tag value. If only one of these 3 values increases this would be O(n)
 - Worst Case: many instances, with many tags, and many non-unique tag values. If all three of these values increase this would be O(n^3)


Final Thoughts
==============
The above application will work fine for generating a summary for a single Amazon CSV file, or even a few. But what if you had several thousand, or hundred thousand files to process? What could be done to optimize efficiency of processing so many CSV files? A simple way would be to spin up a bunch of worker servers and split the work evenly between all of them. While this would work, there is a more efficient way to use available resources.

Think of an assembly line, where multiple workers wait for objects coming down the assembly line. Each worker performing a single task, preparing the item to be worked on the for the next worker down the line.

A similar approach could be used process an enormous amount Amazon CSV files more efficiently.

Here is an example of how this could be accomplished:

1. All unprocessed files would be placed in a 'unprocessed' queue.
2. The first set of workers will be regularly checking to see if there is any work in the queue for them
3. The first set of workers will be responsible for:
 - Generating a unique identifier for each 'unprocessed' file. (This will be user later)
 - Removing unneeded columns from the CSV
 - Removing unneeded rows from the CSV - (summary line items)
 - Gathering up tag headers
 - Detecting tag changes (since they will have the whole file open to work with)
 - Splitting the file into smaller chunks ( 1 day chunks )
 - Tagging each file with the unique identifier.
 - Placing the smaller (day files) into the next 'day' queue
4. The second set of workers will be regularly checking 'day' queue
5. The second set of workers would be responsible:
 - Processing the smaller day files and generating summaries for each day.
 - Place each processed file into the 'processed' queue
6. The third set of workers will be regularly checking 'processed' queue. However, this queue is a little different because they will need to wait until all days for a given report have been processed.
7. The third set of workers would be responsible for packaging up all the parts:
 - Combine all the daily reports in order (using unique identifier)
 - Add the changed tag report
 - Add the unique instance report


Note: For maximum optimization, you may need to run this a few times and fine tune the number of workers in each queue, identifying any bottlenecks. Workers could also dynamically created when there is work in the queue and all workers are currently busy. Likewise workers could be destroyed when there is no work in the queue for them.


There are other benefits of this assembly line strategy besides performance. All work is broken in to logic steps, because of this the application will be easier to maintain and adjust. Maintenance of the application no longer means impacting the whole process, so less chance for bug to cascade throughout the whole application (although not impossible). Also it may be possible for a new developer to work on a small piece of the puzzle without needing to know all the details of the big picture.






