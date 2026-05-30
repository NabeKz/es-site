import type { Schema } from "./types.ts";
import { refName, toSnakeCase, scalarType, isNullable } from "./utils.ts";

export function gleamType(schema: Schema, isRequired: boolean): string {
  let base: string;
  if (schema.$ref) {
    base = refName(schema.$ref);
  } else if (scalarType(schema) === "array") {
    base = `List(${gleamType(schema.items!, true)})`;
  } else {
    const map: Record<string, string> = {
      string: schema.format === "date-time" ? "Timestamp" : schema.format === "uuid" ? "Uuid" : "String",
      integer: "Int",
      number: "Float",
      boolean: "Bool",
    };
    base = map[scalarType(schema)] ?? "Nil";
  }
  return isRequired && !isNullable(schema) ? base : `Option(${base})`;
}

function encodeExpr(schema: Schema, accessor: string, isRequired: boolean): string {
  const inner = (s: Schema, acc: string): string => {
    if (s.$ref) return `encode_${toSnakeCase(refName(s.$ref))}(${acc})`;
    if (scalarType(s) === "array") {
      const itemEnc = inner(s.items!, "item");
      return `json.array(${acc}, fn(item) { ${itemEnc} })`;
    }
    if (scalarType(s) === "string" && s.format === "date-time") {
      return `json.string(timestamp.to_rfc3339(${acc}, calendar.utc_offset))`;
    }
    if (scalarType(s) === "string" && s.format === "uuid") {
      return `json.string(uuid.to_string(${acc}))`;
    }
    const map: Record<string, string> = {
      string: `json.string(${acc})`,
      integer: `json.int(${acc})`,
      number: `json.float(${acc})`,
      boolean: `json.bool(${acc})`,
    };
    return map[scalarType(s)] ?? "json.null()";
  };

  if (!isRequired || isNullable(schema)) {
    const shorthand: Record<string, string> = {
      ...(schema.format !== "date-time" && schema.format !== "uuid" ? { string: "json.string" } : {}),
      integer: "json.int",
      number: "json.float",
      boolean: "json.bool",
    };
    const sh = shorthand[scalarType(schema)];
    if (sh) return `json.nullable(${accessor}, ${sh})`;
    return `json.nullable(${accessor}, fn(inner) { ${inner(schema, "inner")} })`;
  }

  return inner(schema, accessor);
}

export function generateEncoderBlock(name: string, schema: Schema): string {
  const required = new Set(schema.required ?? []);
  const props = Object.entries(schema.properties ?? {});

  const fields = props
    .map(([k, s]) => `    ${toSnakeCase(k)}: ${gleamType(s, required.has(k))}`)
    .join(",\n");

  const typeDef = `pub type ${name} {\n  ${name}(\n${fields},\n  )\n}`;

  const encoderFields = props
    .map(([k, s]) => {
      const enc = encodeExpr(s, `value.${toSnakeCase(k)}`, required.has(k));
      return `    #("${k}", ${enc})`;
    })
    .join(",\n");

  const encoderFn =
    `pub fn encode_${toSnakeCase(name)}(value: ${name}) -> json.Json {\n` +
    `  json.object([\n${encoderFields},\n  ])\n}`;

  return `${typeDef}\n\n${encoderFn}`;
}
