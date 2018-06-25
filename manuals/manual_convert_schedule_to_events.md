# Convert carrier schedule to port call events
We frequently receive the question from carriers how they can share their schedule with Pronto.

This manual contains instructions on how to do this.

## Example carrier schedule
For this manual we take a fictitious port "Gilo" with UNLOCODE `XXGIL`. Gilo has a single terminal managing the ports 3 berth `Gilo 1`, `Gilo 2` and `Gilo 3`.

At 2018-01-01 14:00 the latest schedule for the carrier is as follows:

| ID       | Port call     | Port  | Vessel name | IMO     |
|----------|---------------|-------|-------------|---------|
| 077b9b08 | XXGIL18000001 | XXGIL | BUKHA       | 9500936 |
| f0b2426f | XXGIL18000032 | XXGIL | PENELOPE    | 9402914 |
| f0b2426g | XXGIL18000032 | XXGIL | PENELOPE    | 9402914 |



## Sending events


### Event types
| Event name               | Identifier                   | Description                                                                  |
|--------------------------|------------------------------|------------------------------------------------------------------------------|
| ETA Port                 | port.eta.carrier               | The estimated time the ship will arrive at the port.                         |
| ATA Port                 | port.ata.carrier               | The actual time the ship has arrived in the port.                            |
| ETA Pilot Boarding Place | pilotBoardingPlace.eta.carrier | The estimated time the ship has arrived at the pilot boarding place          |
| ATA Pilot Boarding Place | pilotBoardingPlace.ata.carrier | The actual time the ship will arrive at the pilot boarding place             |
| ETA Berth                | berth.eta.carrier              | The estimated time the ship will arrive at the berth (before it's moored)    |
| ATA Berth                | berth.ata.carrier              | The actual time the ship has arrived at the berth                            |
| ETD Berth                | berth.etd.carrier              | The estimated time the ship will depart from the berth (after it's unmoored) |
| ATD Berth                | berth.atd.carrier              | The actual time the ship has departed from the berth                         |
| ETD Port                 | port.etd.carrier               | The estimated time the ship will depart from the port                        |
| ATD Port                 | port.atd.carrier               | The actual time the ship has departed from the port                          |
| Cancel berth visit       | berth.cancel.carrier           | A previously planned visit to a specific berth will no longer happen                                                                          |
| Cancel visit             | port.cancel.carrier            | A previously planned visit to the port will no longer happen                 |

### Sending Updated

### Cancellations

### Other events

```JSON
{
  "uuid": "5c8745fd-93f3-4155-9205-2df5d6e354c2",
  "version": "3.1.1",
  "source": "",
  "eventType": "",
  "recordTime": "",
  "eventTime": "",
  "ship": {

  }
}
```