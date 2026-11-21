// fallthrough/root-ref: a ref on a component that exposes nothing holds its root element
// (ADR-0118), an <input>, which the parent focuses. The component's own template ref on the
// same element still works: its own focus listener fills the field through it.
import { describeTargets, it, mount } from "@unframework.dev/testing";
import { expect } from "vitest";

import Profile from "./Profile.uf.tsx";

describeTargets("fallthrough/root-ref", () => {
  it("renders the field", async () => {
    const view = await mount(Profile);
    await view.expectParity("initial");
    await expect.element(view.getByRole("textbox", { name: "Name" })).toHaveValue("");
  });

  it(
    "holds the root element in the parent's ref and the component's own",
    { requires: ["interactivity", "expose"] },
    async () => {
      const view = await mount(Profile);
      await view.user.click(view.getByRole("button", { name: "Edit name" }));
      await view.expectParity("focused");
      await expect.element(view.getByRole("textbox", { name: "Name" })).toHaveFocus();
      await expect.element(view.getByRole("textbox", { name: "Name" })).toHaveValue("Ada");
    },
  );
});
