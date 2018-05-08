# Port Call Optimisation

The Taskforce for Portcall Optimisation agreed on functional definitions for Nautical Port Events based on current industry standards. [Read more](https://www.portofrotterdam.com/en/shipping/port-call-optimisation)

# Port call event format

The port call event format is an implementation of the funtional definitions for Nautical Port Information Standard (NPIS) 5.2.

This specification is in active development, and comments from the port community are welcome.

## Event specification

This spec describes the JSON serialization of port call events. <br />
It is written in valid [Typescript](https://www.typescriptlang.org/) and intended to be human-readable. <br />
The specification can be found in [Event_spec.ts](Event_spec.ts), with some accompanying definitions in [Event_spec.md](Event_spec.md)<br />
For machine validation an equivalent JSON Schema is available in [Event_schema.json](Event_schema.json). <br />
Instructions on relation to GS1 EPCIS events and how to convert can be found in [EPCIS.md](EPCIS.md)<br />
Example events can be found in [examples](examples/)
