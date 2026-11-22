// `ember-source` publishes its modules' types as ambient declarations.
/// <reference types="ember-source/types" />
import { renderComponent } from "@ember/renderer";
import createDocument from "@simple-dom/document";
import Serializer from "@simple-dom/serializer";
import voidMap from "@simple-dom/void-map";
import type { SsrRenderer } from "@unframework.dev/codegen";

/**
 * Renders a compiled Ember component on the server: `renderComponent` into a simple-dom
 * document, which is what FastBoot renders into, without a DOM and without running client code,
 * then serialised. Only the component's HTML: the container is not part of it.
 */
/** What Node has for `Element`: nothing is one. */
const NoElement = { [Symbol.hasInstance]: (): boolean => false };

export const renderToString: SsrRenderer = async (component, { props = {} }) => {
  // `renderComponent` tests `into instanceof Element` before it clears a browser container. Node
  // has no `Element`, and a simple-dom element is no browser one.
  globalThis.Element ??= NoElement as unknown as typeof Element;
  const document = createDocument();
  const into = document.createElement("div");
  document.body.appendChild(into);
  // A fresh owner for each render: the renderer it caches is bound to one document.
  const result = renderComponent(component as object, {
    owner: {},
    into,
    args: { ...props },
    env: { document: document as unknown as Document, isInteractive: false, hasDOM: false },
  });
  const html = new Serializer(voidMap).serializeChildren(into);
  result.destroy();
  return html;
};
