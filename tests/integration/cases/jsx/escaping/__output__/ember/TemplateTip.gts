import Component from "@glimmer/component";

export interface TemplateTipProps {
  example: string;
  note: string;
  path: string;
}

export interface TemplateTipSignature {
  Args: TemplateTipProps;
  Element: HTMLElementTagNameMap["figure"];
}

export default class TemplateTip extends Component<TemplateTipSignature> {
  get value1() {
    return this.args.path + "\\index.ts";
  }

  get value2() {
    return "{{ " + this.args.path + " }}";
  }

  <template><figure
      class="template-tip"
      ...attributes
    ><figcaption
      title="Vue \{{ name }}, Svelte {#if ok}, Angular @if (ok) &amp; JSX {name}"
    >Template syntax &amp; escaping</figcaption><pre><code>{{@example}}</code></pre><p
      data-sample="<b> &quot;double&quot; 'single' C:\temp"
    >Static: &lt;b>not bold&lt;/b>, \{{ name }}, @if (ok) { }</p><p>Literal: \{{ name }} &lt;i>not italic&lt;/i> {#each items} @for "quoted" C:\temp café</p><p
      title="Say &quot;hi&quot; &amp; wave"
    >Quoted attribute</p><p
      title={{@note}}
      data-path={{@path}}
    >Bound: {{@note}} in {{this.value1}}</p><p>Mustache: {{this.value2}}</p><p>Done &amp;check;</p></figure></template>
}
