import type { Schema } from "./types.ts";
import { refName, toSnakeCase, scalarType, isNullable } from "./utils.ts";

function gleamTypeForRequest(schema: Schema, isRequired: boolean): string {
  let base: string;
  if (schema.$ref) {
    base = refName(schema.$ref);
  } else if (scalarType(schema) === "array") {
    base = `List(${gleamTypeForRequest(schema.items!, true)})`;
  } else {
    const map: Record<string, string> = {
      string: schema.format === "uuid" ? "Uuid" : "String",
      integer: "Int",
      number: "Float",
      boolean: "Bool",
    };
    base = map[scalarType(schema)] ?? "Nil";
  }
  return isRequired && !isNullable(schema) ? base : `Option(${base})`;
}

function decoderExpr(schema: Schema): string {
  if (schema.$ref) return `decode_${toSnakeCase(refName(schema.$ref))}()`;
  if (scalarType(schema) === "array") {
    return `decode.list(${decoderExpr(schema.items!)})`;
  }
  if (scalarType(schema) === "string" && schema.format === "uuid") {
    return `decode_uuid_field()`;
  }
  const map: Record<string, string> = {
    string: "decode.string",
    integer: "decode.int",
    number: "decode.float",
    boolean: "decode.bool",
  };
  return map[scalarType(schema)] ?? "decode.dynamic";
}

export const uuidDecodeHelper =
  `fn decode_uuid_field() -> decode.Decoder(uuid.Uuid) {\n` +
  `  use s <- decode.then(decode.string)\n` +
  `  case uuid.from_string(s) {\n` +
  `    Ok(u) -> decode.success(u)\n` +
  `    Error(_) -> decode.failure(uuid.nil, "UUID")\n` +
  `  }\n` +
  `}`;

export function generateDecoderBlock(name: string, schema: Schema): string {
  const required = new Set(schema.required ?? []);
  const props = Object.entries(schema.properties ?? {});

  const fields = props
    .map(([k, s]) => `    ${toSnakeCase(k)}: ${gleamTypeForRequest(s, required.has(k))}`)
    .join(",\n");

  const typeDef = `pub type ${name} {\n  ${name}(\n${fields},\n  )\n}`;

  const fieldLines = props.map(([k, s]) => {
    const snk = toSnakeCase(k);
    const inner = decoderExpr(s);
    if (!required.has(k) || isNullable(s)) {
      const innerDecoder = isNullable(s) ? `decode.optional(${inner})` : inner;
      return `    use ${snk} <- decode.optional_field("${k}", option.None, ${innerDecoder})`;
    }
    return `    use ${snk} <- decode.field("${k}", ${inner})`;
  });

  const constructorArgs = props
    .map(([k]) => `      ${toSnakeCase(k)}:`)
    .join(",\n");

  const decoderFn =
    `fn decode_${toSnakeCase(name)}(value: Dynamic) -> Result(${name}, List(decode.DecodeError)) {\n` +
    `  decode.run(value, {\n` +
    fieldLines.join("\n") + "\n" +
    `    decode.success(${name}(\n${constructorArgs},\n    ))\n` +
    `  })\n}`;

  return `${typeDef}\n\n${decoderFn}`;
}
