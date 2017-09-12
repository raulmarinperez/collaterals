**External commands integration within NiFi flows**
=======
*Web scraping with NiFi and Scrapy via the ExecuteProcess processor*
-------
### Introduction and motivation
Web scraping is a technique used often times to extract data from websites for further processing. Many use cases  involve data extraction from web sites as a prerequisite; the following are some examples:

 - Data mining
 - Online price change monitoring and price comparison
 - Website change detection
 - Web data integration

Web scraping presents many challenges, and the complexity of the process to extract data from websites depends on the complexity of the website itself (ie. website structure, client-side frameworks, etcetera).

I tend to think of web scraping as a three-stage process:

 1. Fetching and extracting web pages containing relevant data. This step is also known as web crawling.
 2. Raw data refinement, which is all about parsing, filtering, formatting and enriching the data extracted previously. More often than not, the goal of this step is to give some format to semi-structured data coming from websites.
 3. Outcome dispatching. Based on what I’ve seen in the field, there are two typical ways of dealing with results obtained from the previous step: (1) consolidation and (2) real-time processing.
The first option is the most extended, and it allows interactive access and batch processing on top of the consolidated data. Real-time processing on extracted web data, in the other hand, is not so common as these use cases presume data acquisition from well-defined REST APIs, which it’s not the case. 

There are many powerful and production ready open source web scrapers out there, and all of them excel at stages #1 and #2. However, most of them lack of facilities for “outcome dispatching”. Not to mention that they are not meant to be part of enterprise class architectures where security and governance are a must. Here it’s where **Apache NiFi** comes to the rescue, complementing open source web scrapers to bring a solid web scraping open source and enterprise class solution.

### Scrapy 1.4
Scrapy claims to be an “open source and collaborative framework for extracting the data you need from websites in a fast, simple, yet extensible way”. Scrapy is a Python framework easy to install via pip, and it comes with a set of command line tools which are useful for developing and debugging.

Don’t worry if you’ve never used Scrapy, its [documentation](https://docs.scrapy.org/en/latest/index.html) is very well-written and it has an [101 tutorial](https://docs.scrapy.org/en/latest/intro/tutorial.html) to get familiarized very quickly.
### Collecting Air Quality of main European cities
In this tutorial I’ll show you how to extract air quality data from the [“Air Quality in Europe” web site](https://www.airqualitynow.eu). Unfortunately there is not a REST API available to easily pull that data out, and data has to be extracted directly from the [“Current situation” page](https://www.airqualitynow.eu/comparing_home.php) or [RSS feeds](https://www.airqualitynow.eu/rss.php):


![pic1](img/Air%20Quality%20in%20Europe%20web%20site.png)

<center><small>***Current situation page. Cities are grouped by country.***</small></center>

![pic2](img/RSS%20feed.png)

<center><small>***Current situation page. Cities are grouped by country.***</small></center>

Both resources are valid to extract the data we need, though I’ll use the first one as it gives us the information grouped by country, which will make processing easier afterwards. The “Current situation” page is going to be parsed and processed once an hour and, as a result, there will be a JSON document per city with the following schema:

```
{ country: <country_name>,
  city: <city_name>,
  roadside_idx:  <value>,
  background_idx: <value>,
  date: <yyyyMMdd>,
  hour: <0-23> }
```


