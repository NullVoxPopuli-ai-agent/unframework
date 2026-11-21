import Picker from "./Picker";
import type { ComponentPropsWithRef } from "react";

interface Fruit {
  name: string;
  count: number;
}

export type FruitsAttributes = Omit<ComponentPropsWithRef<"ul">, "fruits" | "children">;

export default function Fruits({
  fruits,
  className,
  style,
  ...attributes
}: { fruits: Fruit[] } & FruitsAttributes) {
  return (
    <Picker
      items={fruits}
      className={className}
      style={style}
      {...attributes}
      renderItem={({ item }) => (
        <span>
          {item.name} × {item.count}
        </span>
      )}
    />
  );
}
