import confluent_kafka.admin
import settings
import confluent_kafka
import concurrent.futures
from confluent_kafka.admin import AdminClient, NewTopic, NewPartitions, ConfigResource


class TOPIC():
    def __init__(self, target_boot, target_name, target_partitions, target_rep):
        self.boot      =   target_boot
        self.name      =   target_name
        self.partitions=   int(target_partitions)
        self.rep       =   int(target_rep)
        #super().__init__(target_boot,target_name,target_partitions, target_rep)
        conf = {'bootstrap.servers': self.boot}
        self.kafka_admin =confluent_kafka.admin.AdminClient(conf)
    

    def create(self):
        topic_list = []
        new_topic   = confluent_kafka.admin.NewTopic(self.name, num_partitions=self.partitions, replication_factor=self.rep)
        topic_list.append(new_topic)
        futuretopic= self.kafka_admin.create_topics(new_topics=topic_list)
        for topic, f in futuretopic.items():
            try:
                f.result()
                print("Topic {} created".format(topic))
                res = format(topic)
            except Exception as e:
                print("Failed to create Topic {}: {}".format(topic,e))
                res= format(e)
        return res


    def list_my_topic(self):
        res = ""
        current_list = self.kafka_admin.list_topics().topics
        for f in current_list.items():
            try:
                res = res + format(f) + '\n'
            except Exception as e:
                res= res + "bad" + format(e)
        return res

     
    def describe_my_topic(self):
        config_response="" 
        topic_configResource = self.kafka_admin.describe_configs([ConfigResource(confluent_kafka.admin.RESOURCE_TOPIC, self.name)])
        for j in concurrent.futures.as_completed(iter(topic_configResource.values())):
            config_response = j.result(timeout=1)
            res= format(config_response)
            print(res)
        return res


    def delete_my_topic(self):
        to_delete=[]
        to_delete.append(self.name)
        futuretopic= self.kafka_admin.delete_topics(to_delete)
        for topic, f in futuretopic.items():
            try:
                f.result()
                print("Topic {} deleted".format(topic))
                res = format(topic)
            except Exception as e:
                print("Failed to delete Topic {}: {}".format(topic,e))
                res= format(e)
        return res