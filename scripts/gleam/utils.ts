import type { Schema, Spec } from "./types.ts";

export const refName = (ref: string) => ref.split("/").pop()!;

export const toSnakeCase = (s: string) =>
  s.replace(/([A-Z])/g, "_$1").toLowerCase().replace(/^_/, "");

export function scalarType(schema: Schema): string {
  const types = Array.isArray(schema.type) ? schema.type : [schema.type ?? ""];
  return types.find((t) => t !== "null") ?? "";
}

export function isNullable(schema: Schema): boolean {
  return Array.isArray(schema.type) && schema.type.includes("null");
}

export function hasOptionalFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) => {
    const required = new Set(schema.required ?? []);
    return Object.entries(schema.properties ?? {}).some(
      ([k, s]) => !required.has(k) || isNullable(s)
    );
  });
}

export function hasDateTimeFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) =>
    Object.values(schema.properties ?? {}).some(
      (s) => scalarType(s) === "string" && s.format === "date-time"
    )
  );
}

export function hasUuidFields(schemas: Record<string, Schema>): boolean {
  return Object.values(schemas).some((schema) =>
    Object.values(schema.properties ?? {}).some(
      (s) => scalarType(s) === "string" && s.format === "uuid"
    )
  );
}

export function collectRequestSchemaNames(spec: Spec): Set<string> {
  const names = new Set<string>();
  for (const pathItem of Object.values(spec.paths ?? {})) {
    for (const method of ["get", "post", "put", "patch", "delete"] as const) {
      const op = pathItem[method];
      const ref = op?.requestBody?.content?.["application/json"]?.schema?.$ref;
      if (ref) names.add(refName(ref));
    }
  }
  return names;
}
