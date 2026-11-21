// What falls through a component (ADR-0118, `src/fallthrough.ts`): the rest of `Astro.props`,
// spread on the root or on the element that spreads the props' rest, with the element's own
// attributes read from the props first, so the consumer's wins. The corpus checks the same shapes
// through every layer (`cases/fallthrough`); these pin each one, and render them.
import { afterAll, describe, expect, it } from "vitest";

import { renderToString } from "../src/toolchain/server.ts";
import { loadAstroComponent, scratchDirectory } from "./astro.ts";
import { emitSource } from "./source.ts";

const scratch = scratchDirectory("fallthrough");
afterAll(() => scratch.remove());

/** Each file a source's components emit, as `emit` prints them, by path. */
const outputs = (source: string, file = "Card.uf.tsx"): Record<string, string> =>
  Object.fromEntries(emitSource(source, file).map(({ path, contents }) => [path, contents]));

/** Server-renders Astro source with props, as the `ssr:astro` project does. */
async function render(source: string, props: Record<string, unknown>): Promise<string> {
  return renderToString(await loadAstroComponent(scratch.path, source), { props });
}

const button = [
  "export default function SaveButton({ title }: { title: string }) {",
  "  return (",
  '    <button type="button" class="button" aria-label={title} disabled>',
  "      {title}",
  "    </button>",
  "  );",
  "}",
].join("\n");

const field = [
  'import { defineOptions } from "@uxfront/unframework";',
  "",
  "export default function Field({ label, ...rest }: { label: string }) {",
  "  defineOptions({ inheritAttrs: false });",
  "  return (",
  '    <label class="field">',
  "      {label} <input {...rest} name={label.toLowerCase()} />",
  "    </label>",
  "  );",
  "}",
].join("\n");

describe("fallthrough (ADR-0118)", () => {
  it("spreads the rest of the props on the root, which reads its own attributes from them first", () => {
    expect(outputs(button, "SaveButton.uf.tsx")["SaveButton.astro"]).toBe(
      [
        "---",
        'import type { HTMLAttributes } from "astro/types";',
        "",
        'interface Props extends Omit<HTMLAttributes<"button">, "title"> { title: string',
        "  class?: string;",
        "  style?: Record<string, string | number | undefined>;",
        "}",
        "",
        'const { title, class: className, style, type = "button", "aria-label": ariaLabel, disabled = true, ...attrs } = Astro.props;',
        "---",
        "",
        "<button",
        "  type={type}",
        '  class:list={["button", className]}',
        "  aria-label={ariaLabel ?? title}",
        "  disabled={disabled}",
        "  style={style}",
        "  {...attrs}",
        ">{title}</button>",
        "",
      ].join("\n"),
    );
  });

  it("writes each attribute once, the consumer's where it passes one, and the scope attributes with the rest", async () => {
    const output = outputs(button, "SaveButton.uf.tsx")["SaveButton.astro"]!;
    await expect(render(output, { title: "Save" })).resolves.toBe(
      '<button type="button" class="button" aria-label="Save" disabled>Save</button>',
    );
    await expect(
      render(output, {
        title: "Save",
        type: "submit",
        "aria-label": "Save the draft",
        disabled: false,
        id: "save",
        class: "primary",
        style: { marginTop: "4px" },
        "data-uf-1a2b3c4d": "",
      }),
    ).resolves.toBe(
      '<button type="submit" class="button primary" aria-label="Save the draft" style="margin-top:4px" id="save" data-uf-1a2b3c4d>Save</button>',
    );
  });

  it("spreads the props' rest on its element, and keeps the scope attributes on the root", async () => {
    const output = outputs(field, "Field.uf.tsx")["Field.astro"]!;
    expect(output).toContain('interface Props extends Omit<HTMLAttributes<"input">, "label"> {');
    expect(output).toContain(
      "const { label, class: className, style, name, ...attrs } = Astro.props;",
    );
    expect(output).toContain(
      'function withoutScope(rest: object): Record<string, unknown> {\n  return Object.fromEntries(Object.entries(rest).filter(([key]) => !key.startsWith("data-uf-")));\n}',
    );
    expect(output).toContain("{...scopeAttributes(Astro.props)}");
    expect(output).toContain(
      "<input\n  {...withoutScope(attrs)}\n  name={name ?? label.toLowerCase()}\n  class:list={[className]}\n  style={style}\n/>",
    );
    await expect(
      render(output, {
        label: "Email",
        id: "email",
        name: "address",
        class: "wide",
        "data-uf-1a2b3c4d": "",
      }),
    ).resolves.toBe(
      '<label class="field" data-uf-1a2b3c4d>Email <input id="email" name="address" class="wide"></label>',
    );
  });

  it("takes a root component's tag for `Props`, its props left out, and passes the rest to it", () => {
    const source = [
      "function Base({ text }: { text: string }) {",
      '  return <a href="/">{text}</a>;',
      "}",
      "",
      "export default function Link({ label }: { label: string }) {",
      "  return <Base text={label} />;",
      "}",
    ].join("\n");
    const link = outputs(source, "Link.uf.tsx")["Link.astro"]!;
    expect(link).toContain('interface Props extends Omit<HTMLAttributes<"a">, "label" | "text"> {');
    expect(link).toContain(
      "<Base text={label} class:list={[className]} style={style} {...attrs} />",
    );
  });

  it("names a declared prop nothing reads apart, so it never falls through", () => {
    const source = [
      "export default function Tag(props: { label: string; hint?: string }) {",
      "  return <span>{props.label}</span>;",
      "}",
    ].join("\n");
    expect(outputs(source, "Tag.uf.tsx")["Tag.astro"]).toContain(
      "const props = Astro.props;\nconst { label: _label, hint: _hint, class: className, style, ...attrs } = Astro.props;",
    );
  });
});
