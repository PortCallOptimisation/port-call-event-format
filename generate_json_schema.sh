#!/bin/sh

npm install typescript-json-schema -g

typescript-json-schema Event_spec.ts IEvent --required --strictNullChecks -o Event_schema.json
