import type { Schema } from "./types.ts";
import { toSnakeCase, scalarType, isNullable } from "./utils.ts";

export type CheckKind =
  | "min_length"
  | "max_length"
  | "min_int"
  | "max_int"
  | "min_float"
  | "max_float"
  | "date_time";

export const checkHelpers: Record<CheckKind, string> = {
  min_length:
    `fn check_min_length(errors: List(String), field: String, value: String, min: Int) -> List(String) {\n` +
    `  case string.length(value) >= min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> int.to_string(min) <> " characters", ..errors]\n` +
    `  }\n}`,
  max_length:
    `fn check_max_length(errors: List(String), field: String, value: String, max: Int) -> List(String) {\n` +
    `  case string.length(value) <= max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> int.to_string(max) <> " characters", ..errors]\n` +
    `  }\n}`,
  min_int:
    `fn check_min_int(errors: List(String), field: String, value: Int, min: Int) -> List(String) {\n` +
    `  case value >= min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> int.to_string(min), ..errors]\n` +
    `  }\n}`,
  max_int:
    `fn check_max_int(errors: List(String), field: String, value: Int, max: Int) -> List(String) {\n` +
    `  case value <= max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> int.to_string(max), ..errors]\n` +
    `  }\n}`,
  min_float:
    `fn check_min_float(errors: List(String), field: String, value: Float, min: Float) -> List(String) {\n` +
    `  case value >=. min {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at least " <> float.to_string(min), ..errors]\n` +
    `  }\n}`,
  max_float:
    `fn check_max_float(errors: List(String), field: String, value: Float, max: Float) -> List(String) {\n` +
    `  case value <=. max {\n` +
    `    True -> errors\n` +
    `    False -> [field <> " must be at most " <> float.to_string(max), ..errors]\n` +
    `  }\n}`,
  date_time:
    `fn check_date_time(errors: List(String), field: String, value: String) -> List(String) {\n` +
    `  case timestamp.parse_rfc3339(value) {\n` +
    `    Ok(_) -> errors\n` +
    `    Error(_) -> [field <> " is not a valid date-time", ..errors]\n` +
    `  }\n}`,
};

export function collectCheckLines(
  schema: Schema
): { lines: string[]; kinds: Set<CheckKind> } {
  const required = new Set(schema.required ?? []);
  const lines: string[] = [];
  const kinds = new Set<CheckKind>();

  for (const [k, s] of Object.entries(schema.properties ?? {})) {
    if (!required.has(k) || isNullable(s)) continue;

    const snk = toSnakeCase(k);
    const accessor = `input.${snk}`;
    const st = scalarType(s);

    if (st === "string" && s.format === "date-time") {
      lines.push(`    |> check_date_time("${k}", ${accessor})`);
      kinds.add("date_time");
    }
    if (st === "string" && s.minLength !== undefined) {
      lines.push(`    |> check_min_length("${k}", ${accessor}, ${s.minLength})`);
      kinds.add("min_length");
    }
    if (st === "string" && s.maxLength !== undefined) {
      lines.push(`    |> check_max_length("${k}", ${accessor}, ${s.maxLength})`);
      kinds.add("max_length");
    }
    if (st === "integer" && s.minimum !== undefined) {
      lines.push(`    |> check_min_int("${k}", ${accessor}, ${s.minimum})`);
      kinds.add("min_int");
    }
    if (st === "integer" && s.maximum !== undefined) {
      lines.push(`    |> check_max_int("${k}", ${accessor}, ${s.maximum})`);
      kinds.add("max_int");
    }
    if (st === "number" && s.minimum !== undefined) {
      lines.push(`    |> check_min_float("${k}", ${accessor}, ${s.minimum}.0)`);
      kinds.add("min_float");
    }
    if (st === "number" && s.maximum !== undefined) {
      lines.push(`    |> check_max_float("${k}", ${accessor}, ${s.maximum}.0)`);
      kinds.add("max_float");
    }
  }

  return { lines, kinds };
}

export function generateValidatorBlock(
  name: string,
  schema: Schema
): { block: string; kinds: Set<CheckKind> } {
  const { lines, kinds } = collectCheckLines(schema);

  const validateFn =
    `fn validate_${toSnakeCase(name)}(input: ${name}) -> Result(${name}, List(String)) {\n` +
    `  let errors =\n` +
    `    []\n` +
    (lines.length > 0 ? lines.join("\n") + "\n" : "") +
    `  case errors {\n` +
    `    [] -> Ok(input)\n` +
    `    _ -> Error(errors)\n` +
    `  }\n}`;

  const parseFn =
    `pub fn parse_${toSnakeCase(name)}(value: Dynamic) -> Result(${name}, List(String)) {\n` +
    `  case decode_${toSnakeCase(name)}(value) {\n` +
    `    Error(_) -> Error(["invalid request body"])\n` +
    `    Ok(input) -> validate_${toSnakeCase(name)}(input)\n` +
    `  }\n}`;

  return { block: `${validateFn}\n\n${parseFn}`, kinds };
}
