// fallthrough/root-ref: a ref on a component that exposes nothing holds its root element
// (ADR-0118), an <input>, which the parent focuses. The component's own template ref on the
// same element still works: it fills the field once mounted.
import { describeTargets, it, mount } from "@unframework.dev/testing";
import { expect } from "vitest";

import Profile from "./Profile.uf.tsx";

describeTargets("fallthrough/root-ref", () => {
  it("renders the field", async () => {
    const view = await mount(Profile);
    await view.expectParity("initial");
    await expect.element(view.getByRole("textbox", { name: "Name" })).toBeVisible();
  });

  it("keeps the component's own ref", { requires: ["interactivity"] }, async () => {
    const view = await mount(Profile);
    await expect.element(view.getByRole("textbox", { name: "Name" })).toHaveValue("Ada");
  });

  it("holds the root element in the ref", { requires: ["interactivity", "expose"] }, async () => {
    const view = await mount(Profile);
    await view.user.click(view.getByRole("button", { name: "Edit name" }));
    await view.expectParity("focused");
    await expect.element(view.getByRole("textbox", { name: "Name" })).toHaveFocus();
  });
});
