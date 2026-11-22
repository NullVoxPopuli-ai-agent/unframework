import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";

export interface UploadStep {
  id: string;
  label: string;
}

export interface UploadStatusProps {
  fileName: string;
  state: "queued" | "uploading" | "failed";
  percent: number;
  steps: UploadStep[];
  error?: string;
}

export interface UploadStatusSignature {
  Args: UploadStatusProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class UploadStatus extends Component<UploadStatusSignature> {
  get value1() {
    return this.args.state === "failed";
  }

  get value2() {
    return this.args.state === "failed" ? (this.args.error ?? "The upload failed.") : undefined;
  }

  get value3() {
    return !(this.args.state === "failed")
      ? this.args.state === "queued"
        ? "Waiting to start"
        : "Uploading"
      : undefined;
  }

  get value4() {
    return `Upload of ${this.args.fileName}`;
  }

  get value5() {
    return styleText([
      ["color", this.args.state === "failed" ? "#8a1c1c" : "#1f3d5c"],
      ["--upload-percent", this.args.percent],
    ]);
  }

  get value6() {
    return classNames("upload", `upload-${this.args.state}`);
  }

  <template><section
      class={{this.value6}}
      aria-label={{this.value4}}
      style={{this.value5}}
      ...attributes
    ><h2>{{@fileName}}</h2><div
      role="progressbar"
      aria-label="Upload progress"
      aria-valuemin="0"
      aria-valuemax="100"
      aria-valuenow={{enumeratedValue @percent}}
    >{{@percent}}%</div>{{#if this.value1}}<p class="upload-error">{{this.value2}}</p>{{else}}<p>{{this.value3}}</p>{{/if}}<ol>{{#each @steps key="id" as |step|}}<li>{{step.label}}</li>{{/each}}</ol></section></template>
}

/** A class as clsx builds it: strings, arrays and toggle objects, empty tokens left out. */
function classNames(...values: unknown[]): string | undefined {
  const tokens: string[] = [];
  const add = (value: unknown): void => {
    if (!value) return;
    if (typeof value === "string" || typeof value === "number") tokens.push(String(value));
    else if (Array.isArray(value)) for (const each of value) add(each);
    else if (typeof value === "object") {
      for (const [name, on] of Object.entries(value)) if (on) tokens.push(name);
    }
  };
  for (const value of values) add(value);
  return tokens.length ? tokens.join(" ") : undefined;
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}

/**
 * A style from its declarations, those whose value is nullish left out, marked safe. A
 * declaration without a property is a whole style: a declaration list, or an object whose keys
 * may be in camel case, as Vue's `normalizeStyle` reads them.
 */
function styleText(
  declarations: readonly (readonly [string, unknown])[],
): ReturnType<typeof htmlSafe> | undefined {
  const parts: string[] = [];
  const add = (property: string, value: unknown): void => {
    if (value === undefined || value === null) return;
    if (property) parts.push(`${property}: ${String(value)}`);
    else if (typeof value === "string") parts.push(value.trim().replace(/;$/, ""));
    else if (typeof value === "object") {
      for (const [key, each] of Object.entries(value)) {
        add(
          key.startsWith("--")
            ? key
            : key.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`),
          each,
        );
      }
    }
  };
  for (const [property, value] of declarations) add(property, value);
  const text = parts.filter(Boolean).join("; ");
  return text ? htmlSafe(text) : undefined;
}
