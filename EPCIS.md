# Mapping between EPCIS Events and port call events

The [GS1 EPCIS standard](https://www.gs1.org/epcis) covers event exchanges in the logistics sector.
Specifically, this specification has overlap with EPCIS 1.2 Section 7.4: the event types module.

The port call event format does not use the EPCIS event format, because the format is not designed to handle **estimated** events. 
It can only describe **actual** events, such as captured by a barcode or NFC scanner, or as emitted by the AIS transponder of a ship.
A port call *actual* event can always be translated to a EPCIS event and vice-versa.
If in a future EPCIS standard estimate events will be accommodated, in this case port call event can be translated 1 on 1 to EPCIS events and vice-versa.

| Definition              | EPCISEvent path       | Port Call Event path |
| ----------------------- | ----------------------|----------------------|
| WHAT                    | `/epcList`            | `/ship`              |
| WHEN                    | `/eventTime`, `/eventTimeZoneOffset` | `/eventTime`         |
| WHERE                   | `/bizLocation`        | `/location`          |
| WHY                     | `/bizStep`, `/action` | `/eventType`, `/context` | 
| Event Id                | `/eventID`            | `/uuid`              |
| Record time             | `/recordTime`         | `/recordTime`        |


#### WHAT, Event subject

Within the port call optimisation project, the what dimension is always a ship identified by an IMO or ENI number and/or MMSI.
Within EPCIS, a list of identifiers in URN format.

The following private URN's are currently used:

```
urn:x-imo:<IMO number>
urn:x-eni:<ENI number>
urn:x-mmsi:<MMSI number>
```

Note: GS1 [is currently working on incorporating IMO numbers into the EPC namespace](https://www.gs1.org/sites/default/files/gs1standards_in-maritime.pdf).
When this is complete, this namespace is preferred.

#### WHEN, Event Time

The event time definition in port call events is compatible with the EPCIS definition.

The ISO8601 format is slightly different, EPCIS and NPIS specify `YYYY-MM-DDThh:mm:ssZ`, while port call uses `YYYY-MM-DDThh:mm:ssTZD` (which allows non GMT timezones)

This will likely be changed in a future version of the port call event format.

#### WHY, Event business context

EPCIS requires businesses to create a common business vocabulary (CVB).
GS1 is currently creating this CVB based on NPIS.
In the mean time, port call encodes event types in the `x-port-call` URN scheme:

`urn:x-port-call:<eventType>`, for example `urn:x-port-call:berth.eta.vessel`

Fields in an `context` should be added as fields to the Event when converting to EPCIS.

#### Other fields

##### Event ID

The EPCIS and port call definition of event id is identical. EPCIS encodes UUID's in the `uuid` URN namespace, while pronto only uses the UUID itself.

##### Record time

The EPCIS and port call definition of event record time is identical. See event time for a note on the ISO8601 format used.
