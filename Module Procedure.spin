'' Module Startup Procedure


'' - Load network object
'' - Load EEPROM object
'' - Load the inputs and outputs table from EEPROM and check checksum, or fail
'' - Load the i/o table from EEPROM, along with the timestamp and check checksum for each entry, and that all elements in the outputs table are defined in the i/o table, or default to timestamp of 0
'' - For each input:
''      - Generate a random id, broadcast it, resolve any collisions
''      - Add an entry to the values cache table, if 

'' - Broadcast i/o table timestamp along with a random number, if a older ts is seen or if the same ts is seen with a higher random number, don't do anything
''      - Otherwise, if a younger ts is seen at all, begin to transmit the i/o table directly from eeprom
'' - If receiving i/o table, add those elements which are in the outputs table to the eeprom i/o table
'' - Reloat the eeprom i/o table into the local i/o table

'' - Parse the tokens in the i/o table, for each element:
''      - Resolve any input names into ids over the network, caching as appropriate
''      - For each input, add an entry to the value cache table, and send a network request for that value to be sent regularly

'' - Begin normal execution

'' Execution Procedure

'' Network Cog

'' - When a value is sent, add it, along with a TTL, to the value cache table
'' - When requested by another device, add a value to the value transmit table, to be sent out
'' - Respond to any request for name resolution for names which exist in the inputs table, with that inputs id
'' - Take any network broadcast which resolves a name in the value cache table, and store the transmitted id in the value cache table, and replace those wntries in the i/o table which use that name, with the associated id

'' Ops Cog

'' - Remove old or expired entries from the tables
'' - Transmit values requested in the value transmit table which are significantly different from the last value transmitted

'' Input Cog

'' - Poll all local inputs, storing their values in the value cache table
'' - On failure, mark it as such in the value cache table, and the inputs table

'' Output Cog

'' - For each entry in both the i/o AND outputs tables, with each enty in the outputs table corrisponding to one-and-only-one entry in the i/o table:
''      - For each token:
''              - If it is a value id, attempt to resolve it against the value cache table, if the value doesn't exist, fail
''              - If it is an operation, complete it against the previous two entries (post-fix notation)
''      - Set the output to the result of the stack
''      - On failure, delete that entry in the i/o table, resulting in the next entry in the i/o table for that output being used next cycle, or fail, if no such output exists                             