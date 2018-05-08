# Port call event model		
  		  
The port call event format is an implementation of the funtional definitions for Nautical Port Information Standard (NPIS) 5.2.		
 		
This specification is in active development, and comments from the port community are welcome.

## MovementId, BerthVisitId and ServiceId

The event system allows for three additional identifiers in addition to portcall id's:
* Movement identifier: this identifies a movement, which is a ship traveling from one location to another inside a portcall
* Berth visit identifier: this identifier a berth visit, which is a ship being alongside a single berth
* Service identifier: this identifies a single service like bunkering

#### Justification

Consider the following events: <br />
`ETA BERTH - IMO 1 - Berth A - 12:00:00` <br />
`ETA BERTH - IMO 1 - Berth B - 14:00:00`

Purely from these events one cannot distinguish the following scenario's:
* The ship was scheduled to go to Berth A at 12:00, but instead is now scheduled to go to Berth B at 14:00
* The ship will got to Berth A at 12:00, and afterwards go to Berth B at 14:00

Similar ambiguity exists for service events (which completion event is linked to which start event?)

Note that these ambiguities usually do not exist with actuals, as they normally never will be updated and can matched on event time.

#### Format

| ID                      | Format              |
| ----------------------- | --------------------|
| Movement identifier     | `MID-{SYSTEM}-{ID}` |
| Berth visit identifier  | `BID-{SYSTEM}-{ID}` |
| Service identifier      | `SID-{SYSTEM}-{ID}` |

`{SYSTEM}` must be replaced by a string consisting of alphanumeric characters or an underscore (`[A-Z0-9_]`) of which can reasonably be assumed that it globally uniquely identifies the system sending events.

`{ID}` must be replaced by a string consisting of of alphanumeric characters or an underscore (`[A-Z0-9_]`) which is unique for that system.

#### Requirements

An event MUST NOT contain both a movement and berth visit identifier <br />
A system MUST NOT use both movement and berth visit identifiers, it can only send one type in its events <br />
A system SHOULD prefer movement identifiers over berth visit identifiers, unless it only sends events about berth activities <br />
An event belonging to a berth visit activity with a movement identifier MUST be interpreted as belonging to the berth visit following that movement <br />
A system MUST use the same berth visit, movement or service identifier if it sends new events about the same activity, unless that identifier was cancelled in case it MUST create a new one. <br />
A system MUST NOT re-use identifiers <br />
A system MAY omit a movement or berthvisit identifier if a portcall only has a single berthvisit and two movements (an inbound and outbound movement) <br />
A system SHOULD NOT send new events with an identifier it previously cancelled, since those events will be considered part of the now cancelled activity. <br />
A system MAY omit berth visit and movement identifiers for actual events <br />


# Future work

Several parties are using additional events which follow, but these have not been standarized yet:

* Tug events: Tug Stand By & Ready to Assist and Tugs Dismissed
* Estimate service events
* Whether service events should be one per service ship (`serviceShip`) or one per service activity (`serviceShips`)
* Service information like amount of bunker fuel pumped
* Events predicted on historical information or derived from other events
* Agent, Carrier, and schedule information
* Several NPIS events do not have an event type yet: Gangway secured, Gangway up, All Fast, All Clear, Safe Access to Shore Open, Safe Access to Shore closed
