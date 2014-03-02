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


Notes
==============
Unique instances are determined by 'UsageType' which starts with 'BoxUsage'.

Resources without tags are not included in the summary report.

This is app is optimized for time not space.

Big-O notation:
 - Best Case: 
 - Worst Case: 
