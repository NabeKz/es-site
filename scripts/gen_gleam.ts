import type { Spec } from "./gleam/types.ts";
import {
  hasOptionalFields,
  hasDateTimeFields,
  hasUuidFields,
  collectRequestSchemaNames,
} from "./gleam/utils.ts";
import { generateEncoderBlock } from "./gleam/encoder.ts";
import { generateDecoderBlock, uuidDecodeHelper } from "./gleam/decoder.ts";
import { checkHelpers, generateValidatorBlock } from "./gleam/validator.ts";
import type { CheckKind } from "./gleam/validator.ts";


const jsonPath = process.argv[2]!;
const spec = await Bun.file(jsonPath).json() as Spec;
const schemas = spec.components?.schemas ?? {};

const objectSchemas = Object.entries(schemas).filter(
  ([, s]) => s.type === "object" && s.properties
);

// responses.gleam
const requestSchemaNames = collectRequestSchemaNames(spec);
const responseSchemas = objectSchemas.filter(([name]) => !requestSchemaNames.has(name));
const responseBlocks = responseSchemas.map(([name, schema]) => generateEncoderBlock(name, schema));

const responseSchemaMap = Object.fromEntries(responseSchemas);
const responseImports = [
  "import gleam/json",
  hasOptionalFields(responseSchemaMap) ? "import gleam/option.{type Option}" : null,
  hasDateTimeFields(responseSchemaMap) ? "import gleam/time/calendar" : null,
  hasDateTimeFields(responseSchemaMap) ? "import gleam/time/timestamp.{type Timestamp}" : null,
  hasUuidFields(responseSchemaMap) ? "import youid/uuid.{type Uuid}" : null,
]
  .filter(Boolean)
  .join("\n");

const responsesPath = new URL("../backend/src/generated/responses.gleam", import.meta.url).pathname;
await Bun.write(
  responsesPath,
  [
    "// This file is auto-generated from openapi.yaml. Do not edit manually.",
    responseImports,
    "",
    responseBlocks.join("\n\n"),
    "",
  ].join("\n")
);
console.log(`Generated ${responseBlocks.length} response schemas → ${responsesPath}`);

// requests.gleam
const requestSchemas = objectSchemas.filter(([name]) => requestSchemaNames.has(name));

if (requestSchemas.length > 0) {
  const decoderBlocks = requestSchemas.map(([name, schema]) => generateDecoderBlock(name, schema));

  const validatorResults = requestSchemas.map(([name, schema]) =>
    generateValidatorBlock(name, schema)
  );

  const allKinds = new Set<CheckKind>(validatorResults.flatMap((r) => [...r.kinds]));
  const validatorBlocks = validatorResults.map((r) => r.block);
  const helperBlocks = [...allKinds].map((k) => checkHelpers[k]);

  const requestSchemaMap = Object.fromEntries(requestSchemas);
  const hasOptional = hasOptionalFields(requestSchemaMap);
  const needsString = allKinds.has("min_length") || allKinds.has("max_length");
  const needsInt =
    allKinds.has("min_length") ||
    allKinds.has("max_length") ||
    allKinds.has("min_int") ||
    allKinds.has("max_int");
  const needsFloat = allKinds.has("min_float") || allKinds.has("max_float");
  const needsTimestamp = allKinds.has("date_time");
  const needsUuid = hasUuidFields(requestSchemaMap);

  const requestImports = [
    "import gleam/dynamic.{type Dynamic}",
    "import gleam/dynamic/decode",
    needsFloat ? "import gleam/float" : null,
    needsInt ? "import gleam/int" : null,
    hasOptional ? "import gleam/option.{type Option}" : null,
    needsString ? "import gleam/string" : null,
    needsTimestamp ? "import gleam/time/timestamp" : null,
    needsUuid ? "import youid/uuid.{type Uuid}" : null,
  ]
    .filter(Boolean)
    .join("\n");

  const requestsPath = new URL("../backend/src/generated/requests.gleam", import.meta.url).pathname;
  await Bun.write(
    requestsPath,
    [
      "// This file is auto-generated from openapi.yaml. Do not edit manually.",
      requestImports,
      "",
      [...decoderBlocks, ...validatorBlocks, ...helperBlocks, ...(needsUuid ? [uuidDecodeHelper] : [])].join("\n\n"),
      "",
    ].join("\n")
  );
  console.log(`Generated ${decoderBlocks.length} request schemas → ${requestsPath}`);
}
