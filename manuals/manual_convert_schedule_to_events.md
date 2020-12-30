# Convert carrier schedule to port call events
We frequently receive the question from carriers how they can share their schedule with Pronto.

This manual contains instructions on how to do this.

## Example carrier schedule
A carrier schedule usually exists out of vessels and which harbours they visit and which times.<br />
In our example we will look at the route between two fictitious ports
 - Gilo with UNLOCODE `XXGIL`
 - Tilo with UNLOCODE `XXTIL`

Because our event model limits events to a single port we will focus the examples on two vessels which are headed towards the "Gilo" port.
Gilo consists of the following berths `Gilo 1`, `Gilo 2` and `Gilo 3`.

At 2018-01-01 14:00 the latest schedule for the carrier "Carrier X" as kept in their carrier schedule system is as follows:
### 
| ID       | Port call             | Previous port | Port  | Vessel name | IMO     | Arrival Port     | Arrival Pilot Boarding Place | Departure Port   | Events                                                                                                                         |
|----------|-----------------------|---------------|-------|-------------|---------|------------------|------------------------------|------------------|--------------------------------------------------------------------------------------------------------------------------------|
| 077b9b08 | XXGIL18000495         | XXTIL         | XXGIL | BUKHA       | 9500936 | 2018-01-03 17:00 | 2018-01-03 18:00             | 2018-01-04 09:00 | [ETA Port](#077b9b08-eta-port), [ETA Pilot Boarding Place](#077b9b08-eta-pilot-boarding-place), [ETD Port](#077b9b08-etd-port) |
| f0b2426f | PID-CarrierX-f0b2426f | XXTIL         | XXGIL | PENELOPE    | 9402914 | 2018-01-05 19:00 |                              | 2018-01-08 17:00 | [ETA Port](#f0b2426f-eta-port), [ETD Port](#f0b2426f-etd-port)                                                                 |

ID: Your internal unique, non-reused ID for the visit <br />
Port call: A unique identifier that could be either assigned to a port call by the Port Authority or one specific to your organisation.<br />
Previous port: The previous port from which the ship will sail to the port<br /> 
Port: The port which the ship will visit<br />
Vessel name: Name of the vessel which the visit is about <br />
IMO: IMO number of the vessel (ENI and MMSI are also supported) <br />
Timestamps: The Carrier Schedule System keeps 4 timestamps for a visit to a port: Arrival Port, Arrival Pilot Boarding Place, Departure Pilot Boarding Place and Departure Port.<br />
Additionally each timestamp is marked as an estimate until it is confirmed by an operator to have happend.

**Note**: *For our harbour the PENELOPE has an pilotage exception certificate thus there is no need to provide pilot boarding place events.*

##### Detail view 077b9b08
| ID        | Port call     | Vessel name | IMO     | Berth  | Arrival Berth    | Departure Berth  | Events                                                               |
|-----------|---------------|-------------|---------|--------|------------------|------------------|----------------------------------------------------------------------|
| 077b9b081 | XXGIL18000495 | BUKHA       | 9500936 | Gilo 1 | 2018-01-03 20:00 | 2018-01-04 07:00 | [ETA Berth](#077b9b081-eta-berth), [ETD Berth](#077b9b081-etd-berth) |

##### Detail view f0b2426f
| ID        | Port call             | Vessel name | IMO     | Berth  | Arrival Berth    | Departure Berth  | Events                                                               |
|-----------|-----------------------|-------------|---------|--------|------------------|------------------|----------------------------------------------------------------------|
| f0b2426f1 | PID-CarrierX-f0b2426f | PENELOPE    | 9402914 | Gilo 3 | 2018-01-05 21:00 | 2018-01-06 19:00 | [ETA Berth](#f0b2426f1-eta-berth), [ETD Berth](#f0b2426f1-etd-berth) |
| f0b2426f2 | PID-CarrierX-f0b2426f | PENELOPE    | 9402914 | Gilo 2 | 2018-01-06 20:00 | 2018-01-08 15:00 | [ETA Berth](#f0b2426f2-eta-berth), [ETD Berth](#f0b2426f2-etd-berth) |

ID: Your internal unique, non-reused ID for the berth visit <br />
Port call: A unique identifier that could be either assigned to a port call by the Port Authority or a generated <br />
Port: The port which the ship will visit<br />
Vessel name: Name of the vessel which the visit is about <br />
IMO: IMO number of the vessel (ENI and MMSI are also supported) <br />
Berth: The berth the vessel will visit <br />
Timestamps: The Carrier Schedule System keeps 2 timestamps for a visit to a berth: Arrival Berth  and Departure Berth.<br />
Additionally each timestamp is marked as an estimate until it is confirmed by an operator to have happend.<br />

## Sending events
In order to share the schedule with other partier the carrier should convert the schedule into events.
If we want to send the ETA Port for visit `077b9b08`, the event should be as follows:

##### 077b9b08 ETA Port
```javascript
{
  // A random or hash-based UUID generated by the carrier
  "uuid": "2ccf0ee9-9f65-4b3f-ae55-0031bc315ec2",
  // The event format version used
  "version": "3.1.1",
  // A string identifying the carrier as agreed with other participants
  "source": "Carrier X",
  // The event type of this timestamp (see table below for other event types)
  "eventType": "port.eta.carrier",
  // The timestamp at which this event was created, in UTC
  "recordTime": "2018-01-01T12:00:00Z",
  // The expected time of arrival (ETA) port of the ship
  "eventTime": "2018-01-03T15:00:00Z",
  // The ship identifiers and (optional) name
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  // The UNLOCODE of the port which the ship will visit
  "port": "XXGIL",
  // Because for our visit the Port Authority has not yet provided us with a portcall identifier we generate our own (for more information see the port call id paragraph below).
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "port"
  }
}
```
**Note**: *Be aware that the event times should be in UTC (Zulu) time. Since our vessel is currently in the +02:00 time zone, two hours need to be subtracted from the local time. We recommend using a date-time library for this.*


### Event types
| Event name               | Identifier                     | Description                                                                  |
|--------------------------|--------------------------------|------------------------------------------------------------------------------|
| ETA Port                 | port.eta.carrier               | The estimated time the ship will arrive at the port.                         |
| ATA Port                 | port.ata.carrier               | The actual time the ship has arrived in the port.                            |
| ETA Pilot Boarding Place | pilotBoardingPlace.eta.carrier | The estimated time the ship has arrived at the pilot boarding place          |
| ATA Pilot Boarding Place | pilotBoardingPlace.ata.carrier | The actual time the ship will arrive at the pilot boarding place             |
| ETA Berth                | berth.eta.carrier              | The estimated time the ship will arrive at the berth (before it's moored)    |
| ATA Berth                | berth.ata.carrier              | The actual time the ship has arrived at the berth                            |
| ETD Berth                | berth.etd.carrier              | The estimated time the ship will depart from the berth (after it's unmoored) |
| ATD Berth                | berth.atd.carrier              | The actual time the ship has departed from the berth                         |
| ETD Pilot Boarding Place | pilotBoardingPlace.etd.carrier | The estimated time the ship has depart through the pilot boarding place      |
| ATD Pilot Boarding Place | pilotBoardingPlace.atd.carrier | The actual time the ship will depart through pilot boarding place            |
| ETD Port                 | port.etd.carrier               | The estimated time the ship will depart from the port                        |
| ATD Port                 | port.atd.carrier               | The actual time the ship has departed from the port                          |
| Cancel berth visit       | berth.cancel.carrier           | A previously planned visit to a specific berth will no longer happen         |
| Cancel visit             | port.cancel.carrier            | A previously planned visit to the port will no longer happen                 |

### Port Call ID
The port call id is a **unique, non-repeating** identifier which the system who reads your events can use to group them together. This is nessasary to work with estimations, if for example you send an ETA Port for a vessel and later send another ETA Port which is 2 days apart it could mean either

1. The ETA Port for the visit has changed
2. The vessel will make a new visit within two days of it's previous visit

By supplying a port call ID consumers can differentiate between the two: if the id is identical the event is an update, if the id is different it is a second visit.

Within Pronto we know two different port call id's, local port call id and a source specific port call id. 
Pronto prefers the first one over the later since this is the id other parties will use to provide information about the specific vist.

#### Local Port Call ID
The local port call id is the identifier assigned to your visit by the port authority of the port it will be visiting. 

#### Source Specific Port Call ID
A source specific port call id will have the following structure `PID-` followed by a string uniquely identify your system, e.g. your source string. It is then followed by a unique identifier of your choosing. Because our system handles these identifiers differently they should be added to an event in its context as seen in [this example](#f0b2426f1-eta-berth)

### Berth visit ID

The berth visit ID is a **unique**, **non-repeating** identifier that systems who read your events can use to link your events.
This is necessary to work with Estimates. If you send an ETA Berth for a vessel at a berth and later send another ETA Berth for a vessel at another berth the meaning of these two events is ambiguous:
it could mean either

1) The ETA of the visit is changed, and the berth of the visit is also changed or
2) The vessel will visit two of your berths, and both ETAs remain valid

By supplying a berth visit ID consumers can differentiate between the two: if the id is identical the event is an update, if the id is different it is a second visit.

A berthvisit ID always starts with `BID-` followed by a string uniquely identifying your system, e.g. your source string.
It is then followed by a unique identifier of your choosing.
Often terminals have a primary key in their database suitable for this, some terminals choose to first hash and salt (e.g. with [sha2](https://en.wikipedia.org/wiki/SHA-2)) their identifier because they do not want to leak it.

Since these ambiguities do not exist for actual events, berth visit IDs are not a requirement for actual events.
It is however highly recommended to still send them, since this allows easy linking of estimates and actuals.

### Sending updates

If a timestamp changes in your system, you should create a new event to share this update with the other parties. Say the ETA Port for the BUKHA we send earlier becomes and ATA, we now send a new ATA event:
```javascript
{
  "uuid": "db1fa9e7-1e24-4fba-96db-6977a650fed2",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "port.ata.carrier",
  "recordTime": "2018-01-04T19:12:04Z",
  "eventTime": "2018-01-04T19:09:27Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "port"
  }
}
```

### Cancellations
Sometimes a visit is already scheduled to a port, and the carrier has already sent out events for this visit, but for some reason the ship will not visit the port (or part of it) anymore.

In this case, the carrier will need to send a cancellation event to the other parties to make sure they are aware that the scheduled visit will no longer happen. 

**Note**: *There is currently no way to "un-cancel" a visit and the identifiers cannot be re-used. It is an error to send new events with a id of a visit that has been cancelled. If a (berth) visit was cancelled but then re-scheduled, it need to have a new id.*

#### Berth visit
Let's say that for some reason the PENELOPE will no longer visit the Gilo 3 but we've already send out the ETA berth and ETD berth. The berth visit must then be cancelled and a cancel event must be send:
```javascript
{
    "uuid": "1915f10d-792c-4c88-a5ad-8bee91689b53",
    "version": "3.1.1",
    "source": "Carrier X",
    "eventType": "berth.cancel.terminal",
    "recordTime": "2018-06-08T13:30:00Z",
    "eventTime": "2018-06-08T13:30:00Z",
    "ship": {
        "imo": "9402914",
        "name": "PENELOPE"
    },
    "port": "XXGIL",
    "location": {
      "type": "berth",
      "name": "Gilo 3"
    },
    "context": {
      "berthVisitId": "BID-CarrierX-f0b2426f1",
      "organisationPortcallId": "PID-CarrierX-f0b2426f"
    }
}
```

#### Visit
If, for example, the port is closed due to certain weather conditions the carrier can decide to re-route the BUKHA to another port. The visit must then be cancelled and a cancel event must be send: 

```javascript
{
    "uuid": "34b4c6e7-ddc2-4678-b37c-48e0795a8bfa",
    "version": "3.1.1",
    "source": "Carrier X",
    "eventType": "port.cancel.terminal",
    "recordTime": "2018-06-08T13:30:00Z",
    "eventTime": "2018-06-08T13:30:00Z",
    "ship": {
        "imo": "9500936",
        "name": "BUKHA"
    },
    "port": "XXGIL",
    "portcallId": "XXGIL18000495",
    "location": {
      "type": "berth",
      "name": "Gilo 1"
    }
}
```

### Other events

##### 077b9b08 ETA Pilot Boarding Place
```javascript
{
  "uuid": "5c8745fd-93f3-4155-9205-2df5d6e354c2",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.eta.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-03T16:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "pilotBoardingPlace",
    "name": "Gilo Pilot Boarding Area 1"
  }
}
```

##### 077b9b081 ETA Berth
```javascript
{
  "uuid": "5c8745fd-93f3-4155-9205-2df5d6e354c2",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.eta.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-03T18:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "berth",
    "name": "Gilo 1"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-077b9b081"
  }
}
```

##### 077b9b081 ETD Berth
```javascript
{
  "uuid": "5c8745fd-93f3-4155-9205-2df5d6e354c2",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.etd.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-04T05:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "berth",
    "name": "Gilo 1"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-077b9b081"
  }
}
```

##### 077b9b08 ETD Port
```javascript
{
  "uuid": "f6da6297-bc98-493c-bb57-afdc3ec59244",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "port.etd.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-04T07:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "portcallId": "XXGIL18000495",
  "location": {
    "type": "port"
  }
}
```

##### f0b2426f ETA Port
```javascript
{
  "uuid": "89355cb0-b12e-4af6-85ff-34cc0617f28e",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "port.eta.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-05T17:00:00Z",
  "ship": {
    "imo": "9402914",
    "name": "PENELOPE"
  },
  "port": "XXGIL",
  "location": {
    "type": "port"
  },
  "context": {
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```

##### f0b2426f1 ETA Berth
```javascript
{
  "uuid": "1d95ee0e-a4ee-4f4e-bbcb-b15d3ce16d66",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.eta.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-05T19:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "location": {
    "type": "berth",
    "name": "Gilo 3"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-f0b2426f1",
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```

##### f0b2426f1 ETD Berth
```javascript
{
  "uuid": "f09f52e4-477b-455b-88e1-21ec9ca0371f",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.etd.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-06T17:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "location": {
    "type": "berth",
    "name": "Gilo 3"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-f0b2426f1",
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```

##### f0b2426f2 ETA Berth
```javascript
{
  "uuid": "24546dfc-088f-4a2f-a901-6369cd0b6a5a",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.eta.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-06T18:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "location": {
    "type": "berth",
    "name": "Gilo 2"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-f0b2426f2",
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```

##### f0b2426f2 ETD Berth
```javascript
{
  "uuid": "a01b4c9c-83d6-4d9d-a126-5a74ade23c93",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "berth.etd.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-08T13:00:00Z",
  "ship": {
    "imo": "9500936",
    "name": "BUKHA"
  },
  "port": "XXGIL",
  "location": {
    "type": "berth",
    "name": "Gilo 2"
  },
  "context": {
    "berthVisitId": "BID-CarrierX-f0b2426f2",
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```

##### f0b2426f ETD Port
```javascript
{
  "uuid": "7c93d2f6-5f8a-4010-9cfe-3205085ff2be",
  "version": "3.1.1",
  "source": "Carrier X",
  "eventType": "port.etd.carrier",
  "recordTime": "2018-01-01T12:00:00Z",
  "eventTime": "2018-01-08T15:00:00Z",
  "ship": {
    "imo": "9402914",
    "name": "PENELOPE"
  },
  "port": "XXGIL",
  "location": {
    "type": "port"
  },
  "context": {
    "organisationPortcallId": "PID-CarrierX-f0b2426f"
  }
}
```
