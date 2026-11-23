// A component as a `.gts` module (plan §6): the imports, the copied types, the signature, then a
// template-only component or a `@glimmer/component` class. Glimmer templates hold paths, literals
// and helper calls, never JavaScript, so every other expression the template reads becomes a
// member of the class: a getter, or a function the template calls with the row variables it
// reads (`{{this.label item}}`).
import {
  addTypeImports,
  childImports,
  componentTypes,
  directiveSpecifier,
  exportsOf,
  expressionNames,
  functionBodyText,
  functionText,
  importedDirectives,
  ImportSet,
  keyImports,
  keyOwner,
  parametersText,
  passThroughImports,
  ownDirectives,
  printMarkup,
  printProgram,
  rewriteCode as rewrite,
  rewriteExpression,
  typeDeclarationCode,
  typeExportsCode,
} from "@unframework.dev/codegen";
import type {
  ChildImport,
  ClassPart,
  MarkupPiece,
  EmitContext,
  RewriteRules,
  StylePart,
} from "@unframework.dev/codegen";
import { js } from "@unframework.dev/codegen";
import type {
  Binding,
  BindingReference,
  ComponentNode,
  ElementNode,
  EventAttribute,
  Expression,
  FunctionCode,
  IfBranch,
  IfNode,
  InjectionKeyDeclaration,
  ListenerAttribute,
  Code,
  ModelAttribute,
  Prop,
  RenderNode,
  SlotFill,
  SlotOutletNode,
  Span,
  TypeDeclaration,
  UfComponent,
  UfModule,
} from "@unframework.dev/ir";

import { emberDialect } from "./dialect.ts";
import { DIRECTIVE_IMPORTS, directiveDeclaration, directiveHelpers } from "./directive.ts";
import { moduleReads } from "./modules.ts";
import type { ModuleReads } from "./modules.ts";

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

/** What a hoisted member holds: a value the template reads, or a listener `{{on}}` takes. */
type HoistedKind = "value" | "listener" | "initial";

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
  /** How many members of each kind the template's expressions became. */
  readonly #counts: Record<HoistedKind, number> = { value: 0, listener: 0, initial: 0 };
  /** The printed members the template's expressions became, in template order. */
  readonly #hoistedMembers: string[] = [];
  /** Each row variable's type, by name, for the lists printed so far. */
  readonly #rows = new Map<string, string>();
  /** The list each row variable belongs to, by name. */
  readonly #rowLists = new Map<string, object>();
  /** The module helpers the members call. */
  readonly #helpers = new Set<HelperName>();
  #usesHtmlSafe = false;
  /** What the template calls before anything else: each watcher's `flush`. */
  readonly #before: string[] = [];
  /** What the template calls after everything else: each effect's `flush`, then the hooks. */
  readonly #after: string[] = [];
  /** Whether the setup holds a `watchEffect`, which runs again when what it reads notifies. */
  get #hasEffects(): boolean {
    return this.#component.setup.some((item) => item.kind === "WatchEffect");
  }
  /** What each scoped fill's name reads: its block param, or a key of it (`fills`). */
  readonly #slotScope = new Map<string, string>();
  /** The children whose signature a scoped fill's block param is typed by, by name. */
  readonly #signatures = new Map<string, ChildImport>();
  /** Whether the setup provides, and whether it injects (`provide`, `inject`). */
  readonly #provides: boolean;
  readonly #injects: boolean;
  /** The children the template renders, by the name it writes them with. */
  readonly #children: ReadonlyMap<string, ChildImport>;
  /** The events interface of each child an inline handler listens to, by the child's name. */
  readonly #eventTypes = new Map<string, { specifier: string; name: string; self: boolean }>();
  /** The tags the template writes. */
  readonly #tags: ReadonlySet<string>;
  /** Each node of the template, branch included, by what holds it. */
  readonly #parents: ReadonlyMap<object, object>;

  constructor(component: UfComponent, module: UfModule) {
    this.#component = component;
    this.#parents = parentsOf(component.render);
    this.#tags = tagsOf(component.render);
    this.#module = module;
    this.#children = new Map(
      childImports(component, module, (name) => `${name}.gts`).map((each) => [each.local, each]),
    );
    this.#provides = component.setup.some((item) => item.kind === "Provide");
    this.#injects = component.setup.some((item) => item.kind === "Inject");
  }

  /** How the class spells a reference to a binding: the same for every site. */
  get component(): UfComponent {
    return this.#component;
  }

  get rules(): RewriteRules {
    return {
      binding: (reference, binding) => this.#spell(reference, binding),
      import: (reference) => this.#local(reference.name),
      // Whether the parent filled a slot is a template keyword, `(has-block "title")`: a marker
      // that `value` writes as it.
      slot: (reference) => `${HAS_BLOCK}${reference.slot}__`,
      // Vue's `nextTick` resolves once its pending flush has run: Ember's is `renderSettled`.
      api: () => {
        this.#helpers.add("renderSettled");
        return "renderSettled";
      },
      // A parent listens to an event through an argument, `@onChange`, as Ember passes actions.
      emit: (emit, _binding, parts) =>
        `this.args.${eventArgument(emit.event)}?.(${parts.arguments.join(", ")})`,
    };
  }

  /**
   * A form control's `v-model`, as Vue's directives bind each control: the state shown through
   * the control's property, and a listener that writes it back. A field with a modifier, or a
   * number field, goes through `modelText`, Vue's `vModelText`.
   */
  model(attribute: ModelAttribute, value: string, element: ElementNode): string[] {
    const write = (code: string, parameters = "") =>
      this.#listener(`(${parameters}) => {\n  ${value} = ${code};\n}`, element);
    const target = (type: string, property: string) =>
      `(event.currentTarget as ${type}).${property}`;
    if (attribute.trim || attribute.lazy || attribute.number || attribute.control === "number") {
      this.#helpers.add("modelText");
      const setter = this.#listener(`(next: typeof ${value}) => {\n  ${value} = next;\n}`, element);
      const options = [
        attribute.trim ? " trim=true" : "",
        attribute.lazy ? " lazy=true" : "",
        attribute.number || attribute.control === "number" ? " number=true" : "",
      ].join("");
      // The first value, which the server renders: `modelText` shows the next ones.
      const initial = this.#hoist(value, "initial", element);
      return [
        `value={{this.${initial.name}}}`,
        `{{modelText ${this.value(value, true, element)} ${setter}${options}}}`,
      ];
    }
    switch (attribute.control) {
      case "text":
      case "textarea":
        return [
          `value={{${this.value(value, false, element)}}}`,
          `{{on "input" ${write(target(element.tag === "textarea" ? "HTMLTextAreaElement" : "HTMLInputElement", "value"), "event: Event")}}}`,
        ];
      case "checkbox":
        return [
          `checked={{${this.value(value, false, element)}}}`,
          `{{on "change" ${write(target("HTMLInputElement", "checked"), "event: Event")}}}`,
        ];
      case "radio": {
        const own = ownValue(element, this);
        return [
          `checked={{${this.value(`${value} === ${own}`, false, element)}}}`,
          `{{on "change" ${write(own)}}}`,
        ];
      }
      case "checkbox-group": {
        this.#helpers.add("toggle");
        const own = ownValue(element, this);
        return [
          `checked={{${this.value(`${value}.includes(${own})`, false, element)}}}`,
          `{{on "change" ${write(`toggle(${value}, ${own}, ${target("HTMLInputElement", "checked")})`, "event: Event")}}}`,
        ];
      }
      // Each option is `selected` where it holds the state (`optionSelected`), which the server
      // renders too.
      case "select":
        return [`{{on "change" ${write(target("HTMLSelectElement", "value"), "event: Event")}}}`];
      case "select-multiple":
        return [
          `{{on "change" ${write(`Array.from(${target("HTMLSelectElement", "selectedOptions")}, (option) => option.value)`, "event: Event")}}}`,
        ];
      default:
        return attribute.control satisfies never;
    }
  }

  /** Whether an option of a `v-model`'s `<select>` holds the state: see the dialect. */
  optionSelected(element: ElementNode, value: string): string {
    let select: ElementNode | undefined;
    for (let node = this.#parents.get(element); node; node = this.#parents.get(node)) {
      if ((node as ElementNode).kind === "Element" && (node as ElementNode).tag === "select") {
        select = node as ElementNode;
        break;
      }
    }
    const model = select?.attributes.find((each): each is ModelAttribute => each.kind === "Model");
    if (!model) return "";
    const state = rewriteExpression(model.value, this.#component, this.rules, "render");
    const test =
      model.control === "select-multiple"
        ? `${state}.includes(${value})`
        : `String(${state}) === ${value}`;
    return ` selected={{${this.value(test, false, element)}}}`;
  }

  /** A listener's member for code, called with the row variables it reads. */
  #listener(code: string, at: object): string {
    const { name, parameters } = this.#hoist(code, "listener", at);
    if (!parameters.length) return `this.${name}`;
    return `(this.${name} ${parameters.map((each) => each.name).join(" ")})`;
  }

  /** The handler a template ref's modifier is given: the member that holds the element. */
  templateRef(name: string): string {
    this.#helpers.add("templateRef");
    return `{{templateRef this "${name}"}}`;
  }

  /** A directive's modifier on its element, with the value it takes (`directive`). */
  directive(name: string, value: string, element: ElementNode): string {
    return `{{${this.#local(name)} ${this.value(value, true, element, true)}}}`;
  }

  /**
   * The name a module value or a row variable takes in the template's scope. Glimmer reads a tag
   * named like a name in scope as that component (`<button>` with `button` imported), so a name
   * the template also writes as a tag takes another.
   */
  #local(name: string): string {
    const taken = (each: string) => this.#tags.has(each) || KEYWORDS.has(each);
    if (!taken(name)) return name;
    let local = `${name}_1`;
    for (let n = 2; taken(local); n++) local = `${name}_${n}`;
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
      // A scoped fill's name: a key of the props object its block param holds (`fills`).
      case "slotScope": {
        const path = this.#slotScope.get(binding.id);
        if (path === undefined) throw new Error(`No fill declares \`${binding.name}\`.`);
        return path;
      }
      case "state":
      case "derived":
      case "localConst":
      case "localFn":
      case "localVar":
        return `this.${binding.name}`;
      case "moduleConst":
      case "import":
      case "component":
        return binding.name;
      // A cached getter that reads the nearest provider's value (`#setupMembers`). The
      // reference to a key of a ref is the whole `count.value`.
      case "context": {
        const item = this.#component.setup.find(
          (each) => each.kind === "Inject" && each.binding === binding.id,
        );
        const ref = item?.kind === "Inject" && this.#key(item.key).ref;
        return ref ? `this.${binding.name}.value` : `this.${binding.name}`;
      }
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
  value(code: string, subexpression: boolean, at?: object, typed = false): string {
    const literal = glimmerLiteral(code);
    if (literal !== undefined) return literal;
    const presence = new RegExp(`^(!?)${HAS_BLOCK}(\\w+)__$`).exec(code);
    if (presence) {
      const test = presence[2] === "default" ? "has-block" : `has-block "${presence[2]}"`;
      return presence[1] ? `(not (${test}))` : subexpression ? `(${test})` : test;
    }
    if (code.includes(HAS_BLOCK)) {
      throw new Error(
        `The ember target tests a slot's presence only as a whole condition: \`${code}\`.`,
      );
    }
    const conditions = this.#conditions(code, at);
    const path = this.#path(code);
    // Glint narrows a path under `{{#if}}` of a path, as TypeScript narrows the source; under any
    // other condition, a member reads the path under that condition.
    if (path !== undefined && conditions.every((each) => this.#narrowsAsPath(each))) return path;
    // Where a type checks the value, a child's argument, the other side is never read: the
    // branch holds wherever the template reads it.
    const otherwise = typed ? "(undefined as never)" : "undefined";
    const guarded = conditions.length
      ? `${conditions.map((each) => `(${each})`).join(" && ")} ? ${code} : ${otherwise}`
      : code;
    const { name, parameters } = this.#hoist(guarded, "value", at);
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
  #hoist(
    code: string,
    kind: HoistedKind,
    at: object | undefined,
    own: ReadonlySet<string> = new Set(),
  ): Hoisted {
    const names = expressionNames(code);
    const parameters: RowVariable[] = [];
    for (const [name, type] of this.#rows) {
      if (names.has(name) && !own.has(name) && this.#inList(name, at)) {
        parameters.push({ name, type });
      }
    }
    const key = `${kind}\0${code}\0${parameters.map((each) => `${each.name}:${each.type}`).join(",")}`;
    const found = this.#hoisted.get(key);
    if (found) return found;
    const name = `${kind}${++this.#counts[kind]}`;
    const hoisted = { name, parameters };
    this.#hoisted.set(key, hoisted);
    const list = parameters.map((each) => `${each.name}: ${each.type}`).join(", ");
    // An arrow's object literal is parenthesised, or it reads as the arrow's block.
    const body = code.trimStart().startsWith("{") ? `(${code})` : code;
    // A listener is a field, so `{{on}}` gets the same function at each render, bound to the
    // instance. A value is a getter, which Glimmer reads again when what it reads changes.
    this.#hoistedMembers.push(
      parameters.length
        ? `${name} = (${list}) => ${body};`
        : kind === "listener"
          ? `${name} = ${code};`
          : kind === "initial"
            ? `readonly ${name} = ${code};`
            : `get ${name}() {\n  return ${code};\n}`,
    );
    return hoisted;
  }

  /** Whether a row variable is in scope at a node: the node is in its list. */
  #inList(name: string, at: object | undefined): boolean {
    const list = this.#rowLists.get(name);
    if (at === undefined || list === undefined) return true;
    for (let node: object | undefined = at; node !== undefined; node = this.#parents.get(node)) {
      if (node === list) return true;
    }
    return false;
  }

  /**
   * The handler of a listener: the setup function it names, or a member that holds the inline
   * one, called with the row variables it reads (`{{on "click" (this.listener1 item)}}`).
   */
  listener(attribute: EventAttribute, at: object): string {
    const { handler } = attribute;
    if (handler.kind === "Function") return `this.${bindingName(this.#component, handler.binding)}`;
    const fn = typedEvent(handler.function, `HTMLElementEventMap["${attribute.event}"]`);
    return this.#inline(fn, at);
  }

  /**
   * A component's fills (ADR-0054): the default slot's children between its tags, or each slot
   * as a named block, `<:header>…</:header>`, once any named one is there. A scoped fill takes
   * the props object as a block param, `as |slotProps|`, whose keys its names read.
   */
  fills(fills: readonly SlotFill[], node: ComponentNode): MarkupPiece[] {
    const named = fills.some((fill) => fill.slot !== "default" || fill.parameter !== undefined);
    return fills.map((fill): MarkupPiece => {
      if (fill.forward !== undefined) {
        throw new Error("The ember target does not forward a slot yet.");
      }
      const content: MarkupPiece = { kind: "nodes", nodes: fill.children, container: fill };
      if (!named) return content;
      const params = fill.parameter ? ` as |${this.#scope(fill, node)}|` : "";
      return {
        kind: "block",
        segments: [{ open: `<:${fill.slot}${params}>`, content }],
        close: `</:${fill.slot}>`,
      };
    });
  }

  /**
   * Declares a scoped fill's names: its block param holds the props object, which a getter takes
   * as a row variable, typed by the child's `Blocks`.
   */
  #scope(fill: SlotFill, node: ComponentNode): string {
    const parameter = fill.parameter!;
    const child = this.#children.get(node.component);
    if (!child) throw new Error(`No output imports \`${node.component}\`.`);
    this.#signatures.set(child.local, child);
    const param = this.#local(parameter.name ?? `${fill.slot}Props`);
    this.#rows.set(param, `${child.name}Signature["Blocks"]["${fill.slot}"][0]`);
    this.#rowLists.set(param, fill);
    const { start, end } = parameter.span;
    const keys = parameter.pattern
      ? patternKeys(parameter.pattern.code)
      : new Map<string, string>();
    for (const binding of this.#component.bindings) {
      if (binding.kind !== "slotScope") continue;
      const offset = Number(binding.id.slice(binding.id.lastIndexOf("@") + 1));
      if (offset < start || offset > end) continue;
      const key = keys.get(binding.name) ?? binding.name;
      const member = /^[A-Za-z_$][\w$]*$/.test(key) ? `.${key}` : `[${JSON.stringify(key)}]`;
      this.#slotScope.set(binding.id, parameter.pattern ? `${param}${member}` : param);
    }
    return param;
  }

  /**
   * A slot outlet (ADR-0054): `{{yield}}`, a named slot's `{{yield to="header"}}`, with a scoped
   * slot's props object as its value, and the fallback where the parent left it empty.
   */
  slotOutlet(node: SlotOutletNode, props: string | undefined): MarkupPiece[] {
    const value = props === undefined ? "" : ` ${this.value(props, true, node)}`;
    const to = node.slot === "default" ? "" : ` to="${node.slot}"`;
    const outlet: MarkupPiece = { kind: "code", code: `{{yield${value}${to}}}` };
    if (!node.fallback.length) return [outlet];
    return [
      {
        kind: "block",
        segments: [
          {
            open:
              node.slot === "default"
                ? "{{#if (has-block)}}"
                : `{{#if (has-block "${node.slot}")}}`,
            content: outlet,
          },
          { open: "{{else}}", content: { kind: "nodes", nodes: node.fallback, container: node } },
        ],
        close: "{{/if}}",
      },
    ];
  }

  /**
   * The handler of a child's event (ADR-0053): the setup function it names, or a member that
   * holds the inline one, its parameters typed by the child's events (`FieldEvents`).
   */
  componentListener(attribute: ListenerAttribute, node: ComponentNode): string {
    const { handler } = attribute;
    if (handler.kind === "Function") return `this.${bindingName(this.#component, handler.binding)}`;
    const child = this.#children.get(node.component);
    if (!child) throw new Error(`No output imports \`${node.component}\`.`);
    const events = `${child.name}Events`;
    this.#eventTypes.set(child.local, {
      specifier: child.specifier,
      name: events,
      self: child.self,
    });
    return this.#inline(
      handler.function,
      node,
      `NonNullable<${events}["${eventArgument(attribute.event)}"]>`,
    );
  }

  /**
   * A member that holds an inline handler, called with the row variables it reads. `type`
   * types its parameters, through \`satisfies\`, where the source leaves them to the context.
   */
  #inline(fn: FunctionCode, at: object, type?: string): string {
    let code = functionText(fn, this.#component, this.rules, "client");
    // The branches around the listener narrow what it reads in the source, which a field does
    // not: it tests them again, as they hold whenever its element is rendered.
    const conditions = this.#conditions(code, at);
    if (conditions.length) {
      const body = functionBodyText(fn, this.#component, this.rules, "client");
      const test = conditions.map((each) => `(${each})`).join(" && ");
      code = `${fn.async ? "async " : ""}(${parametersText(fn)}) => {\n  if (!(${test})) return;\n${indent(body)}\n}`;
    }
    if (type !== undefined) code = `(${code}) satisfies ${type}`;
    const own = new Set(fn.parameters.flatMap((each) => each.name ?? each.pattern?.names ?? []));
    const { name, parameters } = this.#hoist(code, "listener", at, own);
    if (!parameters.length) return `this.${name}`;
    return `(this.${name} ${parameters.map((each) => each.name).join(" ")})`;
  }

  /**
   * Declares a list's row variables for its body, typed from its source: the item is an
   * element of the source's array, the index a number.
   */
  row(source: string, item: string, index: string | undefined, at: object): string {
    const value = this.value(source, true, at);
    const type = this.#typeOf(source, value);
    this.#rows.set(item, `NonNullable<${type}>[number]`);
    this.#rowLists.set(item, at);
    if (index !== undefined) {
      this.#rows.set(index, "number");
      this.#rowLists.set(index, at);
    }
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
    const roots = rootElements(component).spans;
    const isRoot = (element: ElementNode) =>
      roots.some(({ start, end }) => element.span.start === start && element.span.end === end);
    const markup = printMarkup(component.render, emberDialect(this), {
      level: 2,
      component,
      module: this.#module,
      rewrite: this.rules,
      // Attributes the caller passes land on the root element (`...attributes`), or on each one a
      // root conditional or `<component is>` may render.
      scopeRootAttributes: (element) => (isRoot(element) ? ["...attributes"] : []),
      // The provider's marker comes first in the root, so the root's descendants find it, and
      // no sibling of the root does (`provider`).
      childrenWrapper: (element) =>
        element === root && this.#provides
          ? { open: "{{this.providerMarker}}", close: "" }
          : undefined,
    });
    const members = this.#propGetters().concat(this.#setupMembers(), this.#hoistedMembers);
    const own = ownDirectives(component, this.#module);
    if (own.length) this.#helpers.add("directive");
    const { text: imports, reads } = this.#imports(members);
    const parts = [imports];
    for (const type of this.#types(reads.types)) parts.push(type);
    // The module's values it reads, as the source declares them (ADR-0070).
    if (reads.constants.length) parts.push(reads.constants.join("\n"));
    // The module's own directives it applies, each a modifier (ADR-0099).
    for (const directive of own) parts.push(directiveDeclaration(directive));
    parts.push(this.#signature(rootElements(component).tags));
    // A consumer's marker comes first, outside what the component provides itself (`inject`).
    const marker = this.#injects ? "{{this.injectionMarker}}" : "";
    const template = `<template>${marker}${this.#before.join("")}${markup.trimStart()}${this.#after.join("")}</template>`;
    parts.push(this.#declaration(members, template));
    for (const name of Array.from(this.#helpers).toSorted()) {
      if (HELPERS[name]) parts.push(HELPERS[name]);
    }
    return `${parts.join("\n\n")}\n`;
  }

  /**
   * What `provide` gives or `inject` falls back to under a key: for a key that holds a ref, a
   * state as its ref, `{ value }` read from the tracked field as the state changes (`refOf`).
   */
  #contextValue(key: string, code: Code): string {
    const value = rewrite(code, this.#component, this.rules, "pure");
    const [ref] = code.refs;
    const whole =
      code.refs.length === 1 &&
      ref?.kind === "Binding" &&
      ref.span.start === code.span.start &&
      ref.span.end === code.span.end;
    if (!this.#key(key).ref || !whole) return value;
    this.#helpers.add("refOf");
    return `refOf(() => ${value})`;
  }

  /**
   * A key the setup names: its value's type in the class's terms, a ref's as `{ value }`, with
   * the module its type's names are imported from, for a key of another module.
   */
  #key(local: string): { type: string; ref: boolean; specifier?: string; names: string[] } {
    const module = this.#module;
    const own = module.keys?.find((key) => key.name === local);
    if (own)
      return { type: keyValueType(own.type.code, own.ref), ref: own.ref !== undefined, names: [] };
    const imported = keyImports(this.#component, module, (name) => `${name}.gts`).find(
      (key) => key.local === local,
    );
    for (const entry of module.imports ?? []) {
      const name = entry.names.find((each) => each.kind === "Key" && each.local === local);
      const api = name && entry.api.keys?.find((key) => key.name === name.imported);
      if (!api) continue;
      return {
        type: keyValueType(api.type, api.ref),
        ref: api.ref !== undefined,
        ...(imported?.specifier ? { specifier: imported.specifier } : {}),
        // A ref's type is the source's (`Ref<number>`), which the output writes as `{ value }`.
        names: (api.references ?? []).filter((each) => !api.ref || each !== api.ref),
      };
    }
    throw new Error(`No module declares the key \`${local}\`.`);
  }

  /** The imports: Glimmer's and Ember's, then the types and the pass-through modules. */
  #imports(members: readonly string[]): { text: string; reads: ModuleReads } {
    const isClass = members.length > 0;
    const component = this.#component;
    const module = this.#module;
    const lines = [
      isClass
        ? 'import Component from "@glimmer/component";'
        : 'import type { TOC } from "@ember/component/template-only";',
    ];
    const tracking = [];
    if (this.#injects || this.#provides) tracking.push("cached");
    if (
      component.setup.some((item) => item.kind === "State" || item.kind === "TemplateRef") ||
      this.#helpers.has("Effect")
    ) {
      tracking.push("tracked");
    }
    if (tracking.length) {
      lines.push(`import { ${tracking.join(", ")} } from "@glimmer/tracking";`);
    }
    if (this.#usesHtmlSafe) lines.push('import { htmlSafe } from "@ember/template";');
    const ember = new Map<string, Set<string>>();
    for (const helper of this.#helpers) {
      for (const [specifier, names] of Object.entries(HELPER_IMPORTS[helper])) {
        const set = ember.get(specifier) ?? new Set<string>();
        for (const name of names) set.add(name);
        ember.set(specifier, set);
      }
    }
    for (const specifier of Array.from(ember.keys()).toSorted()) {
      const names = Array.from(ember.get(specifier)!).toSorted();
      const types = names.filter((name) => name.startsWith("type "));
      if (types.length === names.length) {
        lines.push(
          `import type { ${types.map((name) => name.slice(5)).join(", ")} } from "${specifier}";`,
        );
      } else lines.push(`import { ${names.join(", ")} } from "${specifier}";`);
    }
    const imports = new ImportSet(module.components.map((each) => each.name));
    addTypeImports(component, module, imports, (name) => `${name}.gts`);
    const reads = moduleReads(component, module, imports);
    // Each child's output, a sibling `.gts` file, under the source's name (ADR-0053).
    for (const child of this.#children.values()) {
      if (child.self) continue;
      if (child.export === "default")
        imports.addDefault(child.specifier, child.local, { exact: true });
      else imports.add(child.specifier, child.name, { local: child.local, exact: true });
    }
    // Each directive of a `.uf.ts` module, from its own module beside it, `vFocusTrap.ts`.
    for (const { specifier, imported, local } of importedDirectives(component, module)) {
      imports.add(directiveSpecifier(specifier, `${imported}.ts`), imported, {
        local,
        exact: true,
      });
    }
    // The keys of other modules, from their main component's output (ADR-0054).
    for (const key of keyImports(component, module, (name) => `${name}.gts`)) {
      if (!key.specifier) continue;
      imports.add(key.specifier, key.name, { local: key.local, exact: true });
      // The names an injected value's type reads, which its getter is typed by.
      const injected = component.setup.some(
        (item) => item.kind === "Inject" && item.key === key.local,
      );
      if (!injected) continue;
      for (const name of this.#key(key.local).names) {
        imports.add(key.specifier, name, { type: true, exact: true });
      }
    }
    for (const { specifier, name, self } of this.#eventTypes.values()) {
      if (!self) imports.add(specifier, name, { type: true, exact: true });
    }
    // A child's signature, where a member's row variable is typed by its `Blocks`.
    const read = members.join("\n");
    for (const child of this.#signatures.values()) {
      if (!child.self && read.includes(`${child.name}Signature[`)) {
        imports.add(child.specifier, `${child.name}Signature`, { type: true, exact: true });
      }
    }
    for (const { specifier, names } of passThroughImports(component, module)) {
      if (!names.length) imports.addPassThrough(specifier);
      for (const { imported, local } of names) {
        imports.addPassThrough(specifier, { imported, local: this.#local(local) });
      }
    }
    const declarations = imports.toDeclarations();
    // The sheet `compile()` writes beside the source, already scoped (ADR-0063): the markup
    // printer gives each element the sheet's `data-uf-…` attribute.
    if (component.styles) {
      const file = module.file;
      declarations.push(js.importDeclaration(`./${file.slice(file.lastIndexOf("/") + 1)}.css`, []));
    }
    if (declarations.length) lines.push(printProgram(js.program(declarations)).trim());
    return { text: lines.join("\n"), reads };
  }

  /** The type declarations the component reaches, and its module's type exports, in order. */
  #types(reached: readonly TypeDeclaration[]): string[] {
    const component = this.#component;
    const module = this.#module;
    const types = typeExportsCode(component, module, (name) => `${name}.gts`);
    for (const declaration of componentTypes(component, module).concat(reached)) {
      types.push({ code: typeDeclarationCode(declaration), span: declaration.span });
    }
    if (keyOwner(module.components, module.exports) === component.name) {
      for (const key of module.keys ?? [])
        types.push({ code: keyDeclaration(key), span: key.span });
    }
    return types.toSorted((a, b) => a.span.start - b.span.start).map(({ code }) => code);
  }

  /**
   * `CardSignature`: the props and the events' arguments as `Args`, and the root element as
   * `Element`. The events are an interface of their own, `CardEvents`, each an optional argument
   * named by {@link eventArgument} that takes the event's payload.
   */
  #signature(roots: readonly string[]): string {
    const component = this.#component;
    const { emits } = component;
    const args: string[] = [];
    if (component.propsParameter) args.push(component.propsParameter.type.code);
    let events = "";
    if (emits) {
      const name = `${component.name}Events`;
      const members = emits.events.map((event) => {
        const parameters = event.parameters
          .map((each) => `${each.name}${each.optional ? "?" : ""}: ${each.type.code}`)
          .join(", ");
        return `  ${eventArgument(event.name)}?: (${parameters}) => void;`;
      });
      events = `export interface ${name} {\n${members.join("\n")}\n}\n\n`;
      args.push(name);
    }
    const lines: string[] = [];
    if (args.length) lines.push(`  Args: ${args.join(" & ")};`);
    // Each slot a block, which yields a scoped slot's props object.
    if (component.slots) {
      const blocks = component.slots.slots.map(
        (slot) => `    ${slot.name}: [${slot.props ? `props: ${slot.props.code}` : ""}];`,
      );
      lines.push(`  Blocks: {\n${blocks.join("\n")}\n  };`);
    }
    if (roots.length) lines.push(`  Element: ${roots.map(elementType).join(" | ")};`);
    return `${events}export interface ${component.name}Signature {\n${lines.join("\n")}\n}`;
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

  /** The setup's declarations as members, in source order, then the lifecycle hooks. */
  #setupMembers(): string[] {
    const component = this.#component;
    const rules = this.rules;
    const hooks: string[] = [];
    /** What the setup provides, as `[key, value]` entries. */
    const provided: string[] = [];
    // The functions come first: a field's value may call one the source declares after it, as
    // the source's function declarations are hoisted.
    const functions: string[] = [];
    let watchers = 0;
    let effects = 0;
    const members = component.setup.flatMap((item) => {
      switch (item.kind) {
        // A template ref is tracked, as Vue's is reactive: `templateRef` sets it once its element
        // is rendered, and sets it to `null` once it is gone.
        case "TemplateRef": {
          const name = bindingName(component, item.binding);
          return `@tracked ${name}: ${item.type?.code ?? "Element"} | null = null;`;
        }
        // `uniqueId` gives each call an id unique to the application, so each instance's differ.
        case "Id": {
          this.#helpers.add("uniqueId");
          return `readonly ${bindingName(component, item.binding)} = \`uf-id-\${uniqueId()}\`;`;
        }
        case "Watch": {
          this.#helpers.add("Watcher");
          this.#helpers.add("callbacks");
          const name = `watcher${++watchers}`;
          this.#before.push(`{{(this.${name}.flush)}}`);
          const reads = item.sources.map((source) =>
            source.kind === "Ref"
              ? `this.${bindingName(component, source.binding)}`
              : functionText(source.getter, component, rules, "pure"),
          );
          let source: string;
          if (item.array) {
            this.#helpers.add("sources");
            const values = item.sources.map((each, index) =>
              each.kind === "Ref" ? reads[index]! : `(${reads[index]!})()`,
            );
            source = `() => sources(${values.join(", ")})`;
          } else {
            source = item.sources[0]!.kind === "Ref" ? `() => ${reads[0]!}` : reads[0]!;
          }
          const callback = functionText(item.callback, component, rules, "client");
          const options = [
            item.array ? "array: true" : "",
            item.immediate ? "immediate: true" : "",
            item.post ? "post: true" : "",
          ].filter(Boolean);
          const rest = options.length ? `, { ${options.join(", ")} }` : "";
          return `readonly ${name} = new Watcher(this, ${source}, ${callback}${rest});`;
        }
        case "WatchEffect": {
          this.#helpers.add("Effect");
          this.#helpers.add("callbacks");
          const name = `effect${++effects}`;
          this.#after.push(`{{(this.${name}.flush)}}`);
          const effect = functionText(item.effect, component, rules, "client");
          return `readonly ${name} = new Effect(this, ${effect});`;
        }
        // Each hook runs once the first render settles, unless the component is gone by then,
        // as a server render is; an `onUnmounted` hook is registered then, so it never runs on
        // the server either.
        case "Lifecycle": {
          this.#helpers.add("afterRender");
          const hook = functionText(item.callback, component, rules, "client");
          hooks.push(
            item.hook === "mounted"
              ? `afterRender(this, ${hook});`
              : `afterRender(this, () => registerDestructor(this, ${hook}));`,
          );
          if (item.hook === "unmounted") this.#helpers.add("registerDestructor");
          return [];
        }
        // Each provided value is read once, as Vue's `provide` reads it, and a provided state is
        // its ref, `{ value }` over the tracked field (`provider`).
        case "Provide": {
          provided.push(`[${this.#local(item.key)}, ${this.#contextValue(item.key, item.value)}]`);
          return [];
        }
        // Read once, as Vue's `inject` reads it at setup: the template reads it after the
        // marker, which is in the DOM by then (`inject`).
        case "Inject": {
          this.#helpers.add("inject");
          const name = bindingName(component, item.binding);
          const key = this.#key(item.key);
          const fallback = item.fallback
            ? this.#contextValue(item.key, item.fallback)
            : "undefined";
          const type = item.fallback ? key.type : `${key.type} | undefined`;
          return `@cached\nget ${name}(): ${type} {\n  return inject(this.injectionMarker, ${this.#local(item.key)}, ${fallback});\n}`;
        }
        case "State": {
          const name = bindingName(component, item.binding);
          // A state without a value holds `undefined`, as `ref<T>()` does, typed `T | undefined`.
          // A write of the value it holds notifies nothing, as Vue's does: an effect would run.
          const type = item.type ? `: ${item.type.code}${item.initial ? "" : " | undefined"}` : "";
          const initial = item.initial
            ? rewrite(item.initial, component, rules, "pure")
            : "undefined";
          const decorator = this.#hasEffects ? "@tracked({ equals: Object.is })" : "@tracked";
          return `${decorator} ${name}${type} = ${initial};`;
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
          const fn = typedEvent(item.function);
          functions.push(
            `${name} = ${functionText(fn, component, rules, "client", { arrow: true })};`,
          );
          return [];
        }
        // Composition and async setup: capabilities the cells leave unsupported, so the case
        // has no Ember output.
        default:
          return [];
      }
    });
    if (this.#injects) members.unshift('readonly injectionMarker = document.createTextNode("");');
    // Read when the template renders the marker, after the component's own `inject` can find
    // what it reads, as Vue's setup injects before it provides.
    if (provided.length) {
      this.#helpers.add("provider");
      members.push(
        `@cached\nget providerMarker(): Text {\n  return provider([${provided.join(", ")}]);\n}`,
      );
    }
    if (hooks.length) {
      this.#after.push("{{(this.onMounted)}}");
      members.push(
        "#mounted = false;",
        `/** Called at the template's end: the hooks run once the component has rendered. */\nonMounted = (): undefined => {\n  if (!this.#mounted) {\n    this.#mounted = true;\n${hooks.map((each) => indent(indent(each))).join("\n")}\n  }\n  return undefined;\n};`,
      );
    }
    return functions.concat(members);
  }
}

/** An injection key (ADR-0054): the source's symbol, which `provider` and `inject` match. */
function keyDeclaration(key: InjectionKeyDeclaration): string {
  return `export const ${key.name} = Symbol(${JSON.stringify(key.description)});`;
}

/** A key's value type: a ref's (`Ref<number>`) as `{ readonly value: number }`. */
function keyValueType(type: string, ref: string | undefined): string {
  if (!ref) return type;
  const inner = /^\w+<([\s\S]*)>$/.exec(type.trim())?.[1];
  return `{ readonly value: ${inner ?? "unknown"} }`;
}

/**
 * A handler with its event parameter typed, which a class member cannot leave to the template
 * to infer: as `on` passes it (`HTMLElementEventMap["click"]`), or as the analyzer reads it.
 */
function typedEvent(fn: FunctionCode, type?: string): FunctionCode {
  if (!fn.parameters.some((each) => each.event !== undefined && each.type === undefined)) return fn;
  return {
    ...fn,
    parameters: fn.parameters.map((each) =>
      each.event !== undefined && each.type === undefined
        ? { ...each, type: { code: type ?? each.event, span: each.span } }
        : each,
    ),
  };
}

/**
 * The keywords of Ember's strict-mode templates that are identifiers: a name of the template's
 * scope takes another, so that the template, and the tools that read it, never confuse the two.
 */
const KEYWORDS: ReadonlySet<string> = new Set([
  "action",
  "and",
  "array",
  "component",
  "concat",
  "debugger",
  "each",
  "eq",
  "fn",
  "get",
  "gt",
  "gte",
  "hash",
  "helper",
  "if",
  "let",
  "log",
  "lt",
  "lte",
  "modifier",
  "mount",
  "mut",
  "neq",
  "not",
  "on",
  "or",
  "outlet",
  "unbound",
  "unless",
  "with",
  "yield",
]);

/** A checkbox's or a radio's own value: its `value` attribute, or `"on"`, as the DOM's. */
function ownValue(element: ElementNode, plan: ComponentPlan): string {
  for (const attribute of element.attributes) {
    if (attribute.kind === "Static" && attribute.name === "value") {
      return JSON.stringify(attribute.value === true ? "" : attribute.value);
    }
    if (attribute.kind === "Bound" && attribute.name === "value") {
      return `(${rewriteExpression(attribute.value, plan.component, plan.rules, "render")})`;
    }
  }
  return '"on"';
}

/** The marker of a slot's presence in code, which `value` writes as `(has-block "…")`. */
const HAS_BLOCK = "__ufHasBlock_";

/**
 * The key each name of a destructuring pattern reads: `{ item, index: position }` gives `item`
 * for `item` and `index` for `position`.
 */
function patternKeys(code: string): Map<string, string> {
  const keys = new Map<string, string>();
  const inner = code.trim().replace(/^\{|\}$/g, "");
  for (const entry of inner.split(",")) {
    const match =
      /^\s*(?:([A-Za-z_$][\w$]*)|"([^"]*)"|'([^']*)')\s*(?::\s*([A-Za-z_$][\w$]*))?/.exec(entry);
    if (!match) continue;
    const key = match[1] ?? match[2] ?? match[3]!;
    keys.set(match[4] ?? key, key);
  }
  return keys;
}

/** The argument a parent passes to listen to an event: `onChange` for `change`. */
function eventArgument(event: string): string {
  return `on${event.charAt(0).toUpperCase()}${event.slice(1)}`;
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

/**
 * The elements a component's root may be, which take the caller's attributes and which its
 * signature's `Element` names by tag: the root element, each branch's of a root conditional, or
 * each tag a root `<component is>` may render. None where a root may be anything else, such as a
 * component or text.
 */
function rootElements(component: UfComponent): { tags: string[]; spans: Span[] } {
  const { render } = component;
  if (render.kind === "Element") return { tags: [render.tag], spans: [render.span] };
  const none = { tags: [], spans: [] };
  if (render.children.length !== 1) return none;
  const tagsOf = (node: RenderNode | undefined): string[] | undefined => {
    if (node?.kind === "Element") return [node.tag];
    if (node?.kind !== "Dynamic") return undefined;
    const tags = node.candidates.flatMap((each) => (each.kind === "Tag" ? [each.tag] : []));
    return tags.length === node.candidates.length ? tags : undefined;
  };
  const [only] = render.children;
  const branches = only?.kind === "If" ? only.branches.map((branch) => branch.children) : [[only]];
  const tags = new Set<string>();
  const spans: Span[] = [];
  for (const children of branches) {
    const [node] = children;
    const found = children.length === 1 ? tagsOf(node) : undefined;
    if (!found || !node) return none;
    for (const tag of found) tags.add(tag);
    spans.push(node.span);
  }
  return { tags: Array.from(tags), spans };
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

type HelperName =
  | "afterRender"
  | "directive"
  | "inject"
  | "provider"
  | "refOf"
  | "callbacks"
  | "classNames"
  | "Effect"
  | "modelText"
  | "enumeratedValue"
  | "registerDestructor"
  | "renderSettled"
  | "sources"
  | "styleText"
  | "templateRef"
  | "toggle"
  | "uniqueId"
  | "Watcher";

/** What each module helper imports from Ember, by module: a `type ` name is a type. */
const HELPER_IMPORTS: Record<HelperName, Record<string, readonly string[]>> = {
  afterRender: { "@ember/destroyable": ["isDestroying"], "@ember/renderer": ["renderSettled"] },
  directive: DIRECTIVE_IMPORTS,
  inject: {},
  provider: {},
  refOf: {},
  callbacks: {},
  classNames: {},
  Effect: {
    "@ember/destroyable": ["isDestroying", "registerDestructor"],
    "@ember/renderer": ["renderSettled"],
  },
  enumeratedValue: {},
  registerDestructor: { "@ember/destroyable": ["registerDestructor"] },
  renderSettled: { "@ember/renderer": ["renderSettled"] },
  uniqueId: { "@ember/helper": ["uniqueId"] },
  modelText: {
    "@ember/modifier": ["capabilities", "setModifierManager"],
    "@glint/template": ["type ModifierLike"],
  },
  toggle: {},
  sources: {},
  styleText: {},
  templateRef: {
    "@ember/modifier": ["capabilities", "setModifierManager"],
    "@glint/template": ["type ModifierLike"],
  },
  Watcher: {
    "@ember/destroyable": ["isDestroying", "registerDestructor"],
    "@ember/renderer": ["renderSettled"],
  },
};

/** The module helpers, after the component. */
const HELPERS: Record<HelperName, string> = {
  directive: directiveHelpers().join("\n\n"),
  provider: `/**
 * Vue's \`provide\`: a text node, first in the component's root, that holds each provided value
 * under its key. The root's descendants find it, and no sibling of the root does (\`inject\`).
 */
function provider(entries: readonly (readonly [symbol, unknown])[]): Text {
  const marker = document.createTextNode("");
  for (const [key, value] of entries) Reflect.set(marker, key, value);
  return marker;
}`,
  inject: `/**
 * Vue's \`inject\`: the value of the nearest provider above \`marker\`, or the fallback. Ember
 * has no context API yet (RFC 1200), so this walks the DOM, as ember-primitives' dom-context
 * does: each ancestor and the nodes before it, where a provider's marker sits.
 */
function inject<T>(marker: Node, key: symbol, fallback: T): T {
  for (let parent: Node | null = marker; parent; parent = parent.parentNode) {
    for (let node = parent.previousSibling; node; node = node.previousSibling) {
      if (Reflect.has(node, key)) return Reflect.get(node, key) as T;
    }
  }
  return fallback;
}`,
  refOf: `/** A provided state as its consumers read a ref: a \`value\` getter over the tracked field. */
function refOf<T>(read: () => T): { readonly value: T } {
  return {
    get value() {
      return read();
    },
  };
}`,
  afterRender: `/** Runs \`run\` once the render settles, unless its component is gone by then. */
function afterRender(owner: object, run: () => unknown): void {
  // A component on the server never mounts, as Vue registers no hook in a server render.
  if (import.meta.env.SSR) return;
  void renderSettled().then(() => {
    if (!isDestroying(owner)) void run();
  });
}`,
  registerDestructor: "",
  renderSettled: "",
  uniqueId: "",
  toggle: `/** The values with \`value\` added when \`checked\`, and removed otherwise. */
function toggle<T>(values: readonly T[], value: T, checked: boolean): T[] {
  return checked ? values.concat([value]) : values.filter((each) => each !== value);
}`,
  modelText: `/**
 * A modifier that binds a text field as Vue's \`vModelText\` does: it writes what the user types,
 * trimmed or cast as \`looseToNumber\` casts it, on \`input\` or, when lazy, on \`change\`, and
 * shows each new value of the state, except where the text already reads as it, or while the
 * user types in a trimmed field what it reads as trimmed.
 */
const modelText = setModifierManager(
  () => ({
    capabilities: capabilities("3.22"),
    createModifier: (): ModelTextState => ({ setValue: () => {} }),
    installModifier(state: ModelTextState, element: Element, { positional, named }: ModelTextArgs) {
      const field = element as HTMLInputElement | HTMLTextAreaElement;
      state.field = field;
      state.setValue = positional[1];
      const read = () => {
        const text = named.trim ? field.value.trim() : field.value;
        return named.number ? looseToNumber(text) : text;
      };
      field.addEventListener(named.lazy ? "change" : "input", () => state.setValue(read()));
      if (named.trim || named.number) {
        field.addEventListener("change", () => {
          field.value = String(read());
        });
      }
      show(field, positional[0], named);
    },
    updateModifier(state: ModelTextState, { positional, named }: ModelTextArgs) {
      state.setValue = positional[1];
      if (state.field) show(state.field, positional[0], named);
    },
    destroyModifier() {},
  }),
  {},
) as unknown as ModifierLike<{
  Element: HTMLInputElement | HTMLTextAreaElement;
  Args: {
    Positional: [value: unknown, setValue: (value: never) => void];
    Named: { trim?: boolean; lazy?: boolean; number?: boolean };
  };
}>;

/** What \`modelText\` keeps of its field. */
interface ModelTextState {
  field?: HTMLInputElement | HTMLTextAreaElement;
  setValue: (value: unknown) => void;
}

/** What \`modelText\`'s manager is given. */
interface ModelTextArgs {
  positional: readonly [unknown, (value: unknown) => void];
  named: { trim?: boolean; lazy?: boolean; number?: boolean };
}

/** A text as a number where it reads as one, as Vue's \`looseToNumber\` casts it. */
function looseToNumber(text: string): string | number {
  const number = Number.parseFloat(text);
  return Number.isNaN(number) ? text : number;
}

/** Shows a state's value in a field, as \`vModelText\`'s update does. */
function show(
  field: HTMLInputElement | HTMLTextAreaElement,
  value: unknown,
  named: { trim?: boolean; number?: boolean },
): void {
  const next = value ?? "";
  const shown = named.number && !/^0\\d/.test(field.value) ? looseToNumber(field.value) : field.value;
  if (shown === next) return;
  const typing = document.activeElement === field && field.type !== "range";
  if (typing && named.trim && field.value.trim() === next) return;
  field.value = String(next);
}`,
  callbacks: `/** How many watchers' callbacks are to run once the current render is done. */
const callbacks = { pending: 0 };`,
  sources: `/** An array of watch sources, typed as a tuple. */
function sources<T extends unknown[]>(...values: T): T {
  return values;
}`,
  templateRef: `/** A modifier that sets a member of its component to its element while the element is rendered. */
const templateRef = setModifierManager(
  () => ({
    capabilities: capabilities("3.22"),
    createModifier: () => ({}),
    installModifier(_state: object, element: Element, { positional }: { positional: readonly unknown[] }) {
      Reflect.set(positional[0] as object, positional[1] as string, element);
    },
    updateModifier() {},
    destroyModifier(_state: object, { positional }: { positional: readonly unknown[] }) {
      Reflect.set(positional[0] as object, positional[1] as string, null);
    },
  }),
  {},
) as unknown as ModifierLike<{ Element: Element; Args: { Positional: [owner: object, name: string] } }>;`,
  Watcher: `/**
 * Vue's \`watch\`: the template calls \`flush\` before anything else, so it sees a change of a
 * source in the render that follows it, and the callback runs right after that render, or once
 * the render settles for a \`post\` watcher. A cleanup the callback registers runs before its
 * next run, and when the component is destroyed.
 */
class Watcher<T> {
  readonly #owner: object;
  readonly #source: () => T;
  readonly #callback: (value: T, previous: T, onCleanup: (cleanup: () => void) => void) => unknown;
  readonly #options: { array?: boolean; immediate?: boolean; post?: boolean };
  #started = false;
  #value: T | undefined;
  #cleanup: (() => void) | undefined;

  constructor(
    owner: object,
    source: () => T,
    callback: (value: T, previous: T, onCleanup: (cleanup: () => void) => void) => unknown,
    options: { array?: boolean; immediate?: boolean; post?: boolean } = {},
  ) {
    this.#owner = owner;
    this.#source = source;
    this.#callback = callback;
    this.#options = options;
    registerDestructor(owner, () => this.#cleanup?.());
  }

  readonly flush = (): undefined => {
    const value = this.#source();
    const started = this.#started;
    // On the server a watcher runs at most its immediate first run, as Vue's does.
    if (import.meta.env.SSR && started) return undefined;
    if (started && this.#same(value, this.#value as T)) return undefined;
    const previous = (started ? this.#value : this.#options.array ? [] : undefined) as T;
    this.#started = true;
    this.#value = value;
    if (!started && !this.#options.immediate) return undefined;
    const run = () => {
      const cleanup = this.#cleanup;
      this.#cleanup = undefined;
      cleanup?.();
      void this.#callback(value, previous, (each) => {
        this.#cleanup = each;
      });
    };
    // The render that calls \`flush\` has read what the callback may write, so the callback
    // runs right after it, or once the render settles for a \`post\` watcher.
    const later = () => {
      if (!isDestroying(this.#owner)) run();
    };
    if (this.#options.post) void renderSettled().then(later);
    else {
      callbacks.pending += 1;
      queueMicrotask(() => {
        callbacks.pending -= 1;
        later();
      });
    }
    return undefined;
  };

  #same(value: T, previous: T): boolean {
    if (!this.#options.array) return Object.is(value, previous);
    const values = value as unknown[];
    const previousValues = previous as unknown[];
    return values.every((each, index) => Object.is(each, previousValues[index]));
  }
}`,
  Effect: `/**
 * Vue's \`watchEffect\`: the template calls \`flush\` after everything else, so the effect runs
 * once the component has rendered in the browser, and again when what it read changes. A
 * cleanup it registers runs before its next run, and when the component is destroyed.
 */
class Effect {
  @tracked ready = false;
  readonly #owner: object;
  readonly #effect: (onCleanup: (cleanup: () => void) => void) => unknown;
  #cleanup: (() => void) | undefined;

  constructor(owner: object, effect: (onCleanup: (cleanup: () => void) => void) => unknown) {
    this.#owner = owner;
    this.#effect = effect;
    registerDestructor(owner, () => this.#cleanup?.());
    void renderSettled().then(() => {
      if (!isDestroying(owner)) this.ready = true;
    });
  }

  readonly flush = (): undefined => {
    if (!this.ready) return undefined;
    // A watcher's callback is still to run after this render: the effect runs once after it,
    // and sees what it writes. Writing \`ready\` again renders this call again then.
    if (callbacks.pending) {
      queueMicrotask(() => {
        if (!isDestroying(this.#owner)) this.ready = true;
      });
      return undefined;
    }
    const cleanup = this.#cleanup;
    this.#cleanup = undefined;
    cleanup?.();
    void this.#effect((each) => {
      this.#cleanup = each;
    });
    return undefined;
  };
}`,
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
