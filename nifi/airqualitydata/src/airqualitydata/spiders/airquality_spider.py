import scrapy
import re

class AQSpider(scrapy.Spider):
    name = "airqualitydata"
    start_urls = [ 'https://www.airqualitynow.eu/comparing_home.php' ]

    def build_datadoc (self, country, row, str_date, str_hour):
       
       return { 'country': country,
                'city': row.xpath("./td[@class='city_bkg1' or @class='city_bkg2']/a/text()").extract_first(),
                'roadside_idx': row.xpath("./td[5]/text()").extract_first(),
                'background_idx': row.xpath("./td[9]/text()").extract_first(),
                'date': str_date,
                'hour': str_hour }

    def parse(self, response):
       country = None

       # 1. Extracting relevant sections from the page
       currentdate = response.xpath("/html/body/div/table[3]/tr/td/table[2]/tr/td[3]/table/tr[2]/td[4]/span/strong/text()").extract_first()
       tablerows = response.xpath("//*[@id='results']/tr")
       # 2. Format date accordingly to our requirements
       parsed_currentdate = re.search('([0-9]{2})/([0-9]{2})/([0-9]{4}) ([0-9]{2}):([0-9]{2})',currentdate)
       str_date = "%s%s%s" % (parsed_currentdate.group(3),parsed_currentdate.group(1),parsed_currentdate.group(2))
       str_hour = parsed_currentdate.group(4)
       # 3. Row by row processing; only relevant data yielded
       for row in tablerows:
          class_attr = row.xpath('@class').extract_first()
          # 2.1 Only processing useful data (first rows skipped)
          if country != None or class_attr != None:
             if class_attr != None:   # A new country starts
                country = row.xpath("./td/text()").extract_first()
                self.log("Start processing a new country: %s" % country)
             else:   # Extract city info
                 yield self.build_datadoc(country, row, str_date, str_hour)
