from confluent_kafka import Producer
import string
import random
import settings
import topiccontrol
import numpy as np

#conf = {'bootstrap.servers': '10.1.2.35:9092'}
#conf = {'bootstrap.servers': settings.BOOTSTRAP_SERVER}
#p= Producer(conf)


class PROD(topiccontrol.TOPIC):
    def __init__(self,target_boot, target_name, target_partitions, target_rep):
        super().__init__(target_boot, target_name, target_partitions, target_rep)
        print(self.boot)
        

    def delivery_report(self, err, msg):
        """Called once per message """
        mc[msg.partition()]= mc[msg.partition()] + 1
        if err is not None:
            print('Msg delivery failed: {}'.format(err))
        else:
            print('Msg {} delivered to {} [{}], Total= {}'.format(
                msg.value(), msg.topic(), msg.partition(),np.sum(mc)))

    def randomstring(self, stringLength=10):
        letters = string.ascii_lowercase
        return ''.join(random.choice(letters) for i in range(stringLength))

    
    def my_producer(self):
        conf = {'bootstrap.servers': self.boot,'queue.buffering.max.messages': 1000000}
        p= Producer(conf)
        global mc 
        mc= np.zeros((self.partitions))
        for data in range(1,1000000):

            p.poll(0)
            p.produce( self.name , self.randomstring().encode('utf-8'),callback= self.delivery_report)
            
            
        p.flush()
        res= str(np.sum(mc))+"\n"
        return res
