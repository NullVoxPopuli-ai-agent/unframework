// A component as a `.gts` module (plan §6): the imports, the copied types, the signature, then a
// template-only component or a `@glimmer/component` class. Glimmer templates hold paths, literals
// and helper calls, never JavaScript, so every other expression the template reads becomes a
// member of the class: a getter, or a function the template calls with the row variables it
// reads (`{{this.label item}}`).
import {
  addTypeImports,
  componentTypes,
  exportsOf,
  expressionNames,
  functionBodyText,
  functionText,
  ImportSet,
  passThroughImports,
  printMarkup,
  printProgram,
  rewriteCode as rewrite,
  rewriteExpression,
  typeDeclarationCode,
  typeExportsCode,
} from "@unframework.dev/codegen";
import type { ClassPart, EmitContext, RewriteRules, StylePart } from "@unframework.dev/codegen";
import { js } from "@unframework.dev/codegen";
import type {
  Binding,
  BindingReference,
  Expression,
  IfBranch,
  IfNode,
  Prop,
  UfComponent,
  UfModule,
} from "@unframework.dev/ir";

import { emberDialect } from "./dialect.ts";

/** A row variable a list's body reads: its name, and its type in the class's terms. */
interface RowVariable {
  name: string;
  type: string;
}

/** A member the template reads in place of an expression. */
interface Hoisted {
  name: string;
  parameters: readonly RowVariable[];
}

/** Prints one component's `.gts` module. */
export function emitComponent(component: UfComponent, context: EmitContext): string {
  const plan = new ComponentPlan(component, context.module);
  return plan.print();
}

/** A component's class: its members in order, and what the template reads through them. */
class ComponentPlan {
  readonly #component: UfComponent;
  readonly #module: UfModule;
  /** The members the template's expressions became, by their code and row variables. */
  readonly #hoisted = new Map<string, Hoisted>();
  /** The printed members the template's expressions became, in template order. */
  readonly #hoistedMembers: string[] = [];
  /** Each row variable's type, by name, for the lists printed so far. */
  readonly #rows = new Map<string, string>();
  /** The module helpers the members call. */
  readonly #helpers = new Set<"classNames" | "enumeratedValue" | "styleText">();
  #usesHtmlSafe = false;
  /** The tags the template writes. */
  readonly #tags: ReadonlySet<string>;
  /** Each node of the template, branch included, by what holds it. */
  readonly #parents: ReadonlyMap<object, object>;

  constructor(component: UfComponent, module: UfModule) {
    this.#component = component;
    this.#parents = parentsOf(component.render);
    this.#tags = tagsOf(component.render);
    this.#module = module;
  }

  /** How the class spells a reference to a binding: the same for every site. */
  get rules(): RewriteRules {
    return {
      binding: (reference, binding) => this.#spell(reference, binding),
      import: (reference) => this.#local(reference.name),
    };
  }

  /**
   * The name a module value or a row variable takes in the template's scope. Glimmer reads a tag
   * named like a name in scope as that component (`<button>` with `button` imported), so a name
   * the template also writes as a tag takes another.
   */
  #local(name: string): string {
    if (!this.#tags.has(name)) return name;
    let local = `${name}_1`;
    for (let n = 2; this.#tags.has(local); n++) local = `${name}_${n}`;
    return local;
  }

  #spell(reference: BindingReference, binding: Binding): string {
    switch (binding.kind) {
      case "prop": {
        const prop = this.#propOf(binding);
        return prop.default ? `this.${prop.name}` : `this.args.${prop.name}`;
      }
      case "loopVar":
        return this.#local(binding.name);
      case "state":
      case "derived":
      case "localConst":
      case "localFn":
      case "localVar":
        return `this.${binding.name}`;
      case "moduleConst":
      case "import":
        return binding.name;
      // Composition and context: a capability the cells leave unsupported, so the case has no
      // Ember output.
      default:
        return `this.${binding.name}`;
    }
  }

  #propOf(binding: Binding): Prop {
    const prop = this.#component.props.find((each) => each.binding === binding.id);
    if (!prop) throw new Error(`No prop binds ${binding.id}.`);
    return prop;
  }

  /**
   * The Glimmer expression for code: a path or a literal as written, or a member that holds the
   * code. `subexpression` writes a member call in parentheses, where Glimmer takes a value
   * (`{{#if (this.open item)}}`), and bare where a mustache calls it (`{{this.label item}}`).
   */
  value(code: string, subexpression: boolean, at?: object): string {
    const literal = glimmerLiteral(code);
    if (literal !== undefined) return literal;
    const conditions = this.#conditions(code, at);
    const path = this.#path(code);
    // Glint narrows a path under `{{#if}}` of a path, as TypeScript narrows the source; under any
    // other condition, a member reads the path under that condition.
    if (path !== undefined && conditions.every((each) => this.#narrowsAsPath(each))) return path;
    const guarded = conditions.length
      ? `${conditions.map((each) => `(${each})`).join(" && ")} ? ${code} : undefined`
      : code;
    const { name, parameters } = this.#hoist(guarded);
    if (!parameters.length) return `this.${name}`;
    const call = `this.${name} ${parameters.map((each) => each.name).join(" ")}`;
    return subexpression ? `(${call})` : call;
  }

  /** A path Glimmer reads as the code does, or `undefined`. */
  #path(code: string): string | undefined {
    // A non-null assertion asserts nothing a Glimmer path needs: it goes.
    const match = /^([A-Za-z_$][\w$]*)((?:!?\??\.[A-Za-z_$][\w$]*)*)!?$/.exec(code);
    if (!match) return undefined;
    const [, head, rest] = match;
    // Glimmer paths are nullish-safe on every segment, as `?.` is.
    const tail = rest!.replace(/!/g, "").replace(/\?\./g, ".");
    if (head === "this") {
      if (tail.startsWith(".args.")) return `@${tail.slice(".args.".length)}`;
      if (tail === "" || tail === ".args") return undefined;
      return `this${tail}`;
    }
    if (this.#rows.has(head!)) return `${head}${tail}`;
    return undefined;
  }

  /**
   * The conditions of the branches around code that read what it reads, which narrow it there
   * as they narrow the source. A member that holds the code reads it under them
   * (`uptime !== undefined ? uptime.toFixed(1) : undefined`): a getter is no branch, so
   * TypeScript would not narrow it otherwise.
   */
  #conditions(code: string, at: object | undefined): string[] {
    const reads = readPaths(code);
    const conditions: string[] = [];
    for (let node = at; node !== undefined; node = this.#parents.get(node)) {
      const branches = (this.#parents.get(node) as IfNode | undefined)?.branches;
      if (!branches || !(branches as readonly object[]).includes(node)) continue;
      const branch = node as IfBranch;
      const own: string[] = [];
      for (const each of branches) {
        if (each === branch) {
          if (each.condition) own.push(this.#condition(each.condition));
          break;
        }
        if (each.condition) own.push(`!(${this.#condition(each.condition)})`);
      }
      for (const condition of own.toReversed()) {
        if (readPaths(condition).some((path) => reads.includes(path)))
          conditions.unshift(condition);
      }
    }
    return conditions;
  }

  /** Whether the template's `{{#if}}` of a condition is a path, or its `{{else}}`. */
  #narrowsAsPath(condition: string): boolean {
    const negated = /^!\((.*)\)$/s.exec(condition)?.[1];
    return this.#path(negated ?? condition) !== undefined;
  }

  #condition(expression: Expression): string {
    return rewriteExpression(expression, this.#component, this.rules, "render");
  }

  /** The member that holds code, declared once for each code and row variables. */
  #hoist(code: string): Hoisted {
    const names = expressionNames(code);
    const parameters: RowVariable[] = [];
    for (const [name, type] of this.#rows) if (names.has(name)) parameters.push({ name, type });
    const key = `${code}\0${parameters.map((each) => `${each.name}:${each.type}`).join(",")}`;
    const found = this.#hoisted.get(key);
    if (found) return found;
    const name = `value${this.#hoisted.size + 1}`;
    const hoisted = { name, parameters };
    this.#hoisted.set(key, hoisted);
    this.#hoistedMembers.push(
      parameters.length
        ? `${name} = (${parameters.map((each) => `${each.name}: ${each.type}`).join(", ")}) => ${code};`
        : `get ${name}() {\n  return ${code};\n}`,
    );
    return hoisted;
  }

  /**
   * Declares a list's row variables for its body, typed from its source: the item is an
   * element of the source's array, the index a number.
   */
  row(source: string, item: string, index: string | undefined, at: object): string {
    const value = this.value(source, true, at);
    const type = this.#typeOf(source, value);
    this.#rows.set(item, `NonNullable<${type}>[number]`);
    if (index !== undefined) this.#rows.set(index, "number");
    return value;
  }

  /** The type of the value the class reads at a Glimmer expression for `code`. */
  #typeOf(code: string, value: string): string {
    const path = this.#path(code);
    if (path !== undefined) return pathType(code, this.#rows);
    const name = /^\(?this\.(value\d+)/.exec(value)?.[1];
    if (name === undefined) throw new Error(`No member holds \`${code}\`.`);
    return value.includes(" ") ? `ReturnType<this["${name}"]>` : `this["${name}"]`;
  }

  /** The code of a class built from parts: one `classNames` call, which skips empty tokens. */
  classCode(parts: readonly ClassPart[]): string {
    this.#helpers.add("classNames");
    return `classNames(${classItems(parts).join(", ")})`;
  }

  /** The code of a style built from parts: one `styleText` call over its declarations. */
  styleCode(parts: readonly StylePart[]): string {
    this.#helpers.add("styleText");
    this.#usesHtmlSafe = true;
    const entries = parts.map((part) => {
      if (part.kind === "Static")
        return `[${JSON.stringify(part.property)}, ${JSON.stringify(part.value)}]`;
      return `[${JSON.stringify(part.property)}, ${part.value}]`;
    });
    return `styleText([${entries.join(", ")}])`;
  }

  rowName(name: string): string {
    return this.#local(name);
  }

  enumerated(): string {
    this.#helpers.add("enumeratedValue");
    return "enumeratedValue";
  }

  parentOf(node: object): object | undefined {
    return this.#parents.get(node);
  }

  /** Raw markup: the string as `htmlSafe` marks it. */
  rawHtml(code: string): string {
    this.#usesHtmlSafe = true;
    return `{{htmlSafe ${this.value(code, true)}}}`;
  }

  /** The module's text. */
  print(): string {
    const component = this.#component;
    const root = component.render.kind === "Element" ? component.render : undefined;
    const markup = printMarkup(component.render, emberDialect(this), {
      level: 2,
      component,
      module: this.#module,
      rewrite: this.rules,
      // Attributes the caller passes land on the root element (`...attributes`).
      scopeRootAttributes: (element) => (element === root ? ["...attributes"] : []),
    });
    const members = this.#propGetters().concat(this.#setupMembers(), this.#hoistedMembers);
    const parts = [this.#imports(members.length > 0)];
    for (const type of this.#types()) parts.push(type);
    parts.push(this.#signature(root?.tag));
    parts.push(this.#declaration(members, `<template>${markup.trimStart()}</template>`));
    for (const name of Array.from(this.#helpers).toSorted()) parts.push(HELPERS[name]);
    return `${parts.join("\n\n")}\n`;
  }

  /** The imports: Glimmer's and Ember's, then the types and the pass-through modules. */
  #imports(isClass: boolean): string {
    const component = this.#component;
    const module = this.#module;
    const lines = [
      isClass
        ? 'import Component from "@glimmer/component";'
        : 'import type { TOC } from "@ember/component/template-only";',
    ];
    if (component.setup.some((item) => item.kind === "State")) {
      lines.push('import { tracked } from "@glimmer/tracking";');
    }
    if (this.#usesHtmlSafe) lines.push('import { htmlSafe } from "@ember/template";');
    const imports = new ImportSet(module.components.map((each) => each.name));
    addTypeImports(component, module, imports, (name) => `${name}.gts`);
    for (const { specifier, names } of passThroughImports(component, module)) {
      if (!names.length) imports.addPassThrough(specifier);
      for (const { imported, local } of names) {
        imports.addPassThrough(specifier, { imported, local: this.#local(local) });
      }
    }
    const declarations = imports.toDeclarations();
    if (declarations.length) lines.push(printProgram(js.program(declarations)).trim());
    return lines.join("\n");
  }

  /** The type declarations the component reaches, and its module's type exports, in order. */
  #types(): string[] {
    const component = this.#component;
    const module = this.#module;
    const types = typeExportsCode(component, module, (name) => `${name}.gts`);
    for (const declaration of componentTypes(component, module)) {
      types.push({ code: typeDeclarationCode(declaration), span: declaration.span });
    }
    return types.toSorted((a, b) => a.span.start - b.span.start).map(({ code }) => code);
  }

  /** `CardSignature`: the props as `Args`, and the root element as `Element`. */
  #signature(root: string | undefined): string {
    const component = this.#component;
    const lines: string[] = [];
    if (component.propsParameter) lines.push(`  Args: ${component.propsParameter.type.code};`);
    if (root !== undefined) lines.push(`  Element: ${elementType(root)};`);
    return `export interface ${component.name}Signature {\n${lines.join("\n")}\n}`;
  }

  /**
   * The component with the source's export shape: a lone default or same-name export in place,
   * any other through an export list. A class when it has members, a `TOC` constant otherwise.
   */
  #declaration(members: readonly string[], template: string): string {
    const { name } = this.#component;
    const signature = `${name}Signature`;
    const exports = exportsOf(name, this.#module.exports);
    const only = exports.length === 1 ? exports[0]! : undefined;
    const isDefault = only?.kind === "default";
    const inPlace = isDefault || only?.name === name;
    const list = inPlace
      ? ""
      : `\n\nexport { ${exports
          .map((entry) => `${name} as ${entry.kind === "default" ? "default" : entry.name}`)
          .join(", ")} };`;
    if (members.length) {
      const keyword = isDefault ? "export default " : inPlace ? "export " : "";
      const body = members.map(indent).join("\n\n");
      return `${keyword}class ${name} extends Component<${signature}> {\n${body}\n\n  ${template}\n}${list}`;
    }
    const constant = `const ${name}: TOC<${signature}> = ${template.replace(/\n {2}/g, "\n")};`;
    if (isDefault) return `${constant}\n\nexport default ${name};`;
    return `${inPlace ? "export " : ""}${constant}${list}`;
  }

  /** A getter for each prop with a default: an absent or `undefined` argument takes it. */
  #propGetters(): string[] {
    return this.#component.props
      .filter((prop) => prop.default)
      .map(
        (prop) =>
          `get ${prop.name}() {\n  return this.args.${prop.name} === undefined ? ${prop.default!.code} : this.args.${prop.name};\n}`,
      );
  }

  /** The setup's declarations as members, in source order. */
  #setupMembers(): string[] {
    const component = this.#component;
    const rules = this.rules;
    return component.setup.flatMap((item) => {
      switch (item.kind) {
        case "State": {
          const name = bindingName(component, item.binding);
          const type = item.type ? `: ${item.type.code}` : "";
          const initial = item.initial
            ? ` = ${rewrite(item.initial, component, rules, "pure")}`
            : "";
          return `@tracked ${name}${type}${initial};`;
        }
        case "Derived": {
          const name = bindingName(component, item.binding);
          const body = functionBodyText(item.getter, component, rules, "pure");
          return `get ${name}()${item.type ? `: ${item.type.code}` : ""} {\n${indent(body)}\n}`;
        }
        case "Const": {
          const name = bindingName(component, item.binding);
          const type = item.type ? `: ${item.type.code}` : "";
          return `readonly ${name}${type} = ${rewrite(item.value, component, rules, "pure")};`;
        }
        case "Variable": {
          const name = bindingName(component, item.binding);
          const type = item.type ? `: ${item.type.code}` : "";
          const initial = item.initial
            ? ` = ${rewrite(item.initial, component, rules, "client")}`
            : "";
          return `${name}${type}${initial};`;
        }
        case "Function": {
          const name = bindingName(component, item.binding);
          return `${name} = ${functionText(item.function, component, rules, "client", { arrow: true })};`;
        }
        // Client code, composition and async setup: capabilities the cells leave unsupported, so
        // the case has no Ember output.
        default:
          return [];
      }
    });
  }
}

function bindingName(component: UfComponent, id: string): string {
  const binding = component.bindings.find((each) => each.id === id);
  if (!binding) throw new Error(`Component ${component.name} declares no binding ${id}.`);
  return binding.name;
}

/**
 * The type of a path's value in the class's terms: `this["args"]["user"]` for `@user`, through
 * `NonNullable` after each `?.`, from a row variable's own type.
 */
function pathType(code: string, rows: ReadonlyMap<string, string>): string {
  const [head, ...segments] = code.replace(/!/g, "").split(/(?=\??\.)/);
  let type = head === "this" ? "this" : rows.get(head!);
  if (type === undefined) throw new Error(`\`${head}\` is no row variable.`);
  for (const segment of segments) {
    const optional = segment.startsWith("?.");
    const name = segment.slice(optional ? 2 : 1);
    type = `${optional ? `NonNullable<${type}>` : type}["${name}"]`;
  }
  return type;
}

/** The element tags of a render tree. */
function tagsOf(root: object): Set<string> {
  const tags = new Set<string>();
  const visit = (value: unknown): void => {
    if (Array.isArray(value)) {
      for (const each of value) visit(each);
      return;
    }
    if (value === null || typeof value !== "object") return;
    if ((value as { kind?: unknown }).kind === "Element") tags.add((value as { tag: string }).tag);
    for (const each of Object.values(value)) visit(each);
  };
  visit(root);
  return tags;
}

/** Every object of a render tree, by the object that holds it. */
function parentsOf(root: object): Map<object, object> {
  const parents = new Map<object, object>();
  const visit = (value: unknown, parent: object | undefined): void => {
    if (Array.isArray(value)) {
      for (const each of value) visit(each, parent);
      return;
    }
    if (value === null || typeof value !== "object") return;
    if (parent) parents.set(value, parent);
    for (const each of Object.values(value)) visit(each, value);
  };
  visit(root, undefined);
  return parents;
}

/** The class's paths code reads: `this.args.uptime`, `this.total`, a row variable. */
function readPaths(code: string): string[] {
  return code.match(/\bthis(?:\.args)?\.[A-Za-z_$][\w$]*|(?<![.\w$])[A-Za-z_$][\w$]*/g) ?? [];
}

/**
 * A class's parts as `classNames` arguments, in source order: static names as string literals,
 * dynamic values as written, and each toggle as a condition that yields its name.
 */
function classItems(parts: readonly ClassPart[]): string[] {
  const items: string[] = [];
  for (const part of parts) {
    if (part.kind === "Static") items.push(JSON.stringify(part.value));
    else if (part.kind === "Dynamic") items.push(part.value);
    else items.push(`(${part.condition}) && ${JSON.stringify(part.name)}`);
  }
  return items;
}

/** The DOM interface of a root element, for the signature's `Element`. */
function elementType(tag: string): string {
  return tag === "svg" ? "SVGSVGElement" : `HTMLElementTagNameMap["${tag}"]`;
}

/** Glimmer's own spelling of a literal, or `undefined` when code is no literal Glimmer has. */
function glimmerLiteral(code: string): string | undefined {
  if (/^(?:true|false|null|undefined)$/.test(code)) return code;
  if (/^-?(?:0|[1-9]\d*)(?:\.\d+)?$/.test(code)) return code;
  // A string without quotes or backslashes inside: Glimmer reads no escapes.
  const string = /^"([^"\\]*)"$/.exec(code) ?? /^'([^'\\]*)'$/.exec(code);
  if (string) return JSON.stringify(string[1]);
  return undefined;
}

function indent(text: string): string {
  return text
    .split("\n")
    .map((line) => (line ? `  ${line}` : line))
    .join("\n");
}

/** The module helpers, after the component. */
const HELPERS = {
  classNames: `/** A class as clsx builds it: strings, arrays and toggle objects, empty tokens left out. */
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
}`,
  enumeratedValue: `/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean" ? (String(value) as "true" | "false") : (value as Exclude<T, boolean>);
}`,
  styleText: `/**
 * A style from its declarations, those whose value is nullish left out, marked safe. A
 * declaration without a property is a whole style: a declaration list, or an object whose keys
 * may be in camel case, as Vue's \`normalizeStyle\` reads them.
 */
function styleText(
  declarations: readonly (readonly [string, unknown])[],
): ReturnType<typeof htmlSafe> | undefined {
  const parts: string[] = [];
  const add = (property: string, value: unknown): void => {
    if (value === undefined || value === null) return;
    if (property) parts.push(\`\${property}: \${String(value)}\`);
    else if (typeof value === "string") parts.push(value.trim().replace(/;$/, ""));
    else if (typeof value === "object") {
      for (const [key, each] of Object.entries(value)) {
        add(key.startsWith("--") ? key : key.replace(/[A-Z]/g, (letter) => \`-\${letter.toLowerCase()}\`), each);
      }
    }
  };
  for (const [property, value] of declarations) add(property, value);
  const text = parts.filter(Boolean).join("; ");
  return text ? htmlSafe(text) : undefined;
}`,
} as const;
