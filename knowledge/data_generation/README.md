# Data generation images
Here you'll find data generators I've found in the Internet that will help me 
to feed systems for demo purposes. My goal is to come up with a way of spining
up a data generator as quick as possible by simply providing some inputs.

I've chosen data generators that can be used for free; if you realize some
software over here is under a licence not allowing public sharing let me know
and I'll remove it.

As usual, Dockerfiles are self-descriptive and very verbose in order to help 
you understanding how the image is built and what's available for you 
afterwards. The following are the images available:

* **trucking_data_dim.-** Trucking Data Simulator publicly available in George 
Vetticaden's github repository: https://github.com/georgevetticaden/sam-trucking-data-utils

   When a container is built and is running, it generates and add events into
   a file and, if properly setup, those events are sent out of the container.