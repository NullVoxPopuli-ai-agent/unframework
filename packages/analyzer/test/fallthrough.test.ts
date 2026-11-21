// What falls through to a component's root (ADR-0118): undeclared attributes and native listeners,
// checked against the child's fallthrough element; a ref on a child that exposes nothing, typed as
// its root element; and the props' rest, with `inheritAttrs: false`, spread whole on one element.
import type { ComponentNode } from "@unframework.dev/ir";
import { describe, expect, it } from "vitest";

import { applyAndRecheck, codes, problems, run } from "./helpers.ts";

const API =
  'import { defineEmits, defineExpose, defineOptions, ref, useTemplateRef } from "@uxfront/unframework";\n';

/** Children of every shape a parent passes things to, in the parent's own module. */
const CHILDREN = `${API}
function Save({ title }: { title: string }) {
  const emit = defineEmits<{ pick: [title: string] }>();
  return <button type="button" onClick={() => emit("pick", title)}>{title}</button>;
}
function Wrapped({ title }: { title: string }) {
  return <Save title={title} />;
}
function Pair() {
  return <><p>a</p><p>b</p></>;
}
function Closed() {
  defineOptions({ inheritAttrs: false });
  return <p>a</p>;
}
function Field({ label, ...rest }: { label: string }) {
  defineOptions({ inheritAttrs: false });
  return <label>{label} <input {...rest} /></label>;
}
function Exposing() {
  const input = useTemplateRef<HTMLInputElement>();
  function focus() {
    input.value?.focus();
  }
  defineExpose({ focus });
  return <input ref={input} />;
}
`;

/** A parent of the children above, returning `jsx`, with `setup` before it. */
function parent(jsx: string, setup = "") {
  const source = `${CHILDREN}\nexport function Page() {\n  ${setup}\n  return ${jsx};\n}\n`;
  return { source, ...run(source) };
}

function componentNode(module: ReturnType<typeof run>["module"]): ComponentNode {
  const page = module!.components.find((each) => each.name === "Page")!;
  const visit = (value: unknown): ComponentNode | undefined => {
    if (!value || typeof value !== "object") return undefined;
    if ((value as { kind?: string }).kind === "Component") return value as ComponentNode;
    for (const item of Object.values(value)) {
      const found = visit(item);
      if (found) return found;
    }
    return undefined;
  };
  return visit(page.render)!;
}

describe("a child's API", () => {
  it("names the element what falls through and a ref land on", () => {
    const { api } = parent("<div />");
    const of = (name: string) => api!.components.find((each) => each.name === name)!;
    expect([of("Save").fallthroughTag, of("Save").refTag]).toEqual(["button", "button"]);
    // A root component's, through the chain.
    expect([of("Wrapped").fallthroughTag, of("Wrapped").refTag]).toEqual(["button", "button"]);
    expect([of("Pair").fallthroughTag, of("Pair").refTag]).toEqual([undefined, undefined]);
    expect(of("Closed").fallthroughTag).toBeUndefined();
    // With `inheritAttrs: false`, what falls through goes to the rest; a ref is still the root.
    expect([of("Field").fallthroughTag, of("Field").refTag]).toEqual(["input", "label"]);
    // A ref on a child that exposes holds what it exposes, never its element.
    expect([of("Exposing").fallthroughTag, of("Exposing").refTag]).toEqual(["input", undefined]);
  });
});

describe("what a parent passes", () => {
  it("lowers undeclared attributes and DOM listeners as the fallthrough element's, in source order", () => {
    const { module, diagnostics } = parent(
      '<Save id="s" title="Save" aria-pressed={on.value} type="submit" onPick={() => {}} onFocus={() => {}} class="a" />',
      "const on = ref(false);",
    );
    expect(diagnostics).toEqual([]);
    expect(
      componentNode(module).attributes.map((each) =>
        each.kind === "Prop" || each.kind === "Static" || each.kind === "Bound"
          ? `${each.kind} ${each.name}`
          : each.kind === "Event" || each.kind === "Listener"
            ? `${each.kind} ${each.event}`
            : each.kind,
      ),
    ).toEqual([
      "Static id",
      "Prop title",
      "Bound aria-pressed",
      "Static type",
      "Listener pick",
      "Event focus",
      "Class",
    ]);
  });

  it("checks them against the fallthrough element", () => {
    // `placeholder` is no attribute of a <button>, and `svae` no event at all.
    const { source, diagnostics } = parent(
      '<Save title="Save" placeholder="x" onSvae={() => {}} />',
    );
    expect(problems(source, diagnostics)).toEqual(["UF3035 placeholder", "UF3036 onSvae"]);
  });

  it("passes them through a root component, to its root", () => {
    const { diagnostics } = parent('<Wrapped title="Save" id="s" onClick={() => {}} />');
    expect(diagnostics).toEqual([]);
  });

  it("puts them on the rest's element with inheritAttrs: false", () => {
    const { source, diagnostics } = parent(
      '<Field label="Email" placeholder="you@example.com" type="email" onFocus={() => {}} />',
    );
    expect(diagnostics).toEqual([]);
    // A <label> attribute is no <input> one.
    const other = parent('<Field label="Email" for="x" />');
    expect(problems(other.source, other.diagnostics)).toEqual(["UF3035 for"]);
    expect(source).toBeDefined();
  });

  it("rejects them where the child takes nothing", () => {
    const { source, diagnostics } = parent(
      '<div><Pair id="a" onClick={() => {}} /><Closed class="b" title="t" /></div>',
    );
    expect(problems(source, diagnostics)).toEqual([
      "UF3045 id",
      "UF3045 onClick",
      "UF3045 class",
      "UF3045 title",
    ]);
  });

  it("rejects a listener option on a listener that falls through", () => {
    const { diagnostics } = parent('<Save title="Save" onClickOnce={() => {}} />');
    expect(codes(diagnostics)).toEqual(["UF1002"]);
  });

  it("reads a named handler that falls through as an element's (no UF3029)", () => {
    const { diagnostics } = parent(
      '<Save title="Save" onClick={track} />',
      "const n = ref(0);\n  function track(event: MouseEvent) {\n    n.value = event.button;\n  }",
    );
    expect(diagnostics).toEqual([]);
  });
});

describe("a ref on a component", () => {
  it("holds the root element of a child that exposes nothing, through a root component", () => {
    for (const child of ["Save", "Wrapped"]) {
      const { diagnostics } = parent(
        `<${child} ref={save} title="Save" />`,
        "const save = useTemplateRef<HTMLButtonElement>();",
      );
      expect(diagnostics).toEqual([]);
    }
  });

  it("is typed as that root element", () => {
    const wrong = parent(
      '<Save ref={save} title="Save" />',
      "const save = useTemplateRef<HTMLInputElement>();",
    );
    expect(problems(wrong.source, wrong.diagnostics)).toEqual(["UF3046 ref={save}"]);
    const untyped = parent('<Save ref={save} title="Save" />', "const save = useTemplateRef();");
    expect(codes(untyped.diagnostics)).toEqual(["UF3046"]);
  });

  it("holds nothing on a root that is not one element", () => {
    const { diagnostics } = parent(
      "<Pair ref={pair} />",
      "const pair = useTemplateRef<HTMLParagraphElement>();",
    );
    expect(codes(diagnostics)).toEqual(["UF3046"]);
  });

  it("holds the root even when the rest goes elsewhere, and only what a child exposes", () => {
    const field = parent(
      '<Field ref={field} label="Email" />',
      "const field = useTemplateRef<HTMLLabelElement>();",
    );
    expect(field.diagnostics).toEqual([]);
    const exposing = parent(
      "<Exposing ref={input} />",
      "const input = useTemplateRef<HTMLInputElement>();",
    );
    expect(codes(exposing.diagnostics)).toEqual(["UF3046"]);
  });
});

describe("the props' rest", () => {
  const rest = (body: string, options = true) =>
    `${API}export function Field({ label, items, ...rest }: { label: string; items: string[] }) {\n  ${options ? "defineOptions({ inheritAttrs: false });\n  " : ""}${body}\n}\n`;

  it("is spread whole on one element", () => {
    expect(run(rest("return <p {...rest}>{label}</p>;")).diagnostics).toEqual([]);
  });

  it("needs inheritAttrs: false, which its fix adds", () => {
    const source = rest("return <p {...rest}>{label}</p>;", false);
    const { diagnostics } = run(source);
    expect(problems(source, diagnostics)).toEqual(["UF2001 ...rest"]);
    expect(applyAndRecheck(source, diagnostics)).toContain(
      "defineOptions({ inheritAttrs: false });",
    );
  });

  it("adds defineOptions to the authoring import where it is missing", () => {
    const source = `import { ref } from "@uxfront/unframework";\nexport function Field({ label, ...rest }: { label: string }) {\n  const on = ref(false);\n  return <p {...rest} class={on.value ? "on" : "off"}>{label}</p>;\n}\n`;
    const { diagnostics } = run(source);
    expect(codes(diagnostics)).toEqual(["UF2001"]);
    const fixed = applyAndRecheck(source, diagnostics);
    expect(fixed).toContain('import { ref, defineOptions } from "@uxfront/unframework";');
  });

  it("is used in no other way", () => {
    for (const [body, problem] of [
      ["return <p title={rest.id}>{label}</p>;", "UF2001 rest"],
      ["return <div><p {...rest} /><p {...rest} /></div>;", "UF2001 {...rest}"],
      [
        "return <ul>{items.map((each) => <li key={each} {...rest}>{each}</li>)}</ul>;",
        "UF2001 {...rest}",
      ],
      ["const copy = rest;\n  return <p>{label}</p>;", "UF2001 rest"],
    ] as const) {
      const source = rest(body);
      expect(problems(source, run(source).diagnostics)).toContain(problem);
    }
  });

  it("is spread on no component", () => {
    const source = `${CHILDREN}export function Outer({ label, ...rest }: { label: string }) {\n  defineOptions({ inheritAttrs: false });\n  return <div><Save title={label} {...rest} /></div>;\n}\n`;
    expect(problems(source, run(source).diagnostics)).toEqual(["UF2001 {...rest}"]);
  });
});
