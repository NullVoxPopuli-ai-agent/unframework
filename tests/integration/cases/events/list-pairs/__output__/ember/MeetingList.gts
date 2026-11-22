import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";

export interface Meeting {
  id: number;
  title: string;
  done: boolean;
}

export interface Organiser {
  name: string;
}

export interface MeetingListProps {
  meetings: Meeting[];
  organiser?: Organiser;
}

export interface MeetingListEvents {
  onOpened?: (title: string) => void;
  onThanked?: (name: string) => void;
  onTrack?: (name: string, count: number) => void;
}

export interface MeetingListSignature {
  Args: MeetingListProps & MeetingListEvents;
  Element: HTMLElementTagNameMap["section"];
}

export default class MeetingList extends Component<MeetingListSignature> {
  record = (line: string) => {
    this.log = [...this.log, line];
  };

  show = (meeting: Meeting) => {
    this.record(`show ${meeting.title}`);
  };

  book = async (room: string) => {
    await Promise.resolve();
    this.record(`booked ${room}`);
  };

  remember = (key: string): boolean => {
    this.lastKey = key;
    return key === "Enter";
  };

  @tracked rooms = ["Atlas", "Borealis"];

  @tracked log: string[] = [];

  @tracked lastKey = "none";

  @tracked clicks = 0;

  get upcoming() {
    return this.args.meetings.filter((meeting) => !meeting.done);
  }

  listener1 = (event: NonNullable<this["upcoming"]>[number]) => () => this.show(event);

  listener2 = (event: NonNullable<this["upcoming"]>[number]) => () =>
    this.args.onOpened?.(event.title);

  listener3 = (room: NonNullable<this["rooms"]>[number]) => () => this.record(`pick ${room}`);

  listener4 = (room: NonNullable<this["rooms"]>[number]) => async () => this.book(room);

  get value1() {
    return this.args.organiser ? `Thank ${this.args.organiser.name}` : undefined;
  }

  listener5 = () => {
    if (!this.args.organiser) return;
    return this.record(`thank ${this.args.organiser.name}`);
  };

  listener6 = () => {
    if (!this.args.organiser) return;
    return this.args.onThanked?.(this.args.organiser.name);
  };

  listener7 = () => (this.clicks += 1);

  listener8 = () => {
    const event = "first-click";
    this.args.onTrack?.(event, this.clicks);
  };

  listener9 = (event: HTMLElementEventMap["keydown"]) => {
    if (event.altKey) return false;
    return this.remember(event.key);
  };

  <template><section
      class="meeting-list"
      aria-label="Meetings"
      ...attributes
    ><ul
      aria-label="Upcoming"
    >{{#each this.upcoming key="id" as |event|}}<li><button
      type="button"
      {{on "click" (this.listener1 event)}}
      {{on "click" (this.listener2 event) once=true}}
    >{{event.title}}</button></li>{{/each}}</ul><ul
      aria-label="Rooms"
    >{{#each this.rooms key="@identity" as |room|}}<li><button
      type="button"
      {{on "click" (this.listener3 room)}}
      {{on "click" (this.listener4 room) once=true}}
    >{{room}}</button></li>{{/each}}</ul>{{#if @organiser}}<button
      type="button"
      {{on "click" this.listener5}}
      {{on "click" this.listener6 once=true}}
    >{{this.value1}}</button>{{else}}<p>No organiser</p>{{/if}}<button
      type="button"
      {{on "click" this.listener7}}
      {{on "click" this.listener8 once=true}}
    >Track</button><p>Clicks: {{this.clicks}}</p><label>Filter<input
      name="filter"
      {{on "keydown" this.listener9}}
    ></label><p>Last key: {{this.lastKey}}</p><ol
      aria-label="Log"
    >{{#each this.log key="@index" as |line|}}<li>{{line}}</li>{{/each}}</ol></section></template>
}
