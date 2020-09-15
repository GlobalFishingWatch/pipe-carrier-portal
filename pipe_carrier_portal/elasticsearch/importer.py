"""Short script to imports vessel information into elastic search."""

import sys
import datetime as dt
import json
import elasticsearch
import elasticsearch.helpers


# Configuration options
server_url = sys.argv[1]
index_name = sys.argv[2]
index_schema = sys.argv[3]

# Derived configuration options
timestamp = dt.datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
unique_index_name = f"{index_name}-{timestamp}"

# Open a base http connection to elasticsearch server
server = elasticsearch.Elasticsearch(server_url)

# Get where the current alias is pointing to later remove old indices
try:
    print("Obtaining alias information for the current index")
    alias_info = server.indices.get_alias(name=index_name)
    old_indices = alias_info.keys()
    print(f"The alias is currently pointing to {old_indices}")
except Exception as e:
    print("The alias is not currently pointing at anything")
    old_indices = {}

# Precreate the index so that we can setup proper mappings
print(f"Creating index {unique_index_name}")
server.indices.create(unique_index_name, body=index_schema)

# Use the bulk helper to load all the data into ES
def line_to_elasticsearch_document(line):
    record = json.loads(line)
    return {
        "_id": record.get("vesselId"),
        "_source": record,
    }


try:
    print(f"Loading bulk data into index {unique_index_name}")
    bulk_actions = map(line_to_elasticsearch_document, iter(sys.stdin))
    elasticsearch.helpers.bulk(server, bulk_actions, index=unique_index_name)

    # Update the alias to point to the new index
    print(f"Updating index alias to the new index {unique_index_name}")
    server.indices.put_alias(unique_index_name, index_name)
except Exception as e:
    print(f"Exception while importing records to elastic search. {e}")
    print(f"Removing new index {unique_index_name} as the import process failed")

    server.indices.delete(unique_index_name)
    raise

# Remove the old indices
print(f"Removing old indices {old_indices}")
for old_index in old_indices:
    server.indices.delete(old_index)
