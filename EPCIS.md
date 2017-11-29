# Mapping between EPCIS Events and Pronto events

The [GS1 EPCIS standard](https://www.gs1.org/epcis) covers event exchanges in the logistics sector.
Specifically, this specification has overlap with EPCIS 1.2 Section 7.4: the event types module.

The Pronto model does not use the EPCIS event format, because the format is not designed to handle **estimated** events. 
It can only describe **actual** events, such as captured by a barcode or NFC scanner, or as emitted by the AIS transponder of a ship.
A Pronto *actual* event can always be translated to a EPCIS event and vice-versa.
If in a future EPCIS standard estimate events will be accommodated, in this case Pronto event can be translated 1 on 1 to EPCIS events and vice-versa.

| Definition              | EPCISEvent path       | ProntoEvent path     |
| ----------------------- | ----------------------|----------------------|
| WHAT                    | `/epcList`            | `/ship`              |
| WHEN                    | `/eventTime`, `/eventTimeZoneOffset` | `/eventTime`         |
| WHERE                   | `/bizLocation`        | `/location`          |
| WHY                     | `/bizStep`, `/action` | `/eventType`, `/context` | 
| Event Id                | `/eventID`            | `/uuid`              |
| Record time             | `/recordTime`         | `/recordTime`        |


#### WHAT, Event subject

Within Pronto, the what dimension is always a ship identified by an IMO or ENI number and/or MMSI.
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

The event time definition in Pronto events is compatible with the EPCIS definition.

The ISO8601 format is slightly different, EPCIS and NPIS specify `YYYY-MM-DDThh:mm:ssZ`, while Pronto uses `YYYY-MM-DDThh:mm:ssTZD` (which allows non GMT timezones)

This will likely be changed in a future version of the pronto event spec.

#### WHERE, Event location

If a pronto event uses GLN's, it is compatible with EPCIS.
Currently not all ports have GLN's defined for their locations.

EPCIS uses the `sgln` URN namespace to encode a GLN and GLN Extension, while a Pronto event has two separate fields.

#### WHY, Event business context

EPCIS requires businesses to create a common business vocabulary (CVB).
GS1 is currently creating this CVB based on NPIS.
In the mean time, Pronto encodes event types in the `x-pronto` URN scheme:

`urn:x-pronto:<eventType>`, for example `urn:x-pronto:berth.eta.vessel`

Fields in an `context` should be added as fields to the Event when converting to EPCIS.

#### Other fields

##### Event ID

The EPCIS and Pronto definition of event id is identical. EPCIS encodes UUID's in the `uuid` URN namespace, while pronto only uses the UUID itself.

##### Record time

The EPCIS and Pronto definition of event record time is identical. See event time for a note on the ISO8601 format used.
