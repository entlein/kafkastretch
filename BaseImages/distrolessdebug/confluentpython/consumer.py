#!/usr/bin/env python
#
# Copyright 2016 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Example high-level Kafka 0.9 balanced Consumer
#
from confluent_kafka import Consumer, KafkaException
#from prometheus_client import start_http_server, Summary, Metric
import sys
import getopt
import json
import logging
import settings
import topiccontrol
import numpy as np
from pprint import pformat


class CONS(topiccontrol.TOPIC):
    def __init__(self,target_boot, target_name, target_partitions, target_rep):
        super().__init__(target_boot, target_name, target_partitions, target_rep)
        print(self.boot)

    #s = Summary('confluent_python_proc_time', 'Time spent processing request')
    #s.observe()
    def stats_cb(self, stats_json_str):
        stats_json = json.loads(stats_json_str)
        print('\nKAFKA Stats: {}\n'.format(pformat(stats_json)))  

    def my_consumer(self):
        conf = {'bootstrap.servers': self.boot, 'group.id': "0", 'session.timeout.ms': 6000,
            'auto.offset.reset': 'earliest'}
        topics = [self.name]
        # Consumer configuration
        # See https://github.com/edenhill/librdkafka/blob/master/CONFIGURATION.md

        conf['stats_cb'] = self.stats_cb
       # conf['statistics.interval.ms'] = int(1000)

    # Create logger for consumer (logs will be emitted when poll() is called)
        logger = logging.getLogger('consumer')
        logger.setLevel(logging.DEBUG)
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter('%(asctime)-15s %(levelname)-8s %(message)s'))
        logger.addHandler(handler)

        # Create Consumer instance
        # Hint: try debug='fetch' to generate some log messages
        c = Consumer(conf, logger=logger)

        def print_assignment(consumer, partitions):
            print('Assignment:', partitions)

        # Subscribe to topics
        c.subscribe(topics, on_assign=print_assignment)

        # Read messages from Kafka, print to stdout
        res = 0
        mysum = 0
        mycount= np.zeros((self.partitions))
        try:
            #while res <=  1000000 :
            while True:
                msg = c.poll(timeout=1.0)
                if msg is None:
                    if res <  1000000 :
                        continue
                if msg.error():
                    raise KafkaException(msg.error())
                else:
                    # Proper messages
                    res= res + 1
                    mycount[msg.partition()]=msg.offset()
                    mysum=np.sum(mycount)
                    sys.stdout.write('%% %s [%d] at offset %d with res %d, mysum= %d: %s\n' %
                    (msg.topic(), msg.partition(), msg.offset(),
                     res, mysum, str(msg.value())))

       
        except KeyboardInterrupt:
            sys.stderr.write(mycount[0], mycount[1], mycount[2],mysum,res)
            sys.stderr.write('%% Aborted by user\n')

        finally:
            # Close down consumer to commit final offsets.
            c.close()
            ret= "Count= " + str(res) +" Total consumed= "+ str(mysum) + "\n"
            return ret
            # will print how many messages it has consumed 
            


#if __name__ == '__main__':
#  # Usage: json_exporter.py port endpoint
#  start_http_server(8000)
#  c=CONS("10.1.2.66:9092","cr_test_topic",3,3)
#  c.my_consumer()
  
        