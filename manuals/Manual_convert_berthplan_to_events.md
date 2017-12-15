# Convert (berth) planning to PRONTO events

A frequent question we receive is "My system only has a berth plan available".
How do I send PRONTO events?

This manual contains step-by-step instructions on how to do this.  

#### Example berth plan

For this manual, we take a fictitious port "Gilo" with UNLCODE `XXGIL`.
Gilo has a single terminal managing the ports 3 berths `Gilo 1`, `Gilo 2` and `Gilo 3`.

At 2018-06-08 15:00, the current berth planning for the terminal as kept in its Terminal Operating System (TOS) is as follows:

| ID       | Port call     | Vessel Name    | IMO     | Berth  | Bollards | Arrival           | Departure         | *Events* |
| -------- | ------------- | -------------- | ------- |------- | ---------| ----------------- | ----------------- | -------- |
| 95aba704 | XXGIL18000144 | BUKHA          | 9500936 | Gilo 1 | 98-150   | 2018-06-08 14:00  | 2018-06-09 18:00  | [ETA](), [ETD](|95aba704-etd-berth), [ATA](|95aba704-eta-berth), [Cancel](|95aba704-cancel-berthvisit)
| 17afe301 | XXGIL18000145 | PENELOPE       | 9402914 | Gilo 3 | 11.5-100 | 2018-06-08 16:00  | 2018-06-08 20:00  |
| 17afe302 | XXGIL18000145 | PENELOPE       | 9402914 | Gilo 2 | 42-130   | 2018-06-08 22:00  | 2018-06-10 04:00  |

ID: Your internal Unique, non-reused ID for the visit<br />
Port call: The Unique identifier the Port Authority has assigned to the port visit<br />
Vessel name: Name of the vessel that will visit the berth<br />
IMO: IMO number of the vessel<br />
Berth: The berth the vessel will visit<br />
Timestamp: The TOS keeps 4 timestamps for each visit: Arrival, Departure, Cargo Start and Cargo Completion. Additionally each timestamp is marked as an estimate until it is confirmed by an operator to have happened.

#### Sending events

In order to share the berth plan with other parties, the TOS should convert the berth plan into events. <br />
If we want to send ETD for visit `95aba704`, the event should be as follows:

###### 95aba704 ETD Berth
```json
{
    // A random or hash-based UUID generated by the terminal
    "uuid": "6824463c-c1bf-4d73-9253-08ac8811372e",
    // The event format version used
    "version": "3.1.1",
    // A string identifying the Gilo terminal as agreed with other participants
    "source": "XXGIL Terminal",
    // The event type of this timestamp, see the table below
    "eventType": "berth.etd.terminal",
    // The timestamp at which this event was created, in UTC
    "recordTime": "2018-06-08T13:02:00Z",
    // The ETD
    "eventTime": "2018-06-08T14:00:00Z",
    // The ship identifiers and (optional) name
    "ship": {
        "imo": "9500936",
        "name": "BUKHA"
    },
    // Since the terminal is located in the port Gilo with UNLOCODE XXGIL, this will always be XXGIL
    "port": "XXGIL",
    // Since our terminal has a link with the local Port Authority system, it knows the portcall identifier and can add this
    "portcallId": "XXGIL18000144",
    "location": {
      // Since our terminal only has berths and always knows the berth, it can always use berth
      "type": "berth",
      // Our terminal already has GLNs assigned to all berths, so can use these
      "gln": "0061414000031",
      "name": "Gilo 1"
    },
    "context": {
      // Our TOS knows an estimate of the static draught of the ship when it will leave, so can add the optional draught to the event
      "draught": 1900,
      // Our TOS has access to mooring information, so can add the optional mooring information to the event
      "bollardFore": 98,
      "bollardAft": 150,
      "orientation": "Port",
      // The identifier of the berth visit for our terminal, see the berth visit id paragraph below
      "berthVisitId": "BID-XXGILTerminal-95aba704"
    }
}
```

Note that the event times should be in UTC (Zulu) time.
Since our terminal is currently in the +02:00 time zone, two hours need to be subtracted from the local time.
We recommend using a date-time library for this.

##### Event types
For terminals, the following event types will generally be the most interesting. A full list can be found in the specification.

| Event name | ID                           | Explanation
| PTA Berth  | berth.pta.terminal           | The planned time the ship will arrive at the berth, before it is moored
| ATA Berth  | berth.ata.terminal           | The actual time the ship has arrived at the berth
| ETS Cargo  | cargoOperations.ets.terminal | The estimated time at which cargo operation for the ship will start
| ATS Cargo  | cargoOperations.ats.terminal | The actual time at which cargo operations were started
| ETC Cargo  | cargoOperations.etc.terminal | The estimated time at which cargo operations for the ship will be completed
| ATC Cargo  | cargoOperations.atc.terminal | The actual time at which cargo operations for the ship were completed
| Cancel     | berth.cancel.terminal        | A planned visit will not happen

[The Standards for Nautical Port Information](../Standard_for_Nautical_Port_Information.pdf) also define the following events, which currently are not incorporated into the event standards yet: <br />
First line secured/released, Last line secured/released (defined for nautical services, but not for terminals), Safe access to shore open/closed, All Fast, All Clear

These are planned to be incorporated into the standard.

##### Berth visit ID

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

#### Sending updates

If a timestamp changing in your system, you should create a new event to share this update to other parties.
Say the ETA Berth for BUKHA we send earlier becomes an ATA, we now send a new ATA event:

####### 95aba704 ATA Berth
```json
{
    "uuid": "f6541fee-67cc-4df1-bacf-c9952f358da4",
    "version": "3.1.1",
    "source": "XXGIL Terminal",
    "eventType": "berth.ata.terminal",
    "recordTime": "2018-06-08T14:12:08Z",
    "eventTime": "2018-06-08T14:03:48Z",
    "ship": {
        "imo": "9500936",
        "name": "BUKHA"
    },
    "port": "XXGIL",
    "portcallId": "XXGIL18000144",
    "location": {
      "type": "berth",
      "gln": "0061414000031",
      "name": "Gilo 1"
    },
    "context": {
      "draught": 1870,
      "bollardFore": 98,
      "bollardAft": 150,
      "orientation": "Port",
      "berthVisitId": "BID-XXGILTerminal-95aba704"
    }
}
```

#### Cancellations

Sometimes a visit to a berth is planned to a terminal, and the terminal has already sent PTA berth and ETD berth events for this visit, but for some reason or another the ship will not visit the berth anymore.

In this case, the terminal will need to send a cancellation event to other parties to make sure that they are aware that the planned visit will not happen.
The events needs to have the same berth visit id as the previous events.

*Note*: There is currently no way to "un-cancel" visits and berth visit id's cannot be re-used.
It is an error to send new events with a berth visit id after it has been cancelled.
If a berth visit was cancelled but then re-scheduled, it needs to have a new berth visit id.

Say at 15:30, a storm prevents any ships from entering the Gilo port and instead of waiting the BUKHA decided to re-route to another port.
The visit must then be cancelled and a cancel event must be send, for example:

###### 95aba704 Cancel Berthvisit
```json
{
    "uuid": "ef3a6f60-db03-4cf1-aca1-5576e35d51fc",
    "version": "3.1.1",
    "source": "XXGIL Terminal",
    "eventType": "berth.cancel.terminal",
    "recordTime": "2018-06-08T13:30:00Z",
    "eventTime": "2018-06-08T13:30:00Z",
    "ship": {
        "imo": "9500936",
        "name": "BUKHA"
    },
    "port": "XXGIL",
    "portcallId": "XXGIL18000144",
    "location": {
      "type": "berth",
      "gln": "0061414000031",
      "name": "Gilo 1"
    },
    "context": {
      "berthVisitId": "BID-XXGILTerminal-95aba704"
    }
}
```


### Other events from the original berthplan
