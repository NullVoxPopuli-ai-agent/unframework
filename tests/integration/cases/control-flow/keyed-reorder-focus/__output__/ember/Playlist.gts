import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface Track {
  id: number;
  title: string;
  starred: boolean;
}

export interface PlaylistProps {
  initial: Track[];
}

export interface PlaylistSignature {
  Args: PlaylistProps;
  Element: HTMLElementTagNameMap["section"];
}

export default class Playlist extends Component<PlaylistSignature> {
  sortByTitle = () => {
    this.tracks = this.tracks.toSorted((a, b) => a.title.localeCompare(b.title));
  };

  toggleStar = (id: number) => {
    this.tracks = this.tracks.map((track) =>
      track.id === id ? { ...track, starred: !track.starred } : track,
    );
  };

  @tracked tracks = this.args.initial;

  value1 = (track: NonNullable<this["tracks"]>[number]) =>
    track.starred ? `${track.title} (starred)` : track.title;

  value2 = (track: NonNullable<this["tracks"]>[number]) => `Star ${track.title}`;

  listener1 = (track: NonNullable<this["tracks"]>[number]) => () => this.toggleStar(track.id);

  <template><section
      class="playlist"
      ...attributes
    ><ol
      aria-label="Playlist"
    >{{#each this.tracks key="id" as |track|}}<li><label><input
      type="checkbox"
      name="queued"
      value={{track.id}}
    >{{this.value1 track}}</label><button
      type="button"
      aria-pressed={{enumeratedValue track.starred}}
      {{on "click" (this.listener1 track)}}
    >{{this.value2 track}}</button></li>{{/each}}</ol><button
      type="button"
      {{on "click" this.sortByTitle}}
    >Sort by title</button></section></template>
}

/** An enumerated attribute's value: a boolean as its name, any other value as it is. */
function enumeratedValue<T>(value: T): Exclude<T, boolean> | "true" | "false" {
  return typeof value === "boolean"
    ? (String(value) as "true" | "false")
    : (value as Exclude<T, boolean>);
}
