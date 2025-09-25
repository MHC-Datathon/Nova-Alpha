## Statistical Testing Info

The goal in this notebook was to run a statistical test on violations per bus stop & poverty rates. Specifically, an ANOVA test to find a significant difference between grouped poverty rates by ZIP, and violations spatially harmonized by ZIP.

> [!NOTE]
>  Throughout the notebook, Violation and Ticket are used interchangeably. Both terms refer to a violation reported on a vehicle given by the ACE system.


The key question to answer:

- Is there a correlation between ticket counts and low-income areas?

To uncover this key question, there were several steps that preceded conducting statistical tests. The main issues stemmed from the two datasets, poverty rates and ACE violations, not being spatially harmonized. This prevents us from conducting statistical analysis from a common unit of measurement.

Therefore, the first step was to assign the corresponding ZIP code to each bus stop coordinate. Since we are provided with multipolygon coordinates of ZIP codes, we can assign the ZIP codes that each bus stop fall into by finding where the point coordinate of each bus stop falls inside the multipolygon coordinate.

Once our two datasets had a common column, we could now aggregate by ZIP codes to find the average violations issued and poverty rates for each one. The only thing left was to create buckets for the average poverty rates, since ANOVA tests require categorical variables to test their significant differences.

To put poverty rates per ZIP codes into buckets, I sorted the average rates greatest to least, and then took percentiles to create high, medium, and low poverty rates. With these buckets created, it was time to test for significant differences.

With the ANOVA test deeming one of the groups significantly different than the others, I used Tukey's Post-Hoc test to find that the high poverty group is significantly different than its counterparts. After checking each group's violation means, I found that the high poverty group is getting significantly higher violations than medium or low poverty areas.

<br>

As you follow along the notebook, there are denoted comments that give context to code lines/blocks.