export type Schema = {
  type?: string | string[];
  format?: string;
  properties?: Record<string, Schema>;
  required?: string[];
  items?: Schema;
  $ref?: string;
  minLength?: number;
  maxLength?: number;
  minimum?: number;
  maximum?: number;
  minItems?: number;
  maxItems?: number;
};

export type PathItem = {
  requestBody?: {
    content?: {
      "application/json"?: { schema?: Schema };
    };
  };
};

export type Spec = {
  components?: { schemas?: Record<string, Schema> };
  paths?: Record<string, PathItem & Record<string, PathItem>>;
};
