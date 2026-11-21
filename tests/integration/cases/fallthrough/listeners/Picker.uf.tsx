import { ref } from "@uxfront/unframework";

import Chip from "./Chip.uf.tsx";

export default function Picker() {
  const log = ref<string[]>([]);

  function record(line: string) {
    log.value = [...log.value, line];
  }

  return (
    <section aria-label="Picker">
      <Chip
        label="Ada"
        onClick={() => record("click")}
        onPick={(label) => record(`pick ${label}`)}
        onFocus={() => record("focus")}
        onKeydown={(event) => record(`keydown ${event.key}`)}
      />
      <ol aria-label="Log">
        {log.value.map((entry, index) => (
          <li key={index}>{entry}</li>
        ))}
      </ol>
    </section>
  );
}
